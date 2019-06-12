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
	@objc optional func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didReorder orderedPanes: [DSFInspectorPaneProtocol])
	@objc optional func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didExpandOrContract pane: DSFInspectorPaneProtocol)
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
	@IBInspectable private(set) var canDragRearrange: Bool = false

	/// The way the inspector is separated
	private(set) var inspectorType: InspectorType = .none

	/// Edge insets from the view to inset the panes
	@objc public var insets: NSEdgeInsets = NSEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) {
		didSet {
			self.primaryStack.edgeInsets = self.insets
			self.primaryStack.needsLayout = true
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
			self.primaryStack.spacing = self.spacing
			self.primaryStack.needsLayout = true
		}
	}

	/// Return an array containing all the inspector panes
	@objc public var panes: [DSFInspectorPaneProtocol] {
		return self.arrangedInspectorPanes as [DSFInspectorPaneProtocol]
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
		self.canDragRearrange = canDragRearrange

		if let font = titleFont {
			self.titleFont = font
		}
		super.init(frame: frameRect)
		self.setup()
	}

	@objc required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
}

// MARK: - Adding, moving, reordering

@objc public extension DSFInspectorPanesView {

	@discardableResult
	@objc func add(
		title: String,
		view: NSView,
		headerAccessoryView: NSView? = nil,
		canHide: Bool = true,
		expanded: Bool = true
	) -> DSFInspectorPaneProtocol {
		view.translatesAutoresizingMaskIntoConstraints = false

		let inspectorPaneView = DSFInspectorPanesView.Pane(titleFont: self.titleFont, canHide: canHide, canReorder: self.canDragRearrange, inspectorType: inspectorType, animated: self.animated)
		inspectorPaneView.changeDelegate = self
		inspectorPaneView.separatorVisible = self.arrangedInspectorPanes.count != 0
		inspectorPaneView.inspectorType = self.inspectorType
		inspectorPaneView.translatesAutoresizingMaskIntoConstraints = false
		inspectorPaneView.add(propertyView: view, headerAccessoryView: headerAccessoryView)
		inspectorPaneView.title = title
		self.primaryStack.addArrangedSubview(inspectorPaneView)

		// If we're embedded in a scroll view, give ourselves more horizontal gap to our border
		let vScrollWidth = self.embeddedInScrollView ? 12 : 4
		let metrics = ["vScrollWidth": vScrollWidth]
		let variableBindings = ["disclosureView": inspectorPaneView] as [String: Any]
		primaryStack.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-(vScrollWidth)-[disclosureView]-(vScrollWidth)-|",
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
		inspectorPaneView.needsUpdateConstraints = true
		self.primaryStack.needsUpdateConstraints = true
		window?.recalculateKeyViewLoop()
		return inspectorPaneView
	}

	/// Remove the inspector pane at the specified index
	@objc func remove(at index: Int) {
		assert(index < self.primaryStack.arrangedSubviews.count)

		let view = self.primaryStack.arrangedSubviews[index]
		self.primaryStack.removeArrangedSubview(view)
	}

	@objc func move(index: Int, to newIndex: Int) {
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

	@objc func swap(index: Int, with newIndex: Int) {
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
	@objc func expandAll(_ expanded: Bool, animated: Bool) {
		self.arrangedInspectorPanes.forEach { $0.setExpanded(expanded, animated: animated) }
	}
}

// MARK: Keyboard handling

@objc public extension DSFInspectorPanesView {
	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)

		if !self.canDragRearrange {
			return
		}

		if let flags = NSApp.currentEvent?.modifierFlags, flags.contains(NSEvent.ModifierFlags.option) {
			let focussed = self.window?.firstResponder
			let match = self.arrangedInspectorPanes
				.enumerated()
				.filter { focussed == $0.element }
				.first

			guard let found = match else {
				return
			}

			if event.keyCode == kVK_UpArrow {
				if found.offset != 0 {
					self.swap(index: found.offset, with: found.offset - 1)
					self.window?.makeFirstResponder(found.element)
					self.window?.recalculateKeyViewLoop()
				}
			}
			else if event.keyCode == kVK_DownArrow {
				if found.offset != self.arrangedInspectorPanes.count - 1 {
					self.swap(index: found.offset, with: found.offset + 1)
					self.window?.makeFirstResponder(found.element)
					self.window?.recalculateKeyViewLoop()
				}
			}
		}
	}
}

// MARK: - Initialization and setup

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

		// Hook ourselves up to receive drag events from the draggable stack
		self.primaryStack.canReorder = self.canDragRearrange
		self.primaryStack.dragDelegate = self

		if showSeparators == true {
			self.inspectorType = .separator
		}
		else if showBoxes == true {
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
}

// MARK: - Delegate callback handling

extension DSFInspectorPanesView: DraggingStackViewProtocol {
	func stackViewDidReorder() {
		for inspector in self.arrangedInspectorPanes.filter({ $0.inspectorType == .separator}).enumerated() {
			inspector.element.separatorVisible = inspector.offset != 0
			inspector.element.needsDisplay = true
		}
		self.window?.recalculateKeyViewLoop()
		self.inspectorPaneDelegate?.inspectorPanes?(self, didReorder: self.panes)
	}
}

extension DSFInspectorPanesView: DSFInspectorPaneViewDelegate {
	func inspectorPaneDidChangeVisibility(_ pane: DSFInspectorPanesView.Pane) {
		self.inspectorPaneDelegate?.inspectorPanes?(self, didExpandOrContract: pane)
	}
}
