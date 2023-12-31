//
//  DSFInspectorPanesView.swift
//
//  Created by Darren Ford on 30/4/19.
//
//  MIT License
//
//  Copyright (c) 2020 Darren Ford
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

#if os(macOS)

import Carbon.HIToolbox
import Cocoa

@objc public protocol DSFInspectorPanesViewProtocol {
	/// Called on the delegate when the ordering of panes in the view changes
	/// - Parameter inspectorPanes: The inspector panes view
	/// - Parameter orderedPanes: The updated ordering of panes within the view
	@objc optional func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didReorder orderedPanes: [DSFInspectorPane])

	/// Called on the delegate when a panes is expanded or contracted
	/// - Parameter inspectorPanes: The inspector panes view
	/// - Parameter pane: the pane that changed visibility
	@objc optional func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didChangeVisibilityOf pane: DSFInspectorPane)
}

@IBDesignable
@objc public class DSFInspectorPanesView: NSView {
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
	@objc var inspectorType: InspectorType = .none

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
	@IBInspectable public var spacing: CGFloat = 8 {
		didSet {
			self.primaryStack.spacing = self.spacing
			self.primaryStack.needsLayout = true
		}
	}

	/// Return an array containing all the inspector panes
	@objc public var panes: [DSFInspectorPane] {
		return self.arrangedInspectorPanes as [DSFInspectorPane]
	}

	/// If the panes view was created as embedded within a scrollview, the scrollview object
	internal var scrollView: NSScrollView?
	internal let primaryStack = FlippedStackView()

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

//	deinit {
//		debugPrint("deinit: DSFInspectorPanesView…")
//	}

	/// If the touchbar is available, the primary touchbar identifier
	@available(macOS 10.12.2, *)
	internal static let popoverIdentifier = NSTouchBarItem.Identifier("com.darrenford.inspectorpanes.popover")

	private var _popover: AnyObject?
	@available(macOS 10.12.2, *)
	internal var popover: DSFInspectorPanesPopoverTouchBar? {
		get {
			return self._popover as? DSFInspectorPanesPopoverTouchBar
		}
		set {
			self._popover = newValue
		}
	}
}

// MARK: - Initialization and setup

extension DSFInspectorPanesView {
	public override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	public override func prepareForInterfaceBuilder() {
		// Note that awakeFromNib is NOT called when dealing with prepareForInterfaceBuilder!
		// So we have to set it up for ourselves
		self.setup()

		let b1 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b1.title = "Default content"
		let b2 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b2.title = "Expanded content"
		let b3 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b3.title = "Content always visible"
		let b4 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b4.title = "Collapsed content (not visible)"
		let b5 = NSButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
		b5.title = "Visible content with no header"

		self.addPane(title: "Basic default", view: b1)
		self.addPane(title: "No Header", view: b5, showsHeader: false)
		self.addPane(title: "Expanded by default", view: b2)
		self.addPane(title: "No collapsing", view: b3, expansionType: .none)

		let bv = NSButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
		bv.title = ">🐶<"
		self.addPane(title: "Collapsed", view: b4, headerAccessoryView: bv, expansionType: .collapsed)

		self.layout()
	}
}

// MARK: - Adding, moving, reordering

@objc public extension DSFInspectorPanesView {
	/// Add a new pane to the inspector
	/// - Parameter title: The title to display in the pane header
	/// - Parameter view: The view to display in the pane
	/// - Parameter showsHeader: Does the inspector pane show the header?
	/// - Parameter headerAccessoryView: If the inspector uses a supporting header pane, the view for the header
	/// - Parameter headerAccessoryVisibility: When is the header accessory shown?
	/// - Parameter expansionType: Can the pane be expanded, and if so what is its default expansion state
	@discardableResult
	func addPane(
		title: String,
		view: NSView,
		showsHeader: Bool = true,
		headerAccessoryView: NSView? = nil,
		headerAccessoryVisibility: DSFInspectorPaneHeaderAccessoryVisibility = .onlyWhenCollapsed,
		expansionType: DSFInspectorPaneExpansionType = .expanded
	) -> DSFInspectorPane {
		return add_internal(
			title: title,
			view: view,
			showsHeader: showsHeader,
			headerAccessoryView: headerAccessoryView,
			headerAccessoryVisibility: headerAccessoryVisibility,
			expansionType: expansionType
		)
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
		view.removeFromSuperview()
	}

	/// Remove all of the panes from the view
	func removeAll() {
		self.arrangedInspectorPanes.forEach { $0.removeFromSuperview() }
		self.primaryStack.needsLayout = true
	}

	/// Move a pane from one index to another
	/// - Parameter index: the index of the pane to move
	/// - Parameter newIndex: the index to where the pane should move
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

	/// Swap the location of two panes
	/// - Parameter index: the first pane to swap
	/// - Parameter newIndex: the second pane to swap
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
}

@objc public extension DSFInspectorPanesView {
	/// Show or hide all of the inspector panes at once, optionally animating
	/// - Parameters:
	///   - expanded: If true, expands all panes. Otherwise all panes are hidden
	///   - animated: Should we animate the change?
	@objc func expandAll(_ expanded: Bool, animated: Bool) {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(expanded, animated: animated) }
	}

	/// Expand all the panes in the inspector
	@objc func expandAll() {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(true, animated: self.animated) }
	}

	/// Hide all the panes in the inspector
	@objc func hideAll() {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(false, animated: self.animated) }
	}

	/// Toggle the expansion state of all the panes in the inspector
	@objc func toggleAll() {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(!$0.isExpanded, animated: self.animated) }
	}
}

#endif
