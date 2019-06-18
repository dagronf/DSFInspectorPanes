//
//  MainViewController.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 11/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa
import DSFInspectorPanes

class MainViewController: NSViewController {

	let shortDescription = ShortDescriptionViewController()
	let longDescription = LongDescriptionViewController()
	let imageItem = ImageViewController()

	private var panes: DSFInspectorPanesView {
		return self.view as! DSFInspectorPanesView
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		self.setup()
    }

	func setup() {
		panes.insets = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
		panes.spacing = 4
		panes.add(title: "Short Description",
				  view: shortDescription.view)
		panes.add(title: "Long Description",
				  view: longDescription.view)
		panes.add(title: "Image", view: imageItem.view, headerAccessoryView: imageItem.headerView, canHide: true, expanded: false)

		// Listen to inspector changes
		panes.inspectorPaneDelegate = self
	}

	@IBAction func toggleVisibility(_ sender: NSButton) {
		switch sender.tag {
		case 100:
			self.panes.panes.forEach { $0.setExpanded( !$0.expanded, animated: true) }
		case 101:
			self.panes.panes.forEach { $0.setExpanded( true, animated: true) }
		case 102:
			self.panes.panes.forEach { $0.setExpanded( false, animated: true) }
		default:
			break;
		}
	}
	

}

extension MainViewController: DSFInspectorPanesViewProtocol {
	func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didReorder orderedPanes: [DSFInspectorPane]) {
		// do something
		print("Panes did reorder: ")
		print("-  \(orderedPanes.map { $0.title })")
	}

	func inspectorPanes(_ inspectorPanes: DSFInspectorPanesView, didExpandOrContract pane: DSFInspectorPane) {
		// Do something
		print("Pane: \(pane.title), \(pane.expanded)")
	}
}
