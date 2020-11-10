//
//  ViewController.swift
//  xcode-pane-example
//
//  Created by Darren Ford on 9/11/20.
//  Copyright © 2020 Darren Ford. All rights reserved.
//

import Cocoa

class ViewController: NSSplitViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.

		self.splitViewItems[0].holdingPriority = .defaultLow
		self.splitViewItems[1].holdingPriority = .defaultLow

	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

