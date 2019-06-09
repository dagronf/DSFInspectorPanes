//
//  DSFInspectorPaneView.swift
//  DSFInspectorPanes
//
//  Created by Darren Ford on 9/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

internal class DSFInspectorPaneView: NSView {
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
	internal let inspectorViewContainerView = NSView()
	// The actual property view being displayed
	private var inspectorView: NSView?

	// If a separator was automatically added, the separator view
	internal var associatedSeparator: NSBox?

	internal var titleFont: NSFont? {
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

		self.inspectorViewContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.inspectorViewContainerView.wantsLayer = true

		self.inspectorViewContainerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.inspectorViewContainerView.setContentHuggingPriority(.required, for: .vertical)

		self.mainStack.addArrangedSubview(self.inspectorViewContainerView)

		updateConstraintsForSubtreeIfNeeded()
	}

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

		self.panelHeight = NSMinY(bounds) - NSMinY(self.headerView.frame)
		self.heightConstraint = NSLayoutConstraint(
			item: self.inspectorViewContainerView,
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
		if animated {
			NSAnimationContext.runAnimationGroup({ context in
				context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
				context.duration = animSpeed()
				self.inspectorViewContainerView.animator().alphaValue = 1.0
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
		self.inspectorViewContainerView.alphaValue = 1.0
		self.inspectorViewContainerView.isHidden = false
		self.inspectorViewContainerView.removeConstraint(self.heightConstraint)
		self.inspectorViewContainerView.addConstraint(self.panelBottom)
		self.headerAccessoryViewContainer.isHidden = true
		self.window?.recalculateKeyViewLoop()
		self.superview?.needsLayout = true
		self.needsUpdateConstraints = true
		self.needsLayout = true
	}

	// MARK: Close Pane

	private func closePane(animated: Bool) {
		// close an open panel
		self.panelHeight = self.inspectorView!.frame.height
		self.heightConstraint.constant = self.panelHeight

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
		self.inspectorViewContainerView.isHidden = true
		self.headerAccessoryViewContainer.isHidden = false
		self.inspectorViewContainerView.alphaValue = 0.0
		self.mainStack.needsUpdateConstraints = true
		self.mainStack.needsLayout = true
		self.superview?.needsLayout = true
		self.needsLayout = true
		self.needsUpdateConstraints = true
		self.window?.recalculateKeyViewLoop()
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
		get {
			return self.inspectorView
		}
	}

	var header: NSView? {
		get {
			let headerContainer = self.headerAccessoryViewContainer
			if headerContainer.subviews.count == 1 {
				return headerContainer.subviews[0]
			}
			return nil
		}
	}

	var expanded: Bool {
		get {
			let state = self.disclosureButton?.state ?? .on
			return state == .off
		}
		set {
			self.openDisclosure(open: newValue, animated: self.animated)
		}
	}

	func setExpanded(_ expanded: Bool, animated: Bool ) {
		self.openDisclosure(open: expanded, animated: animated)
	}

	var hide: Bool {
		get {
			return self.isHidden
		}
		set {
			self.isHidden = newValue
			self.associatedSeparator?.isHidden = newValue
		}
	}
}
