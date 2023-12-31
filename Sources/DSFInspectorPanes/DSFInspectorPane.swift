//
//  DSFInspectorPane.swift
//
//  Created by Darren Ford on 9/6/19.
//
//  MIT License
//
//  Copyright (c) 2023 Darren Ford
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

#if os(macOS)

import Cocoa

/// The expansion type for a new pane
@objc public enum DSFInspectorPaneExpansionType: Int {
	/// The pane cannot be collapsed. Does not show a disclosure button
	case none
	/// Expanded by default
	case expanded
	/// Collapsed by default
	case collapsed
}

/// Publicly accessable inspector pane information
@objc public protocol DSFInspectorPane {
	/// A unique identifier for the inspector panel
	@objc var identifier: NSUserInterfaceItemIdentifier? { get set }
	/// The inspector panes title
	@objc var title: String { get set }
	/// The actual inspector pane
	@objc var inspector: NSView? { get }
	/// An optional header view for the inspector pane
	@objc var header: NSView? { get }
	/// When is the header view visible?
	@objc var headerVisibility: DSFInspectorPaneHeaderAccessoryVisibility { get }
	/// Can the user expand and contract the pane?
	@objc var canExpand: Bool { get }
	/// Is the panel expanded?
	@objc var isExpanded: Bool { get set }

	/// Change the visibility overriding the inspector's built-in animation settings
	///
	/// - Parameters:
	///   - expanded: true to expand, false to collapse
	///   - animated: should the change be animated?
	@objc func setExpanded(_ expanded: Bool, animated: Bool)
}

@objc public enum DSFInspectorPaneHeaderAccessoryVisibility: Int {
	/// Only show the header accessory when the pane is collapsed
	case onlyWhenCollapsed = 0
	/// Always show the header accessory
	case always = 1
}

#endif
