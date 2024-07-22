//
//  DSFInspectorPanesView+private.swift
//
//  MIT License
//
//  Copyright (c) 2024 Darren Ford
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
		p.isExpanded = pane.isExpanded
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
