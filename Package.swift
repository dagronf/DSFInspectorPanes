// swift-tools-version: 5.5

import PackageDescription

let package = Package(
	name: "DSFInspectorPanes",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.library(name: "DSFInspectorPanes", targets: ["DSFInspectorPanes"]),
		.library(name: "DSFInspectorPanes-static", type: .static, targets: ["DSFInspectorPanes"]),
		.library(name: "DSFInspectorPanes-shared", type: .dynamic, targets: ["DSFInspectorPanes"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "DSFInspectorPanes",
			dependencies: []
		),
		.testTarget(
			name: "DSFInspectorPanesTests",
			dependencies: ["DSFInspectorPanes"]),
	]
)
