// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "SpotPullRefresh",
	platforms: [
		.iOS("8.0"),
	],
	products: [
		.library(name: "SpotPullRefresh", targets: ["SpotPullRefresh"]),
	],
	dependencies: [],
	targets: [
		.target(name: "SpotPullRefresh", dependencies: []),
		.testTarget(name: "SpotPullRefreshTests", dependencies: ["SpotPullRefresh"]),
	]
)
