//
//  MainPropertyPanesViewController.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 9/6/19.
//  Copyright © 2020 Darren Ford. All rights reserved.
//

import Cocoa

import DSFInspectorPanes

class MainPropertyPanesViewController: NSViewController {
	// Dummy views
	let dummy = DummyViewController()
	let spacing = SpacingViewController()
	let alignment = AlignmentViewController()
	let color = ColorViewController()
	let fillAndStroke = FillStrokeViewController()
	let desc = DescriptionFieldViewController()
	let textWithAction = TextWithButtonViewController()

	// Main window nested views
	let dummy1 = DummyViewController()
	let dummy2 = ColorViewController()
	lazy var nestedPanes: DSFInspectorPanesView = {
		let n = DSFInspectorPanesView(frame: .zero,
												animated: true,
												embeddedInScrollView: false,
												showSeparators: true,
												showBoxes: false,
												titleFont: NSFont.systemFont(ofSize: 12))
		n.addPane(title: "Nested Radio", view: dummy1.view, showsHeader: false)
		n.addPane(title: "Nested Color", view: dummy2.view, showsHeader: false, headerAccessoryView: dummy2.headerView)
		return n
	}()

	private var panes: DSFInspectorPanesView {
		return self.view as! DSFInspectorPanesView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.createPanes()
	}

	private func createPanes() {
		self.panes.insets = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

		self.panes.addPane(
			title: "Description",
			view: self.desc.view,
			headerAccessoryView: self.desc.headerView,
			expansionType: .collapsed
		)
		self.panes.addPane(
			title: "Label with button thing",
			view: self.textWithAction.view
		)
		self.panes.addPane(
			title: "Grid of colors",
			view: self.color.view,
			headerAccessoryView: self.color.headerView,
			headerAccessoryVisibility: .always,
			expansionType: .collapsed
		)
		self.panes.addPane(
			title: "Alignment (fixed)",
			view: self.alignment.view,
			expansionType: .none
		)

		/// Add in our nested

		self.panes.addPane(
			title: "Nested Panes",
			view: self.nestedPanes
		)

		self.panes.addPane(
			title: "Spacing",
			view: self.spacing.view,
			headerAccessoryView: self.spacing.headerView
		)

		self.panes.addPane(
			title: "Fill And Stroke",
			view: self.fillAndStroke.view,
			showsHeader: false
		)
	}
}
