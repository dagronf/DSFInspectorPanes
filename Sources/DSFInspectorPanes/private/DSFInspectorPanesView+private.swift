//
//  DSFInspectorPanesView+private2.swift
//  DSFInspectorPanes
//
//  Created by Darren Ford on 23/7/19.
//  Copyright © 2020 Darren Ford. All rights reserved.
//

import Cocoa

internal protocol DSFInspectorPanesAction {
	func moveUp()
	func moveDown()
	func toggleVisibility()
}

// MARK: Menu handling, key bindings

extension DSFInspectorPanesView: NSUserInterfaceValidations {
	internal func focussedPane() -> (index: Int, pane: DSFInspectorPanesView.Pane)? {
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
			menuItem.state = hasFocus.pane.isExpanded ? .on : .off
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
		self.inspectorPaneDelegate?.inspectorPanes?(self, didChangeVisibilityOf: pane)
	}
}

