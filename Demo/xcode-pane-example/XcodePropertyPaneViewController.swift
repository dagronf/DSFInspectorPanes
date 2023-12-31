//
//  XcodePropertyPaneViewController.swift
//  xcode-pane-example
//
//  Created by Darren Ford on 9/11/20.
//  Copyright © 2023 Darren Ford. All rights reserved.
//

import Cocoa

import DSFInspectorPanes

class XcodePropertyPaneViewController: NSViewController {

	override func loadView() {

		self.view = self.panes

	}

	lazy var panes: DSFInspectorPanesView = {
		let p = DSFInspectorPanesView(frame: .zero,
									  animated: true,
									  embeddedInScrollView: true,
									  showSeparators: true,
									  showBoxes: false,
									  titleFont: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize,
																   weight: .bold), canDragRearrange: false)
		p.translatesAutoresizingMaskIntoConstraints = false
		return p
	}()

	let previewPane = PreviewViewController()
	let schemePane = ColorSchemePropertyPaneViewController()
	let dynamicTypePane = DynamicTypePropertyPaneViewController()
	let framePane = FramePropertyPaneViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

		self.panes.addPane(title: "Preview", view: self.previewPane.view, expansionType: .none)
		self.panes.addPane(title: "Color Scheme", view: self.schemePane.view, expansionType: .none)
		self.panes.addPane(title: "Dynamic Type", view: self.dynamicTypePane.view, expansionType: .none)
		self.panes.addPane(title: "Frame", view: self.framePane.view, expansionType: .none)


    }
    
}
