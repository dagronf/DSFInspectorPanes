//
//  MainViewController.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 11/6/19.
//  Copyright © 2020 Darren Ford. All rights reserved.
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
		self.panes.insets = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
		self.panes.spacing = 4
		self.panes.addPane(title: "Short Description", view: self.shortDescription.view)
		self.panes.addPane(title: "Long Description", view: self.longDescription.view)
		self.panes.addPane(title: "Image", view: self.imageItem.view, headerAccessoryView: self.imageItem.headerView, expansionType: .collapsed)

		// Listen to inspector changes
		self.panes.inspectorPaneDelegate = self
	}

	@IBAction func toggleVisibility(_ sender: NSButton) {
		switch sender.tag {
		case 100:
			self.panes.panes.forEach { $0.setExpanded(!$0.isExpanded, animated: true) }
		case 101:
			self.panes.panes.forEach { $0.setExpanded(true, animated: true) }
		case 102:
			self.panes.panes.forEach { $0.setExpanded(false, animated: true) }
		default:
			break
		}
	}
}

extension MainViewController: DSFInspectorPanesViewProtocol {
	func inspectorPanes(_: DSFInspectorPanesView, didReorder orderedPanes: [DSFInspectorPane]) {
		// do something
		print("Panes did reorder: ")
		print("-  \(orderedPanes.map { $0.title })")
	}

	func inspectorPanes(_: DSFInspectorPanesView, didChangeVisibilityOf pane: DSFInspectorPane) {
		// Do something
		print("Pane: \(pane.title), \(pane.isExpanded)")
	}
}
