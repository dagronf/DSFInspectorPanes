//
//  WindowPropertyPanesViewController.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 9/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa
import DSFInspectorPanes

class WindowPropertyPanesViewController: NSViewController {

	let textButton = TextWithButtonViewController()
	let spacing = SpacingViewController()


	// Separate window views
	let windowPane1 = DummyViewController()
	let windowDummy1 = DummyViewController()
	let windowDummy2 = ColorViewController()
	lazy var windowNestedPanes: DSFInspectorPanesView = {
		let v = DSFInspectorPanesView(frame: .zero,
									  animated: true,
									  embeddedInScrollView: false,
									  showSeparators: false,
									  showBoxes: true)
		v.add(title: "Nested Radios", view: windowDummy1.view)
		v.add(title: "Nested Color Pane", view: windowDummy2.view)
		return v
	}()

	private var panes: DSFInspectorPanesView {
		return self.view as! DSFInspectorPanesView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.createPanes()
	}

	private func createPanes() {
		panes.add(title: "Label with button thing",
				  view: textButton.view,
				  expanded: false)
		panes.add(title: "Nested", view: windowNestedPanes)
	}
}
