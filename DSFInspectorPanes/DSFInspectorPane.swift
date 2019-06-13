//
//  DSFInspectorPane.swift
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

/// Publicly accessable inspector pane information
@objc public protocol DSFInspectorPane {
	/// A unique identifier for the inspector panel
	@objc var identifier: NSUserInterfaceItemIdentifier? { get set }
	/// The inspector panes title
	@objc var titleText: String { get set }
	/// The actual inspector pane
	@objc var inspector: NSView? { get }
	/// If specified, the inspector's header view
	@objc var header: NSView? { get }
	/// Is the panel expanded?
	@objc var expanded: Bool { get }
	/// Is the inspector panel hidden from view?
	@objc var hide: Bool { get set }

	/// Change the visibility overriding the inspector's built-in animation settings
	///
	/// - Parameters:
	///   - expanded: true to expand, false to contract
	///   - animated: should the change be animated?
	@objc func setExpanded(_ expanded: Bool, animated: Bool)
}
