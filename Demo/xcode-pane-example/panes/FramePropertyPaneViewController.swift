//
//  FramePropertyPaneViewController.swift
//  xcode-pane-example
//
//  Created by Darren Ford on 11/11/20.
//  Copyright © 2020 Darren Ford. All rights reserved.
//

import Cocoa

import DSFStepperView
import DSFToggleButton

class FramePropertyPaneViewController: NSViewController {
	@IBOutlet weak var width: DSFStepperView!
	@IBOutlet weak var height: DSFStepperView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

	@IBAction func toggled(_ sender: DSFToggleButton) {
		let enabled = (sender.state == .on)

		self.width.isEnabled = enabled
		self.height.isEnabled = enabled
	}

}
