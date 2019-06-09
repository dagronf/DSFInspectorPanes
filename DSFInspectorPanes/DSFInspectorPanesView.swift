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

import Cocoa

@IBDesignable
@objc public class DSFInspectorPanesView: NSView {
	/// Should we animate hiding and showing?
	@IBInspectable private(set) var animated: Bool = true

	/// Should (when added) property panes be added to an embedded scrollable view?
	@IBInspectable private(set) var embeddedInScrollView: Bool = true

	/// Should there be separators between the inspector panes?
	@IBInspectable private(set) var showSeparators: Bool = true

	/// Edge insets from the view to inset the panes
	@objc public var insets: NSEdgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
		didSet {
			self.stackView.edgeInsets = self.insets
			self.stackView.needsLayout = true
		}
	}

	//! The font to use in the title for all property panes
	@IBInspectable public var titleFont: NSFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize) {
		didSet {
			self.arrangedInspectorPanes.forEach { $0.titleFont = self.titleFont }
			self.needsLayout = true
		}
	}

	/// Vertical spacing between panes
	@IBInspectable public var spacing: CGFloat = 8 {
		didSet {
			self.stackView.spacing = self.spacing
			self.stackView.needsLayout = true
		}
	}

	/// Return an array containing all the inspector panes
	@objc public var panes: [DSFInspectorPaneProtocol] {
		return self.arrangedInspectorPanes as [DSFInspectorPaneProtocol]
	}

	private var scrollView: NSScrollView?
	private let stackView = FlippedStackView()

	@objc public init(frame frameRect: NSRect,
					  animated: Bool = true,
					  embeddedInScrollView: Bool = true,
					  showSeparators: Bool = true,
					  titleFont: NSFont? = nil) {
		self.animated = animated
		self.embeddedInScrollView = embeddedInScrollView
		self.showSeparators = showSeparators
		if let font = titleFont {
			self.titleFont = font
		}
		super.init(frame: frameRect)
		self.setup()
	}

	@objc required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}

	@objc public func add(
		title: String,
		view: NSView,
		headerAccessoryView: NSView? = nil,
		canHide: Bool = true,
		expanded: Bool = true
		) {
		if self.showSeparators && self.arrangedInspectorPanes.count > 0 {
			// If there is a previous pane in place, add in a separator
			let box = NSBox(frame: NSRect(x: 0, y: 0, width: 20, height: 1))
			box.boxType = .separator
			box.translatesAutoresizingMaskIntoConstraints = false
			self.stackView.addArrangedSubview(box) // (box, in: .top)
			self.stackView.addConstraints(
				NSLayoutConstraint.constraints(
					withVisualFormat: "H:|-12-[box]-12-|",
					options: NSLayoutConstraint.FormatOptions(rawValue: 0),
					metrics: nil,
					views: ["box": box]
				)
			)
			self.arrangedInspectorPanes.last?.associatedSeparator = box
		}

		let disclosureView = DSFInspectorPaneView(titleFont: self.titleFont, canHide: canHide, animated: self.animated)
		disclosureView.translatesAutoresizingMaskIntoConstraints = false
		disclosureView.add(propertyView: view, headerAccessoryView: headerAccessoryView)
		disclosureView.title = title
		self.stackView.addArrangedSubview(disclosureView)

		let vScrollWidth = 12
		let metrics = ["vScrollWidth": vScrollWidth]
		let variableBindings = ["disclosureView": disclosureView] as [String: Any]
		stackView.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-(vScrollWidth)-[disclosureView]-(vScrollWidth)-|",
			options: .alignAllLastBaseline,
			metrics: metrics as [String: NSNumber],
			views: variableBindings
		))

		if canHide, !expanded {
			disclosureView.openDisclosure(open: false, animated: false)
		}

		view.needsUpdateConstraints = true
		view.needsLayout = true
		self.stackView.needsLayout = true
		disclosureView.needsUpdateConstraints = true
		self.stackView.needsUpdateConstraints = true
		window?.recalculateKeyViewLoop()
	}

	/// Convenience method for showing or hiding all of the inspector panes at once
	@objc public func expandAll(_ expanded: Bool, animated: Bool) {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(expanded, animated: animated) }
	}
}

// MARK: - Configuration

extension DSFInspectorPanesView {
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

		if self.embeddedInScrollView, let sv = self.scrollView {
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

	/// Return the contained inspector panes
	private var arrangedInspectorPanes: [DSFInspectorPaneView] {
		let panes = self.stackView.arrangedSubviews.filter { $0 is DSFInspectorPaneView }
		return panes as? [DSFInspectorPaneView] ?? []
	}
}
