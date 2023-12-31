// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "DSFInspectorPanes",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(
			name: "DSFInspectorPanes",
			type: .static,
			targets: ["DSFInspectorPanes"]),
		.library(
			name: "DSFInspectorPanes-shared",
			type: .dynamic,
			targets: ["DSFInspectorPanes"]),

	],
	dependencies: [
	],
	targets: [
		.target(
			name: "DSFInspectorPanes",
			dependencies: []),
		.testTarget(
			name: "DSFInspectorPanesTests",
			dependencies: ["DSFInspectorPanes"]),
	],
	swiftLanguageVersions: [.v5]
)
