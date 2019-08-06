//
//  MainPropertyPanesViewController.swift
//  DSFInspectorPanes_Demo
//
//  Created by Darren Ford on 9/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
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
		n.add(title: "Nested Radio", view: dummy1.view, showsHeader: false)
		n.add(title: "Nested Color", view: dummy2.view, showsHeader: false, headerAccessoryView: dummy2.headerView)
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

		panes.insets = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

		panes.add(title: "Description",
				  view: desc.view,
				  headerAccessoryView: desc.headerView,
				  expanded: false)
		panes.add(title: "Label with button thing",
				  view: textWithAction.view)
		panes.add(title: "Grid of colors",
				  view: color.view,
				  headerAccessoryView: color.headerView,
				  expanded: false)
		panes.add(title: "Alignment (fixed)",
				  view: alignment.view,
				  canHide: false)

		/// Add in our nested

		panes.add(title: "Nested Panes",
				  view: nestedPanes)

		panes.add(title: "Spacing",
				  view: spacing.view,
				  headerAccessoryView: spacing.headerView)

		panes.add(title: "Fill And Stroke",
				  view: fillAndStroke.view,
				  showsHeader: false)

	}

}
