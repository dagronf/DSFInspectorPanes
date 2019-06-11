//
//  DSFInspectorPaneView.swift
//
//  Created by Darren Ford on 9/6/19.
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

/// Custom box class to handle the different inspector pane drawing types (box, separator)
internal class DSFInspectorBox: NSBox {
	var inspectorType: DSFInspectorPanesView.InspectorType = .none
	var separatorVisible: Bool = true

	override func draw(_ dirtyRect: NSRect) {
		if inspectorType == .separator {
			if separatorVisible {
				let line = NSBezierPath()
				line.move(to: CGPoint(x: 4, y: 0))
				line.line(to: CGPoint(x: self.bounds.width - 4, y: 0))
				NSColor.quaternaryLabelColor.setStroke()
				line.lineWidth = 2.0
				line.stroke()
			}
		}
		else if inspectorType == .box {
			super.draw(dirtyRect)
		}
		else {
			// Draw nothing
		}
	}
}

@objc internal protocol DSFInspectorPaneViewDelegate {
	@objc optional func inspectorView(_ inspectorView: DSFInspectorPaneView, didChangeVisibility: DSFInspectorPaneView)
}

internal class DSFInspectorPaneView: DSFInspectorBox {
	// Is the item animated?
	private let animated: Bool

	// The primary stack, containing header and property pane
	private var mainStack = NSStackView()

	// Header view
	private var headerView = NSStackView()
	// Disclosure button
	private var disclosureButton: NSButton?
	// Title for the pane
	private var titleTextView: NSTextField?
	// The container holding the header accessory view
	private let headerAccessoryViewContainer = NSView()

	// Property view container
	internal let inspectorViewContainerView = NSView()
	// The actual property view being displayed
	private var inspectorView: NSView?

	var changeDelegate: DSFInspectorPaneViewDelegate?

	// Can the pane be contracted/expanded
	var canExpand: Bool {
		return !(self.disclosureButton?.isHidden ?? true)
	}

	// If a separator was automatically added, the separator view
	// internal var associatedSeparator: NSBox?

	internal var headerFont: NSFont? {
		get {
			return self.titleTextView?.font
		}
		set {
			self.titleTextView?.font = newValue
			self.needsLayout = true
		}
	}

	// Constraint from the pane to the bottom of the property view
	// We want to remove and add this as the panel is opened/closed
	var panelBottom: NSLayoutConstraint!
	var heightConstraint: NSLayoutConstraint!

	override var isFlipped: Bool {
		return true
	}

	override var title: String {
		didSet {
			self.titleTextView?.stringValue = self.title
			self.setAccessibilityLabel("\(self.title) pane")
		}
	}

	internal init(titleFont: NSFont, canHide: Bool, canReorder: Bool, inspectorType: DSFInspectorPanesView.InspectorType, animated: Bool) {
		self.animated = animated
		super.init(frame: .zero)
		self.inspectorType = inspectorType
		translatesAutoresizingMaskIntoConstraints = false
		self.setup(titleFont: titleFont, canHide: canHide, canReorder: canReorder)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup(titleFont: NSFont, canHide: Bool, canReorder: Bool) {
		guard let content = self.contentView else {
			return
		}

		self.translatesAutoresizingMaskIntoConstraints = false
		self.titlePosition = .noTitle

		self.headerAccessoryViewContainer.translatesAutoresizingMaskIntoConstraints = false
		self.headerAccessoryViewContainer.setContentHuggingPriority(.required, for: .vertical)

		self.mainStack.translatesAutoresizingMaskIntoConstraints = false
		self.mainStack.frame = frame
		self.mainStack.orientation = .vertical
		self.mainStack.alignment = .left
		self.mainStack.distribution = .fillProportionally
		self.mainStack.spacing = 8
		self.mainStack.detachesHiddenViews = true
		self.mainStack.setContentHuggingPriority(.required, for: .vertical)
		self.mainStack.setHuggingPriority(.required, for: .vertical)
		self.mainStack.edgeInsets = .zero

		self.addSubview(self.mainStack)

		self.mainStack.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
		self.mainStack.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
		self.mainStack.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
		self.mainStack.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true

		self.mainStack.setHuggingPriority(.defaultLow, for: .horizontal)
		self.mainStack.setHuggingPriority(.required, for: .vertical)
		self.mainStack.setContentCompressionResistancePriority(.required, for: .vertical)

		self.mainStack.setClippingResistancePriority(.required, for: .vertical)
		self.mainStack.setHuggingPriority(.required, for: .vertical)

		self.mainStack.setContentHuggingPriority(.required, for: .vertical)

		setContentHuggingPriority(.required, for: .vertical)
		setContentCompressionResistancePriority(.required, for: .vertical)

		//////
		let disclosure = NSButton()
		disclosure.translatesAutoresizingMaskIntoConstraints = false
		disclosure.bezelStyle = .disclosure
		disclosure.title = ""
		disclosure.setButtonType(.onOff)
		disclosure.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		disclosure.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		disclosure.target = self
		disclosure.action = #selector(self.toggleDisclosure(sender:))
		disclosure.isHidden = !canHide
		disclosure.controlSize = .mini

		disclosure.wantsLayer = true
		disclosure.layer!.backgroundColor = CGColor.clear

		self.disclosureButton = disclosure

		let title = CreateInspectorTitleField()
		title.font = titleFont
		title.stringValue = "Dummy Value"
		title.allowsDefaultTighteningForTruncation = true
		title.usesSingleLineMode = true
		title.cell?.truncatesLastVisibleLine = true
		title.cell?.lineBreakMode = .byTruncatingHead
		title.isEditable = false
		title.isBordered = false
		title.drawsBackground = false
		title.translatesAutoresizingMaskIntoConstraints = false

		title.setContentCompressionResistancePriority(.required, for: .horizontal)
		title.setContentCompressionResistancePriority(.required, for: .vertical)
		title.setContentHuggingPriority(.defaultLow, for: .horizontal)
		title.setContentHuggingPriority(.defaultHigh, for: .vertical)
		title.addGestureRecognizer(self.expandContractGestureRecognizer())

		self.titleTextView = title

		// Dummy spacer to make sure the accessory view appears on the right
		let spacer = NSView()
		spacer.translatesAutoresizingMaskIntoConstraints = false
		spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
		spacer.addGestureRecognizer(self.expandContractGestureRecognizer())

		self.headerView.wantsLayer = true
		self.headerView.translatesAutoresizingMaskIntoConstraints = false
		self.headerView.distribution = .fillProportionally
		self.headerView.spacing = 4
		self.headerView.detachesHiddenViews = false
		self.headerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.headerView.orientation = .horizontal
		self.headerView.alignment = .centerY
		if canHide {
			self.headerView.addArrangedSubview(disclosure)
		}
		self.headerView.addArrangedSubview(title)
		self.headerView.addArrangedSubview(spacer)
		self.headerView.setHuggingPriority(.required, for: .vertical)
		self.headerView.setContentHuggingPriority(.required, for: .vertical)
		self.headerView.addArrangedSubview(self.headerAccessoryViewContainer)

		if canReorder {
			self.headerView.addArrangedSubview(self.dragImageView)
		}

		self.headerAccessoryViewContainer.isHidden = true
		self.mainStack.addArrangedSubview(self.headerView)
		//////

		self.inspectorViewContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.inspectorViewContainerView.wantsLayer = true

		self.inspectorViewContainerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.inspectorViewContainerView.setContentHuggingPriority(.required, for: .vertical)

		self.mainStack.addArrangedSubview(self.inspectorViewContainerView)

		updateConstraintsForSubtreeIfNeeded()
	}

	private lazy var dragImageView: NSImageView = {
		let image = NSImage(named: NSImage.Name("NSListViewTemplate"))!
		image.isTemplate = true
		let imageview = NSImageView(frame: .zero)
		imageview.translatesAutoresizingMaskIntoConstraints = true
		imageview.image = image
		imageview.imageAlignment = .alignCenter
		imageview.imageScaling = .scaleNone
		let c = NSLayoutConstraint(item: imageview, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
		c.priority = .required
		imageview.addConstraint(c)
		imageview.toolTip = NSLocalizedString("Drag to re-order panes", comment: "")
		return imageview
	}()

	/// Set the view (and header accessory) for the container
	internal func add(propertyView: NSView, headerAccessoryView: NSView? = nil) {
		self.inspectorView = propertyView

		self.inspectorViewContainerView.subviews.forEach { $0.removeFromSuperview() }

		propertyView.wantsLayer = true
		propertyView.translatesAutoresizingMaskIntoConstraints = false
		propertyView.setContentHuggingPriority(.required, for: .vertical)

		self.disclosureButton!.state = .on
		self.inspectorViewContainerView.addSubview(propertyView)

		let variableBindings = ["panelView": propertyView] as [String: Any]

		// add horizontal constraints
		inspectorViewContainerView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|[panelView]|",
			options: .alignAllLastBaseline,
			metrics: nil,
			views: variableBindings
		))

		self.inspectorViewContainerView.addConstraint(
			NSLayoutConstraint(
				item: propertyView,
				attribute: .top,
				relatedBy: .equal,
				toItem: self.inspectorViewContainerView,
				attribute: .top,
				multiplier: 1,
				constant: 0
			)
		)

		self.panelBottom = NSLayoutConstraint(
			item: propertyView,
			attribute: .bottom,
			relatedBy: .equal,
			toItem: self.inspectorViewContainerView,
			attribute: .bottom,
			multiplier: 1,
			constant: 0
		)

		self.inspectorViewContainerView.addConstraint(self.panelBottom)
		self.inspectorViewContainerView.needsLayout = true

		self.inspectorViewContainerView.setContentCompressionResistancePriority(.required, for: .vertical)
		self.inspectorViewContainerView.setContentHuggingPriority(.required, for: .vertical)

		self.heightConstraint = NSLayoutConstraint(
			item: self.inspectorViewContainerView,
			attribute: .height,
			relatedBy: .equal,
			toItem: nil,
			attribute: .notAnAttribute,
			multiplier: 1,
			constant: bounds.minY - self.headerView.frame.minY
		)

		self.headerAccessoryViewContainer.subviews.forEach { $0.removeFromSuperview() }
		if let hav = headerAccessoryView {
			hav.translatesAutoresizingMaskIntoConstraints = false
			hav.setContentHuggingPriority(.required, for: .vertical)
			hav.setContentCompressionResistancePriority(.required, for: .vertical)

			self.headerAccessoryViewContainer.addSubview(hav)
			// add horizontal constraints
			let variableBindings = ["panelView": hav] as [String: Any]
			headerAccessoryViewContainer.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[panelView]|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings
			))
			self.headerAccessoryViewContainer.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[panelView]|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings
			))
		}

		setContentHuggingPriority(.required, for: .vertical)

		self.needsUpdateConstraints = true
	}
}

// MARK: - Open and close

extension DSFInspectorPaneView {

	private func animSpeed() -> TimeInterval {
		if let flags = NSApp.currentEvent?.modifierFlags, flags.contains(NSEvent.ModifierFlags.option) {
			return 2.0
		}
		return 0.1
	}

	func openDisclosure(open: Bool, animated: Bool) {
		if self.disclosureButton!.isHidden {
			return
		}
		self.disclosureButton!.state = open ? .on : .off
		if open == true {
			self.openPane(animated: animated)
		} else {
			self.closePane(animated: animated)
		}
	}

	// MARK: Open Pane

	private func openPane(animated: Bool) {
		self.inspectorViewContainerView.isHidden = false

		// Get the height of the (hidden) view
		self.inspectorView?.layout()
		let inspectorHeight = self.inspectorView!.fittingSize.height

		if animated {
			NSAnimationContext.runAnimationGroup({ context in
				context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
				context.duration = animSpeed()
				self.inspectorViewContainerView.animator().alphaValue = 1.0
				self.headerAccessoryViewContainer.animator().alphaValue = 0.0
				self.heightConstraint.animator().constant = inspectorHeight
			}, completionHandler: {
				self.openPanelComplete()
			})
		} else {
			self.openPanelComplete()
		}
	}

	private func openPanelComplete() {
		self.setAccessibilityExpanded(true)
		self.inspectorViewContainerView.alphaValue = 1.0
		self.inspectorViewContainerView.isHidden = false
		self.inspectorViewContainerView.removeConstraint(self.heightConstraint)
		self.inspectorViewContainerView.addConstraint(self.panelBottom)
		self.headerAccessoryViewContainer.isHidden = true
		self.window?.recalculateKeyViewLoop()
		self.superview?.needsLayout = true
		self.needsUpdateConstraints = true
		self.needsLayout = true
		self.changeDelegate?.inspectorView?(self, didChangeVisibility: self)
	}

	// MARK: Close Pane

	private func closePane(animated: Bool) {
		// close an open panel
		self.heightConstraint.constant = self.inspectorView!.frame.height

		self.inspectorViewContainerView.addConstraint(self.heightConstraint)
		self.inspectorViewContainerView.removeConstraint(self.panelBottom)
		self.inspectorViewContainerView.needsLayout = true
		if animated {
			NSAnimationContext.runAnimationGroup({ context in
				context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
				context.duration = animSpeed()
				self.headerAccessoryViewContainer.isHidden = false
				self.heightConstraint.animator().constant = 0
				self.inspectorViewContainerView.animator().alphaValue = 0.0
				self.headerAccessoryViewContainer.animator().alphaValue = 1.0
			}, completionHandler: {
				self.closePanelComplete()
			})
		} else {
			self.closePanelComplete()
		}
	}

	private func closePanelComplete() {
		self.setAccessibilityExpanded(false)
		self.inspectorViewContainerView.isHidden = true
		self.headerAccessoryViewContainer.isHidden = false
		self.inspectorViewContainerView.alphaValue = 0.0
		self.mainStack.needsUpdateConstraints = true
		self.mainStack.needsLayout = true
		self.superview?.needsLayout = true
		self.needsLayout = true
		self.needsUpdateConstraints = true
		self.window?.recalculateKeyViewLoop()
		self.changeDelegate?.inspectorView?(self, didChangeVisibility: self)
	}
}

// MARK: Interaction

extension DSFInspectorPaneView {
	override var acceptsFirstResponder: Bool {
		return true
	}

	override func drawFocusRingMask() {
		var rect = self.bounds
		rect.origin.y += 1
		rect.size.height -= 4
		rect.origin.x += 2
		rect.size.width -= 4
		let path = NSBezierPath.init(roundedRect: rect, xRadius: 4, yRadius: 4)
		path.fill()
	}

	override var focusRingMaskBounds: NSRect {
		return self.bounds
	}

	override func keyDown(with event: NSEvent) {
		if event.keyCode == kVK_Space {
			self.toggleDisclosure(sender: self)
		}
		else {
			super.keyDown(with: event)
		}
	}

	@objc func headerClick(sender: AnyObject) {
		if self.canExpand && self.window?.firstResponder === self {
			// Only toggle the inspector IF the inspector is currently the first responder
			self.toggleDisclosure(sender: sender)
		}
		self.window?.makeFirstResponder(self)
	}

	@objc func toggleDisclosure(sender: AnyObject) {
		// called when the disclosure button is pressed
		if let disclosure = sender as? NSButton {
			self.openDisclosure(open: disclosure.state == .on, animated: self.animated)
		} else if let disclosure = self.disclosureButton {
			self.disclosureButton?.state = disclosure.state == .on ? .off : .on
			self.openDisclosure(open: disclosure.state == .on, animated: self.animated)
		}
	}

	private func expandContractGestureRecognizer() -> NSGestureRecognizer {
		let gesture = NSClickGestureRecognizer()
		gesture.buttonMask = 0x1 // left mouse
		gesture.numberOfClicksRequired = 1
		gesture.target = self
		gesture.action = #selector(self.headerClick(sender:))
		return gesture
	}
}

// MARK: - Conformance to public protocol

extension DSFInspectorPaneView: DSFInspectorPaneProtocol {
	var titleText: String {
		get {
			return self.title
		}
		set {
			self.title = newValue
		}
	}

	var inspector: NSView? {
		return self.inspectorView
	}

	var header: NSView? {
		let headerContainer = self.headerAccessoryViewContainer
		if headerContainer.subviews.count == 1 {
			return headerContainer.subviews[0]
		}
		return nil
	}

	var expanded: Bool {
		get {
			let state = self.disclosureButton?.state ?? .on
			return state == .on
		}
		set {
			self.openDisclosure(open: newValue, animated: self.animated)
		}
	}

	func setExpanded(_ expanded: Bool, animated: Bool) {
		self.openDisclosure(open: expanded, animated: animated)
	}

	var hide: Bool {
		get {
			return self.isHidden
		}
		set {
			self.isHidden = newValue
			//self.associatedSeparator?.isHidden = newValue
		}
	}
}
