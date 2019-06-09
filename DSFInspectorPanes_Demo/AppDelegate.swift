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

	@IBOutlet weak var mainPropertyPanesController: MainPropertyPanesViewController!
	@IBOutlet weak var WindowPropertyPanesController: WindowPropertyPanesViewController!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}


}

