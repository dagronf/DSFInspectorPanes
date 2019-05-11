//
//  AppDelegate.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 1/5/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa
import DSFInspectorPanes

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var propertyPanes1: DSFInspectorPanesView!

	@IBOutlet weak var paneView1: NSView!
	@IBOutlet weak var paneView2: NSView!
	@IBOutlet weak var paneHiddenView: NSView!
	@IBOutlet weak var SpacingView: NSView!
	@IBOutlet weak var SpacingAccessory: NSPopUpButton!
	@IBOutlet weak var AlignmentView: NSView!

	@IBOutlet weak var freeTextView: NSView!
	@IBOutlet weak var freeTextTrunc: NSView!
	
	@IBOutlet weak var propertyPaneWindow: NSPanel!
	@IBOutlet weak var propertyPaneWindowView: DSFInspectorPanesView!
	@IBOutlet weak var propertyPaneWindowLabelViewThing: NSView!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application

//		self.propertyPanes1.titleFont = NSFont.boldSystemFont(ofSize: 11)
//		self.propertyPanes1.spacing = 4
//		self.propertyPanes1.insets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

		propertyPanes1.add(title: "Description", view: self.freeTextView, headerAccessoryView: freeTextTrunc, expanded: false)

		propertyPanes1.add(title: "Label with button thing", view: self.paneView1)
		propertyPanes1.add(title: "Grid of colors",
							   view: self.paneView2,
							   headerAccessoryView: paneHiddenView,
							   expanded: false)
		propertyPanes1.add(title: "Alignment", view: self.AlignmentView, canHide: false)
		propertyPanes1.add(title: "Spacing", view: self.SpacingView, headerAccessoryView: SpacingAccessory)

		propertyPaneWindow.makeKeyAndOrderFront(nil)
		propertyPaneWindowView.titleFont = NSFont.boldSystemFont(ofSize: 12)
		propertyPaneWindowView.add(title: "Label with button thing", view: self.propertyPaneWindowLabelViewThing)

	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

