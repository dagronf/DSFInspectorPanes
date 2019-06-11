//
//  DSFInspectorPanes+utilities.swift
//
//  Created by Darren Ford on 9/6/19.
//
//  3rd party licenses
//
//  Makes use of RSVerticallyCenteredTextFieldCell
//  Red Sweater Software: http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes)
//  License - http://opensource.org/licenses/mit-license.php
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

/// An NSStackView that has flipped coordinates
internal class FlippedStackView: DraggingStackView {
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

/// Class for vertically centering text within an NSTextField
///
/// Adapted from Red Sweater Software, LLC for [RSVerticallyCenteredTextFieldCell](http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes) component
///
/// [License (MIT)](http://opensource.org/licenses/mit-license.php)
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

internal extension NSEdgeInsets {
	static var zero: NSEdgeInsets {
		return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
}

internal extension Array {
	mutating func move(from oldIndex: Index, to newIndex: Index) {
		if oldIndex == newIndex { return }
		if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
		self.insert(self.remove(at: oldIndex), at: newIndex)
	}
}

// MARK: - Draggable Stack View

internal protocol DraggingStackViewProtocol {
	func stackViewDidReorder()
}

/// Draggable Stack View class
///
/// Adapted from Mark Onyschuk on [GitHub](https://github.com/monyschuk) -- [Draggable Stack View](https://gist.github.com/monyschuk/cbca3582b6b996ab54c32e2d7eceaf25)
internal class DraggingStackView: NSStackView {

	/// Can the stack view be reordered
	var canReorder = true

	/// Delegate callback when the stackview finishes reordering
	var dragDelegate: DraggingStackViewProtocol?

	// MARK: -
	// MARK: Update Function
	var update: (NSStackView, [NSView]) -> Void = { stack, views in
		stack.views.forEach {
			//stack.removeView($0)
			stack.removeArrangedSubview($0)
		}

		views.forEach {
			//stack.addView($0, in: .leading)
			stack.addArrangedSubview($0)

//			switch stack.orientation {
//			case .horizontal:
//				$0.topAnchor.constraint(equalTo: stack.topAnchor).isActive = true
//				$0.bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
//
//			case .vertical:
//				$0.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
//				$0.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
//
//			default:
//				break
//			}
		}
	}


	// MARK: -
	// MARK: Event Handling
	override func mouseDragged(with event: NSEvent) {
		if canReorder {
			let location = convert(event.locationInWindow, from: nil)
			if let dragged = views.first(where: { $0.hitTest(location) != nil }) {
				reorder(view: dragged, event: event)
			}
		} else {
			super.mouseDragged(with: event)
		}
	}

	private func reorder(view: NSView, event: NSEvent) {
		guard let layer = self.layer else { return }
		guard let cached = try? self.cacheViews() else { return }

		let container = CALayer()
		container.frame = layer.bounds
		container.zPosition = 1
		container.backgroundColor = NSColor.underPageBackgroundColor.cgColor

		cached
			.filter  { $0.view !== view }
			.forEach { container.addSublayer($0) }

		layer.addSublayer(container)
		defer { container.removeFromSuperlayer() }

		let dragged = cached.first(where: { $0.view === view })!

		dragged.zPosition = 2
		layer.addSublayer(dragged)
		defer { dragged.removeFromSuperlayer() }

		let d0 = view.frame.origin
		let p0 = convert(event.locationInWindow, from: nil)

		NSCursor.closedHand.set()

		window!.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout: 1e6, mode: RunLoop.Mode.eventTracking) { event, stop in
			guard let event = event else {
				return
			}
			if event.type == .leftMouseDragged {
				let p1 = self.convert(event.locationInWindow, from: nil)

				let dx = (self.orientation == .horizontal) ? p1.x - p0.x : 0
				let dy = (self.orientation == .vertical)   ? p1.y - p0.y : 0

				CATransaction.begin()
				CATransaction.setDisableActions(true)
				dragged.frame.origin.x = d0.x + dx
				dragged.frame.origin.y = d0.y + dy
				CATransaction.commit()

				let reordered = self.views.map {
					(view: $0,
					 position: $0 !== view
						? NSPoint(x: $0.frame.midX, y: $0.frame.midY)
						: NSPoint(x: dragged.frame.midX, y: dragged.frame.midY))
					}
					.sorted {
						switch self.orientation {
						case .vertical: return $0.position.y < $1.position.y
						case .horizontal: return $0.position.x < $1.position.x
						default: return true
						}
					}
					.map { $0.view }

				let nextIndex = reordered.firstIndex(of: view)!
				let prevIndex = self.views.firstIndex(of: view)!

				if nextIndex != prevIndex {
					self.update(self, reordered)
					self.layoutSubtreeIfNeeded()

					CATransaction.begin()
					CATransaction.setAnimationDuration(0.15)
					CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))

					for layer in cached {
						layer.position = NSPoint(x: layer.view.frame.midX, y: layer.view.frame.midY)
					}

					CATransaction.commit()
				}
			} else {
				view.mouseUp(with: event)
				NSCursor.pop()
				stop.pointee = true
				self.dragDelegate?.stackViewDidReorder()
			}
		}
	}

	// MARK: -
	// MARK: View Caching
	private class CachedViewLayer: CALayer {
		let view: NSView!

		enum CacheError: Error {
			case bitmapCreationFailed
		}

		override init(layer: Any) {
			self.view = (layer as! CachedViewLayer).view
			super.init(layer: layer)
		}

		init(view: NSView) throws {
			self.view = view

			super.init()

			guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { throw CacheError.bitmapCreationFailed }
			view.cacheDisplay(in: view.bounds, to: bitmap)

			frame = view.frame
			contents = bitmap.cgImage
		}

		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}

	private func cacheViews() throws -> [CachedViewLayer] {
		return try views.map { try cacheView(view: $0) }
	}

	private func cacheView(view: NSView) throws -> CachedViewLayer {
		return try CachedViewLayer(view: view)
	}
}
