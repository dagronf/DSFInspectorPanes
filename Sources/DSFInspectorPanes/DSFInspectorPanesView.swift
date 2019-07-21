//
//  DSFInspectorPanesView.swift
//
//  Created by Darren Ford on 30/4/19.
//
//  MIT License
//
//  Copyright (c) 2019 Darren Ford
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Carbon.HIToolbox
import Cocoa

@objc public protocol DSFInspectorPanesViewProtocol {
	@objc optional func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didReorder orderedPanes: [DSFInspectorPane])
	@objc optional func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didExpandOrContract pane: DSFInspectorPane)
}

internal protocol DSFInspectorPanesAction {
	func moveUp()
	func moveDown()
	func toggleVisibility()
}

@IBDesignable
@objc public class DSFInspectorPanesView: NSView {

	@available (macOS 10.12.2, *)
	private static let popoverIdentifier = NSTouchBarItem.Identifier("com.darrenford.inspectorpanes.popover")

	/// Delegate to receive messages
	@objc public var inspectorPaneDelegate: DSFInspectorPanesViewProtocol?

	/// The 'look' of the inspector panes
	@objc internal enum InspectorType: UInt {
		/// Draw a rounded rectangle around each pane
		case box
		/// Draw a separator between each pane
		case separator
		/// No drawing
		case none
	}

	/// Should we animate hiding and showing?
	@IBInspectable private(set) var animated: Bool = true

	/// Should (when added) property panes be added to an embedded scrollable view?
	@IBInspectable private(set) var embeddedInScrollView: Bool = true

	/// Should there be separators between the inspector panes?
	@IBInspectable private(set) var showSeparators: Bool = true

	/// Should we wrap each inspector pane in a rounded box?
	@IBInspectable private(set) var showBoxes: Bool = false

	/// Can we rearrange the order by dragging the inspector pane?
	@IBInspectable private(set) var canReorderPanes: Bool = false

	/// The way the inspector is separated
	@objc private(set) var inspectorType: InspectorType = .none

	/// Edge insets from the view to inset the panes
	@objc public var insets: NSEdgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
		didSet {
			self.primaryStack.edgeInsets = self.insets
			self.primaryStack.needsLayout = true
		}
	}

	//! The font to use in the title for all property panes
	@objc public var titleFont: NSFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize) {
		didSet {
			self.arrangedInspectorPanes.forEach { $0.titleFont = self.titleFont }
			self.needsLayout = true
		}
	}

	/// Vertical spacing between panes
	@objc @IBInspectable public var spacing: CGFloat = 8 {
		didSet {
			self.primaryStack.spacing = self.spacing
			self.primaryStack.needsLayout = true
		}
	}

	/// Return an array containing all the inspector panes
	@objc public var panes: [DSFInspectorPane] {
		return self.arrangedInspectorPanes as [DSFInspectorPane]
	}

	private var scrollView: NSScrollView?
	private let primaryStack = FlippedStackView()

	@objc public init(frame frameRect: NSRect,
					  animated: Bool = true,
					  embeddedInScrollView: Bool = true,
					  showSeparators: Bool = true,
					  showBoxes: Bool = false,
					  titleFont: NSFont? = nil,
					  canDragRearrange: Bool = false) {
		self.animated = animated
		self.embeddedInScrollView = embeddedInScrollView
		self.showSeparators = showSeparators
		self.showBoxes = showBoxes
		self.canReorderPanes = canDragRearrange

		if let font = titleFont {
			self.titleFont = font
		}
		super.init(frame: frameRect)
		self.setup()
	}

	@objc required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}

	private var _popover: AnyObject?
	@available(macOS 10.12.2, *)
	private var popover: DSFInspectorPanesPopoverTouchBar? {
		get {
			return _popover as? DSFInspectorPanesPopoverTouchBar
		}
		set {
			_popover = newValue
		}
	}
}

// MARK: - Initialization and setup

extension DSFInspectorPanesView {
	public override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.setContentCompressionResistancePriority(.required, for: .vertical)
		self.setContentHuggingPriority(.required, for: .vertical)

		// Hook ourselves up to receive drag events from the draggable stack
		self.primaryStack.canReorder = self.canReorderPanes
		self.primaryStack.dragDelegate = self

		if self.showSeparators == true {
			self.inspectorType = .separator
		}
		else if self.showBoxes == true {
			self.inspectorType = .box
		}
		else {
			self.inspectorType = .none
		}

		if self.embeddedInScrollView {
			let sv = NSScrollView(frame: bounds)
			scrollView = sv
			sv.translatesAutoresizingMaskIntoConstraints = false
			sv.hasVerticalScroller = true
			sv.identifier = NSUserInterfaceItemIdentifier("ScrollView")
			sv.setContentHuggingPriority(.defaultLow, for: .horizontal)
			sv.setContentHuggingPriority(.defaultLow, for: .vertical)
			sv.hasHorizontalScroller = false
			sv.hasVerticalScroller = true
			sv.autohidesScrollers = true
			addSubview(sv)

			let variableBindings = ["scrollview": sv] as [String: Any]
			addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-0-[scrollview]-0-|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings
			))
			addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "V:|-0-[scrollview]-0-|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings
			))
		}

		self.primaryStack.translatesAutoresizingMaskIntoConstraints = false
		self.primaryStack.orientation = .vertical
		self.primaryStack.alignment = .left
		self.primaryStack.distribution = .fillProportionally
		self.primaryStack.spacing = self.spacing
		self.primaryStack.detachesHiddenViews = true
		self.primaryStack.edgeInsets = self.insets
		self.primaryStack.setContentHuggingPriority(.required, for: .vertical)
		self.primaryStack.setContentCompressionResistancePriority(.required, for: .vertical)

		if self.embeddedInScrollView, let sv = self.scrollView {
			sv.documentView = self.primaryStack
			let variableBindings2 = ["_documentView": self.primaryStack] as [String: Any]
			let hConstraints = NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[_documentView]|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings2
			)
			let vConstraints = NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[_documentView]",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings2
			)

			sv.contentView.addConstraints(hConstraints)
			sv.contentView.addConstraints(vConstraints)
		} else {
			addSubview(self.primaryStack)
			let variableBindings2 = ["_stack": self.primaryStack] as [String: Any]
			let hConstraints = NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[_stack]|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings2
			)
			let vConstraints = NSLayoutConstraint.constraints(
				withVisualFormat: "V:|-0@1000-[_stack]-0@1000-|",
				options: .alignAllBottom,
				metrics: nil,
				views: variableBindings2
			)
			addConstraints(hConstraints)
			addConstraints(vConstraints)

			self.primaryStack.setClippingResistancePriority(.required, for: .vertical)
			self.primaryStack.setHuggingPriority(.required, for: .vertical)
			self.superview?.setContentHuggingPriority(.required, for: .vertical)
		}
	}

	/// Return the contained inspector panes
	private var arrangedInspectorPanes: [DSFInspectorPanesView.Pane] {
		return self.primaryStack.arrangedSubviews as? [DSFInspectorPanesView.Pane] ?? []
	}

	public override func prepareForInterfaceBuilder() {

		// Note that awakeFromNib is NOT called when dealing with prepareForInterfaceBuilder!
		// So we have to set it up for ourselves
		self.setup()

		let b1 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b1.title = "Button 1"
		let b2 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b2.title = "Button 2"

		self.add(title: "Pane 1", view: b1)
		self.add(title: "Pane 2", view: b2)

		self.layout()
	}
}


// MARK: - Adding, moving, reordering

@objc public extension DSFInspectorPanesView {
	@discardableResult
	func add(
		title: String,
		view: NSView,
		showsHeader: Bool = true,
		headerAccessoryView: NSView? = nil,
		canHide: Bool = true,
		expanded: Bool = true
		) -> DSFInspectorPane {
		view.translatesAutoresizingMaskIntoConstraints = false

		let inspectorPaneView = DSFInspectorPanesView.Pane(
			titleFont: self.titleFont,
			showsHeader: showsHeader,
			canHide: canHide,
			canReorder: self.canReorderPanes,
			inspectorType: self.inspectorType,
			animated: self.animated,
			initiallyExpanded: expanded)

		inspectorPaneView.translatesAutoresizingMaskIntoConstraints = false
		inspectorPaneView.changeDelegate = self
		inspectorPaneView.separatorVisible = self.arrangedInspectorPanes.count != 0
		inspectorPaneView.inspectorType = self.inspectorType
		inspectorPaneView.add(propertyView: view, headerAccessoryView: headerAccessoryView)
		inspectorPaneView.title = title
		self.primaryStack.addArrangedSubview(inspectorPaneView)

		let metrics = ["leftInset": insets.left, "rightInset": insets.right]
		let variableBindings = ["disclosureView": inspectorPaneView] as [String: Any]
		primaryStack.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-(leftInset)-[disclosureView]-(rightInset)-|",
			options: .alignAllLastBaseline,
			metrics: metrics as [String: NSNumber],
			views: variableBindings
		))

		if canHide, !expanded {
			inspectorPaneView.openDisclosure(open: false, animated: false)
		}

		view.needsUpdateConstraints = true
		view.needsLayout = true
		self.primaryStack.needsLayout = true
		inspectorPaneView.needsLayout = true
		inspectorPaneView.needsUpdateConstraints = true
		self.primaryStack.needsUpdateConstraints = true

		self.enclosingScrollView?.reflectScrolledClipView(self.enclosingScrollView!.contentView)

		window?.recalculateKeyViewLoop()
		return inspectorPaneView
	}

	/// Returns the index of the specified pane object
	func index(of item: DSFInspectorPane) -> Int {
		guard let pane = item as? DSFInspectorPanesView.Pane,
			let index = self.arrangedInspectorPanes.firstIndex(of: pane) else {
				return -1
		}
		return index
	}

	/// Remove the inspector pane at the specified index
	func remove(at index: Int) {
		assert(index < self.primaryStack.arrangedSubviews.count)

		let view = self.primaryStack.arrangedSubviews[index]
		self.primaryStack.removeArrangedSubview(view)
	}

	func removeAll() {
		self.arrangedInspectorPanes.forEach { $0.removeFromSuperview() }
		self.primaryStack.needsLayout = true
	}

	func move(index: Int, to newIndex: Int) {
		assert(index < self.primaryStack.arrangedSubviews.count)
		assert(newIndex < self.primaryStack.arrangedSubviews.count)

		var primary = self.arrangedInspectorPanes
		primary.forEach { self.primaryStack.removeView($0) }
		primary.move(from: index, to: newIndex)
		primary.forEach {
			self.reAdd(pane: $0)
		}
		self.inspectorPaneDelegate?.inspectorPanes?(self, didReorder: self.arrangedInspectorPanes)
	}

	func swap(index: Int, with newIndex: Int) {
		assert(index < self.primaryStack.arrangedSubviews.count)
		assert(newIndex < self.primaryStack.arrangedSubviews.count)

		var primary = self.arrangedInspectorPanes
		primary.forEach { self.primaryStack.removeView($0) }
		primary.swapAt(index, newIndex)
		primary.forEach {
			self.reAdd(pane: $0)
		}
		self.inspectorPaneDelegate?.inspectorPanes?(self, didReorder: self.arrangedInspectorPanes)
	}

	private func reAdd(pane: DSFInspectorPanesView.Pane) {
		self.primaryStack.addArrangedSubview(pane)
		// If we're embedded in a scroll view, give ourselves more horizontal gap to our border
		let vScrollWidth = self.embeddedInScrollView ? 12 : 4
		let metrics = ["vScrollWidth": vScrollWidth]
		let variableBindings = ["disclosureView": pane] as [String: Any]
		primaryStack.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-(vScrollWidth)-[disclosureView]-(vScrollWidth)-|",
			options: .alignAllLastBaseline,
			metrics: metrics as [String: NSNumber],
			views: variableBindings
		))
	}

	/// Convenience method for showing or hiding all of the inspector panes at once
	func expandAll(_ expanded: Bool, animated: Bool) {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(expanded, animated: animated) }
	}
}

// MARK: Menu handling, key bindings

extension DSFInspectorPanesView: NSUserInterfaceValidations {
	private func focussedPane() -> (index: Int, pane: DSFInspectorPanesView.Pane)? {
		guard let focussed = self.window?.firstResponder as? DSFInspectorPanesView.Pane else {
			return nil
		}
		let index = self.index(of: focussed)
		guard index >= 0 else {
			return nil
		}
		return (index, focussed)
	}

	public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		if item.action == #selector(self.movePaneUp(_:)) {
			return canMoveUp(item)
		}
		else if item.action == #selector(self.movePaneDown(_:)) {
			return canMoveDown(item)
		}
		else if item.action == #selector(self.togglePane(_:)) {
			return canToggle(item)
		}
		return false
	}

	// MARK: Toggle a panes visibility

	private func canToggle(_ sender: Any?) -> Bool {
		let focussed = self.focussedPane()
		if let menuItem = sender as? NSMenuItem {
			guard let hasFocus = focussed else {
				menuItem.state = .off
				return false
			}
			menuItem.state = hasFocus.pane.expanded ? .on : .off
		}

		if let focussed = focussedPane() {
			return focussed.pane.canExpand
		}
		return false
	}

	@objc public func togglePane(_: Any?) {
		guard let focussed = focussedPane() else {
			return
		}
		focussed.pane.toggleDisclosure(sender: self)
	}

	// MARK: Move Up

	private func canMoveUp(_: Any?) -> Bool {
		if !self.canReorderPanes { return false }
		guard let focussed = focussedPane() else { return false }
		return focussed.index > 0
	}

	@objc public func movePaneUp(_: Any?) {
		guard self.canReorderPanes else {
			return
		}

		guard let focussed = self.focussedPane(),
			focussed.index > 0 else {
				return
		}

		self.swap(index: focussed.index, with: focussed.index - 1)
		self.window?.makeFirstResponder(focussed.pane)
		self.window?.recalculateKeyViewLoop()
	}

	// MARK: Move Down

	private func canMoveDown(_: Any?) -> Bool {
		if !self.canReorderPanes { return false }
		guard let focussed = focussedPane() else { return false }
		return focussed.index < (self.panes.count - 1)
	}

	@objc public func movePaneDown(_: Any?) {
		guard self.canReorderPanes else {
			return
		}

		guard let focussed = self.focussedPane(),
			focussed.index < (self.panes.count - 1) else {
				return
		}

		self.swap(index: focussed.index, with: focussed.index + 1)
		self.window?.makeFirstResponder(focussed.pane)
		self.window?.recalculateKeyViewLoop()
	}
}

extension DSFInspectorPanesView: DSFInspectorPanesAction {
	func moveUp() {
		self.movePaneUp(self)
	}

	func moveDown() {
		self.movePaneDown(self)
	}

	func toggleVisibility() {
		self.togglePane(self)
	}
}

// MARK: - Delegate callback handling

extension DSFInspectorPanesView: DraggingStackViewProtocol {
	func stackViewDidReorder() {
		for inspector in self.arrangedInspectorPanes.filter({ $0.inspectorType == .separator }).enumerated() {
			inspector.element.separatorVisible = inspector.offset != 0
			inspector.element.needsDisplay = true
		}
		self.window?.recalculateKeyViewLoop()

		if #available(macOS 10.12.2, *) {
			if let focused = self.focussedPane() {
				updateTouchbarTitleForVisibility(for: focused.pane, at: focused.index)
			}
		}

		self.inspectorPaneDelegate?.inspectorPanes?(self, didReorder: self.panes)
	}
}

extension DSFInspectorPanesView: DSFInspectorPaneViewDelegate {

	func inspectorPaneDidFocus(_ pane: DSFInspectorPanesView.Pane) {
		if #available(macOS 10.12.2, *) {
			guard let focused = self.focussedPane() else {
				return
			}
			self.updateTouchbarTitleForVisibility(for: pane, at: focused.index)
		}
	}

	func inspectorPaneDidChangeVisibility(_ pane: DSFInspectorPanesView.Pane) {
		if #available(macOS 10.12.2, *) {
			updateTouchbarTitleForVisibility(for: pane)
		}

		self.inspectorPaneDelegate?.inspectorPanes?(self, didExpandOrContract: pane)
	}
}

// MARK: - Touch bar handling

@available (macOS 10.12.2, *)
extension DSFInspectorPanesView: NSTouchBarDelegate {

	public override func makeTouchBar() -> NSTouchBar? {
		let mainBar = NSTouchBar()

		mainBar.delegate = self
		mainBar.defaultItemIdentifiers = [
			DSFInspectorPanesView.popoverIdentifier,
			.otherItemsProxy
		]
		return mainBar
	}

	public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {

		if identifier == DSFInspectorPanesView.popoverIdentifier {
			let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
			popoverItem.showsCloseButton = true
			popoverItem.customizationLabel = NSLocalizedString("Popover", comment:"")
			popoverItem.collapsedRepresentationImage = NSImage(named: NSImage.Name("NSListViewTemplate"))
			popoverItem.collapsedRepresentationLabel = NSLocalizedString("Pane", comment: "")

			let pv = DSFInspectorPanesPopoverTouchBar(inspectorView: self, presentingItem: popoverItem)
			self.popover = pv

			popoverItem.popoverTouchBar = pv

			if let pp = self.focussedPane() {
				updateTouchbarTitleForVisibility(for: pp.pane, at: pp.index)
			}
			else {
				pv.canExpand = false
				pv.canMoveDown = false
				pv.canMoveUp = false
			}

			return popoverItem
		}
		return nil
	}
}

@available (macOS 10.12.2, *)
extension DSFInspectorPanesView {
	func updateTouchbarTitleForVisibility(for pane: DSFInspectorPanesView.Pane, at index: Int? = nil) {

		guard let p = self.popover else {
			return
		}

		p.canMoveDown = self.canReorderPanes
		p.canMoveUp = self.canReorderPanes

		if let index = index, self.canReorderPanes {
			p.canMoveDown = index < self.panes.count - 1
			p.canMoveUp = index != 0
		}

		p.canExpand = pane.canExpand
		p.isExpanded = pane.expanded
	}
}

@available (macOS 10.12.2, *)
class DSFInspectorPanesPopoverTouchBar: NSTouchBar, NSTouchBarDelegate {

	private static let moveUpIdentifier = NSTouchBarItem.Identifier("com.darrenford.inspectorpanes.moveup")
	private static let moveDownIdentifier = NSTouchBarItem.Identifier("com.darrenford.inspectorpanes.movedown")
	private static let toggleIdentifier = NSTouchBarItem.Identifier("com.darrenford.inspectorpanes.toggle")

	private var inspectorPanesView: DSFInspectorPanesAction? = nil

	public var canMoveUp: Bool = true {
		didSet {
			(touchbarMoveUpItem.view as? NSButton)?.isEnabled = self.canMoveUp
		}
	}

	public var canMoveDown: Bool = true {
		didSet {
			(touchbarMoveDownItem.view as? NSButton)?.isEnabled = self.canMoveDown
		}
	}

	public var canExpand: Bool = true {
		didSet {
			if let button = touchbarToggleItem.view as? NSButton {
				button.isEnabled = self.canExpand
			}
		}
	}

	public var isExpanded: Bool = true {
		didSet {
			if let button = touchbarToggleItem.view as? NSButton {
				button.title = self.isExpanded
					? NSLocalizedString("Close", comment: "Close an open inspector pane")
					: NSLocalizedString("Open", comment: "Open a closed inspector pane")
				button.image = self.isExpanded
					? NSImage(named: NSImage.Name("NSTouchBarExitFullScreenTemplate"))
					: NSImage(named: NSImage.Name("NSTouchBarEnterFullScreenTemplate"))
			}
		}
	}

	lazy var touchbarMoveDownItem: NSCustomTouchBarItem = {
		let touchbaritem = NSCustomTouchBarItem(identifier: DSFInspectorPanesPopoverTouchBar.moveDownIdentifier)
		let button = NSButton(title: NSLocalizedString("Move Down", comment: "Move the selected pane down in the inspector pane view"),
							  image: NSImage(named: NSImage.Name("NSTouchBarGoDownTemplate"))!,
							  target: self, action: #selector(self.movePaneDown(_:)))
		touchbaritem.view = button
		return touchbaritem
	}()

	lazy var touchbarMoveUpItem: NSCustomTouchBarItem = {
		let touchbaritem = NSCustomTouchBarItem(identifier: DSFInspectorPanesPopoverTouchBar.moveUpIdentifier)
		let button = NSButton(title: NSLocalizedString("Move Up", comment: "Move the selected pane up in the inspector pane view"),
							  image: NSImage(named: NSImage.Name("NSTouchBarGoUpTemplate"))!,
							  target: self, action: #selector(self.movePaneUp(_:)))
		touchbaritem.view = button
		return touchbaritem
	}()

	lazy var touchbarToggleItem: NSCustomTouchBarItem = {
		let touchbaritem = NSCustomTouchBarItem(identifier: DSFInspectorPanesPopoverTouchBar.toggleIdentifier)
		let button = NSButton(title: "<title>",
							  image: NSImage(named: NSImage.Name("NSTouchBarEnterFullScreenTemplate"))!,
							  target: self, action: #selector(self.togglePane(_:)))
		touchbaritem.view = button
		return touchbaritem
	}()

	var presentingItem: NSPopoverTouchBarItem?

	@objc func dismiss(_ sender: Any?) {
		guard let popover = presentingItem else { return }
		popover.dismissPopover(sender)
	}

	convenience init(inspectorView: DSFInspectorPanesAction, presentingItem: NSPopoverTouchBarItem? = nil) {
		self.init()
		self.inspectorPanesView = inspectorView
		self.delegate = self
		self.presentingItem = presentingItem
		self.defaultItemIdentifiers = [
			DSFInspectorPanesPopoverTouchBar.moveUpIdentifier,
			DSFInspectorPanesPopoverTouchBar.moveDownIdentifier,
			DSFInspectorPanesPopoverTouchBar.toggleIdentifier
		]
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		if identifier == DSFInspectorPanesPopoverTouchBar.moveDownIdentifier {
			return self.touchbarMoveDownItem
		}
		else if identifier == DSFInspectorPanesPopoverTouchBar.moveUpIdentifier {
			return self.touchbarMoveUpItem
		}
		else if identifier == DSFInspectorPanesPopoverTouchBar.toggleIdentifier {
			return self.touchbarToggleItem
		}
		return nil
	}

	@objc public func movePaneUp(_: Any?) {
		self.inspectorPanesView?.moveUp()
	}

	@objc public func movePaneDown(_: Any?) {
		self.inspectorPanesView?.moveDown()
	}

	@objc public func togglePane(_: Any?) {
		self.inspectorPanesView?.toggleVisibility()
	}
}
