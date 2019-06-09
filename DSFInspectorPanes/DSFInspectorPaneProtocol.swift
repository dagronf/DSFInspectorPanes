//
//  DSFInspectorPaneProtocol.swift
//  DSFInspectorPanes
//
//  Created by Darren Ford on 9/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

/// Publicly accessable inspector pane information
@objc public protocol DSFInspectorPaneProtocol {
	/// The inspector panes title
	@objc var titleText: String { get set }
	/// The actual inspector pane
	@objc var inspector: NSView? { get }
	/// If specified, the inspector's header view
	@objc var header: NSView? { get }
	/// Expand or contract the inspector view
	@objc var expanded: Bool { get set }
	/// Is the inspector panel hidden from view?
	@objc var hide: Bool { get set }

	/// Change the visibility overriding the inspector's built-in animation settings
	///
	/// - Parameters:
	///   - expanded: true to expand, false to contract
	///   - animated: should the change be animated?
	@objc func setExpanded(_ expanded: Bool, animated: Bool )
}
