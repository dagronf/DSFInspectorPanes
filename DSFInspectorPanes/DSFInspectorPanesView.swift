//
//  DSFInspectorPanesView.swift
//
//  Created by Darren Ford on 30/4/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

@IBDesignable
@objc public class DSFInspectorPanesView: NSView {
	private class StackView: NSStackView {
		override var isFlipped: Bool {
			return true
		}
	}

	/// Should we animated hiding and showing?
	@IBInspectable var animated: Bool = true

	/// Should (when created) that the property panes should exist within a scroll view?
	@IBInspectable var usesScrollView: Bool = true

	/// Edge insets from the view to inset the panes
	@objc public var insets: NSEdgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
		didSet {
			self.stackView.edgeInsets = self.insets
			self.stackView.needsLayout = true
		}
	}

	//! The font to use in the title for all property panes
	@objc public var titleFont: NSFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize) {
		didSet {
			for stackItem in self.stackView.arrangedSubviews {
				if let item = stackItem as? StackItemView {
					item.titleTextView!.font = self.titleFont
					item.needsLayout = true
				}
			}
			self.needsLayout = true
		}
	}

	/// Vertical spacing between panes
	@objc public var spacing: CGFloat = 8 {
		didSet {
			self.stackView.spacing = self.spacing
			self.stackView.needsLayout = true
		}
	}

	private var scrollView: NSScrollView?
	private let stackView = StackView()

	init(frame frameRect: NSRect,
	     animated: Bool = true,
	     usesScrollView: Bool = true,
	     font: NSFont?) {
		self.animated = animated
		self.usesScrollView = usesScrollView
		if let font = font {
			self.titleFont = font
		}
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}

	public override func awakeFromNib() {
		// Only called with initWithCoder is called. Setup here because the inspectables aren't
		// available until awakeFromNib is called
		super.awakeFromNib()
		self.setup()
	}

	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.setContentCompressionResistancePriority(.required, for: .vertical)
		self.setContentHuggingPriority(.required, for: .vertical)

		if self.usesScrollView {
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

		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.orientation = .vertical
		self.stackView.alignment = .left
		self.stackView.distribution = .fillProportionally
		self.stackView.spacing = self.spacing
		self.stackView.detachesHiddenViews = true
		self.stackView.edgeInsets = self.insets
		self.stackView.setContentHuggingPriority(.required, for: .vertical)
		self.stackView.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		self.stackView.setContentCompressionResistancePriority(.required, for: .vertical)

		if self.usesScrollView, let sv = self.scrollView {
			sv.documentView = self.stackView
			let variableBindings2 = ["_documentView": self.stackView] as [String: Any]
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
			addSubview(self.stackView)
			let variableBindings2 = ["_stack": self.stackView] as [String: Any]
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

			self.stackView.setClippingResistancePriority(.required, for: .vertical)
			self.stackView.setHuggingPriority(.required, for: .vertical)
			self.superview?.setContentHuggingPriority(.required, for: .vertical)
		}
	}

	@objc public func add(
		title: String,
		view: NSView,
		headerAccessoryView: NSView? = nil,
		canHide: Bool = true,
		expanded: Bool = true
	) {
		let disclosureView = StackItemView(titleFont: self.titleFont, canHide: canHide, animated: self.animated)
		disclosureView.translatesAutoresizingMaskIntoConstraints = false
		disclosureView.add(propertyView: view, headerAccessoryView: headerAccessoryView)
		disclosureView.title = title
		self.stackView.addArrangedSubview(disclosureView) // addView(disclosureView, in: .top)

		let vScrollWidth = 12
		let metrics = ["vScrollWidth": vScrollWidth]
		let variableBindings = ["disclosureView": disclosureView] as [String: Any]
		stackView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-(vScrollWidth)-[disclosureView]-(vScrollWidth)-|",
			options: .alignAllLastBaseline,
			metrics: metrics as [String: NSNumber],
			views: variableBindings
		))

		let box = NSBox(frame: NSRect(x: 0, y: 0, width: 20, height: 1))
		box.boxType = .separator
		box.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.addArrangedSubview(box) // (box, in: .top)

		if !expanded {
			disclosureView.openDisclosure(open: false, animated: false)
		}

		view.needsUpdateConstraints = true
		view.needsLayout = true
		disclosureView.needsUpdateConstraints = true
		self.stackView.needsUpdateConstraints = true
		window?.recalculateKeyViewLoop()
	}
}

private extension DSFInspectorPanesView {
	class StackItemView: NSView {
		// Is the item animated?
		let animated: Bool

		// The primary stack, containing header and property pane
		private var mainStack = NSStackView()

		// Header view
		private var headerView = NSStackView()
		// Disclosure button
		private var disclosureButton: NSButton?
		// Title for the pane
		fileprivate var titleTextView: NSTextField?
		// The container holding the header accessory view
		private let headerAccessoryViewContainer = NSView()

		// Property view container
		internal let propertyViewContainerView = NSView()
		// The actual property view being displayed
		private var propertyView: NSView?

		// Constraint from the pane to the bottom of the property view
		// We want to remove and add this as the panel is opened/closed
		var panelBottom: NSLayoutConstraint!

		var panelHeight: CGFloat = 0
		var heightConstraint: NSLayoutConstraint!

		override var isFlipped: Bool {
			return true
		}

		public var title: String = "<property>" {
			didSet {
				self.titleTextView?.stringValue = self.title
			}
		}

		internal init(titleFont: NSFont, canHide: Bool, animated: Bool) {
			self.animated = animated
			super.init(frame: .zero)
			translatesAutoresizingMaskIntoConstraints = false
			self.setup(titleFont: titleFont, canHide: canHide, animated: animated)
		}

		required init?(coder _: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		private func setup(titleFont: NSFont, canHide: Bool, animated _: Bool) {
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
			self.mainStack.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			addSubview(self.mainStack)

			self.mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			self.mainStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
			self.mainStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			self.mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

			self.mainStack.setHuggingPriority(.defaultLow, for: .horizontal)
			self.mainStack.setHuggingPriority(.required, for: .vertical)
			self.mainStack.setContentCompressionResistancePriority(.required, for: .vertical)

			self.mainStack.setClippingResistancePriority(.required, for: .vertical)
			self.mainStack.setHuggingPriority(.required, for: .vertical)

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

			let title = DSFInspectorPanesView.CreateTitleField()
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
			title.setContentHuggingPriority(.defaultLow, for: .vertical)

			self.titleTextView = title

			if canHide {
				let gesture = NSClickGestureRecognizer()
				gesture.buttonMask = 0x1 // left mouse
				gesture.numberOfClicksRequired = 1
				gesture.target = self
				gesture.action = #selector(self.toggleDisclosure(sender:))
				title.addGestureRecognizer(gesture)
			}

			// Dummy spacer to make sure the accessory view appears on the right
			let spacer = NSView()
			spacer.translatesAutoresizingMaskIntoConstraints = false
			spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

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
			self.headerView.setHuggingPriority(.defaultHigh, for: .vertical)
			self.headerView.addArrangedSubview(self.headerAccessoryViewContainer)
			self.headerAccessoryViewContainer.isHidden = true
			self.mainStack.addArrangedSubview(self.headerView)
			//////

			self.propertyViewContainerView.translatesAutoresizingMaskIntoConstraints = false
			self.propertyViewContainerView.wantsLayer = true

			self.propertyViewContainerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			self.propertyViewContainerView.setContentHuggingPriority(.required, for: .vertical)

			self.mainStack.addArrangedSubview(self.propertyViewContainerView)

			updateConstraintsForSubtreeIfNeeded()
		}

		/// Set the view (and header accessory) for the container
		internal func add(propertyView: NSView, headerAccessoryView: NSView? = nil) {
			self.propertyView = propertyView

			self.propertyViewContainerView.subviews.forEach { $0.removeFromSuperview() }

			propertyView.wantsLayer = true
			propertyView.translatesAutoresizingMaskIntoConstraints = false
			propertyView.setContentHuggingPriority(.required, for: .vertical)

			self.disclosureButton!.state = .on
			self.propertyViewContainerView.addSubview(propertyView)

			let variableBindings = ["panelView": propertyView] as [String: Any]

			// add horizontal constraints
			propertyViewContainerView.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[panelView]|",
				options: .alignAllLastBaseline,
				metrics: nil,
				views: variableBindings
			))

			self.propertyViewContainerView.addConstraint(
				NSLayoutConstraint(
					item: propertyView,
					attribute: .top,
					relatedBy: .equal,
					toItem: self.propertyViewContainerView,
					attribute: .top,
					multiplier: 1,
					constant: 0
				)
			)

			self.panelBottom = NSLayoutConstraint(
				item: propertyView,
				attribute: .bottom,
				relatedBy: .equal,
				toItem: self.propertyViewContainerView,
				attribute: .bottom,
				multiplier: 1,
				constant: 0
			)

			self.propertyViewContainerView.addConstraint(self.panelBottom)
			self.propertyViewContainerView.needsLayout = true

			self.propertyViewContainerView.setContentCompressionResistancePriority(.required, for: .vertical)
			self.propertyViewContainerView.setContentHuggingPriority(.required, for: .vertical)

			self.panelHeight = NSMinY(bounds) - NSMinY(self.headerView.frame)
			self.heightConstraint = NSLayoutConstraint(
				item: self.propertyViewContainerView,
				attribute: .height,
				relatedBy: .equal,
				toItem: nil,
				attribute: .notAnAttribute,
				multiplier: 1,
				constant: self.panelHeight
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

		@objc func toggleDisclosure(sender: AnyObject) {
			// called when the disclosure button is pressed
			if let disclosure = sender as? NSButton {
				self.openDisclosure(open: disclosure.state == .on, animated: self.animated)
			} else if let disclosure = self.disclosureButton {
				self.disclosureButton?.state = disclosure.state == .on ? .off : .on
				self.openDisclosure(open: disclosure.state == .on, animated: self.animated)
			}
		}

		private func animSpeed() -> TimeInterval {
			if let flags = NSApp.currentEvent?.modifierFlags, flags.contains(NSEvent.ModifierFlags.option) {
				return 2.0
			}
			return 0.1
		}

		// MARK: - Open and close

		func openDisclosure(open: Bool, animated: Bool) {
			self.disclosureButton!.state = open ? .on : .off
			if open == true {
				self.openPane(animated: animated)
			} else {
				self.closePane(animated: animated)
			}
		}

		// MARK: Open Pane

		private func openPane(animated: Bool) {
			self.propertyViewContainerView.isHidden = false
			if animated {
				NSAnimationContext.runAnimationGroup({ context in
					context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
					context.duration = animSpeed()
					self.propertyViewContainerView.animator().alphaValue = 1.0
					self.headerAccessoryViewContainer.animator().alphaValue = 0.0
					self.heightConstraint.animator().constant = self.panelHeight
				}, completionHandler: {
					self.openPanelComplete()
				})
			} else {
				self.openPanelComplete()
			}
		}

		private func openPanelComplete() {
			self.propertyViewContainerView.alphaValue = 1.0
			self.propertyViewContainerView.isHidden = false
			self.propertyViewContainerView.addConstraint(self.panelBottom)
			self.headerAccessoryViewContainer.isHidden = true
			self.window?.recalculateKeyViewLoop()
			self.superview?.needsLayout = true
			self.needsUpdateConstraints = true
			self.needsLayout = true
		}

		// MARK: Close Pane

		private func closePane(animated: Bool) {
			// close an open panel
			self.panelHeight = self.propertyView!.frame.height
			self.heightConstraint.constant = self.panelHeight

			self.propertyViewContainerView.addConstraint(self.heightConstraint)
			self.propertyViewContainerView.removeConstraint(self.panelBottom)
			self.propertyViewContainerView.needsLayout = true
			if animated {
				NSAnimationContext.runAnimationGroup({ context in
					context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
					context.duration = animSpeed()
					self.headerAccessoryViewContainer.isHidden = false
					self.heightConstraint.animator().constant = 0
					self.propertyViewContainerView.animator().alphaValue = 0.0
					self.headerAccessoryViewContainer.animator().alphaValue = 1.0
				}, completionHandler: {
					self.closePanelComplete()
				})
			} else {
				self.closePanelComplete()
			}
		}

		private func closePanelComplete() {
			self.propertyViewContainerView.isHidden = true
			self.headerAccessoryViewContainer.isHidden = false
			self.propertyViewContainerView.alphaValue = 0.0
			self.mainStack.needsUpdateConstraints = true
			self.mainStack.needsLayout = true
			self.superview?.needsLayout = true
			self.needsLayout = true
			self.needsUpdateConstraints = true
			self.window?.recalculateKeyViewLoop()
		}
	}
}

extension DSFInspectorPanesView {

	static func CreateTitleField() -> NSTextField {
		let title = NSTextField()
		title.cell = RSVerticallyCenteredTextFieldCell()
		return title
	}

	/// Vertically centering text field
	class RSVerticallyCenteredTextFieldCell: NSTextFieldCell {
		var mIsEditingOrSelecting: Bool = false

		override func drawingRect(forBounds theRect: NSRect) -> NSRect {
			// Get the parent's idea of where we should draw
			var newRect: NSRect = super.drawingRect(forBounds: theRect)

			// When the text field is being edited or selected, we have to turn off the magic because it screws up
			// the configuration of the field editor.  We sneak around this by intercepting selectWithFrame and editWithFrame and sneaking a
			// reduced, centered rect in at the last minute.

			if !self.mIsEditingOrSelecting {
				// Get our ideal size for current text
				let textSize: NSSize = self.cellSize(forBounds: theRect)

				// Center in the proposed rect
				let heightDelta: CGFloat = newRect.size.height - textSize.height
				if heightDelta > 0 {
					newRect.size.height -= heightDelta
					newRect.origin.y += heightDelta / 2
				}
			}

			return newRect
		}

		override func select(
			withFrame rect: NSRect,
			in controlView: NSView,
			editor textObj: NSText,
			delegate: Any?,
			start selStart: Int,
			length selLength: Int
		) {
			let arect = self.drawingRect(forBounds: rect)
			self.mIsEditingOrSelecting = true
			super.select(withFrame: arect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
			self.mIsEditingOrSelecting = false
		}

		override func edit(
			withFrame rect: NSRect,
			in controlView: NSView,
			editor textObj: NSText,
			delegate: Any?,
			event: NSEvent?
		) {
			let aRect = self.drawingRect(forBounds: rect)
			self.mIsEditingOrSelecting = true
			super.edit(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, event: event)
			self.mIsEditingOrSelecting = false
		}
	}
}
