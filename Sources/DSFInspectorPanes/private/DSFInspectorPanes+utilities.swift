//
//  DSFInspectorPanes+utilities.swift
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
