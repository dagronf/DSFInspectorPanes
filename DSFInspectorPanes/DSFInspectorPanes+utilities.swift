//
//  DSFInspectorPanes+utilities.swift
//  DSFInspectorPanes
//
//  Created by Darren Ford on 9/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

/// An NSStackView that has flipped coordinates
internal class FlippedStackView: NSStackView {
	override var isFlipped: Bool {
		return true
	}
}

internal func CreateInspectorTitleField() -> NSTextField {
	let title = NSTextField()
	title.cell = RSVerticallyCenteredTextFieldCell()
	return title
}

// MARK: - Vertically centered text field

internal class RSVerticallyCenteredTextFieldCell: NSTextFieldCell {
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
