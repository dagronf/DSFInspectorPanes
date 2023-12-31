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

	/// The panes view
	
	private lazy var panesView: DSFInspectorPanesView = {
		return self.view as! DSFInspectorPanesView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setup()
	}

	func setup() {
		self.panesView.insets = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
		self.panesView.spacing = 4
		self.panesView.addPane(title: "Short Description", view: self.shortDescription.view)
		self.panesView.addPane(title: "Long Description", view: self.longDescription.view)
		self.panesView.addPane(title: "Image", view: self.imageItem.view, headerAccessoryView: self.imageItem.headerView, expansionType: .collapsed)

		// Listen to inspector changes
		self.panesView.inspectorPaneDelegate = self
	}

	@IBAction func toggleVisibility(_ sender: NSButton) {
		switch sender.tag {
		case 100:
			self.panesView.toggleAll()
		case 101:
			self.panesView.expandAll()
		case 102:
			self.panesView.hideAll()
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
