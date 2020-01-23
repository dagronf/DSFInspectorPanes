//
//  ImageViewController.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 11/6/19.
//  Copyright © 2020 Darren Ford. All rights reserved.
//

import Cocoa

class ImageViewController: NSViewController {

	@IBOutlet weak var image: NSImageView!

	@IBOutlet var headerView: NSView!
	@IBOutlet weak var headerImage: NSImageView!

	var displayedImage: NSImage? {
		didSet {
			image.image = displayedImage
			headerImage.image = displayedImage
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		displayedImage = NSImage(named: NSImage.Name("apple_logo_orig"))
	}

	@IBAction func imageDidChange(_ sender: NSImageView) {
		self.displayedImage = sender.image
	}

	@IBAction func headerImageDidChange(_ sender: NSImageView) {
		self.displayedImage = sender.image
	}
}
