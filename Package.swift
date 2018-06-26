// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CodableExtensions",
	products: [
		.library(name: "CodableExtensions", targets: ["CodableExtensions"])
	],
	dependencies: [
		.package(url: "https://github.com/yonaskolb/Codability.git", from: "0.2.0"),
		.package(url: "https://github.com/Appsaurus/RuntimeExtensions",  .upToNextMajor(from: "0.1.0")),
		.package(url: "https://github.com/Appsaurus/SwiftTestUtils",  .upToNextMajor(from: "1.0.0"))
	],
	targets: [
		.target(name: "CodableExtensions", dependencies: ["RuntimeExtensions", "Codability"], path: "./Sources/Shared"),
		.testTarget(name: "CodableExtensionsTests", dependencies: ["CodableExtensions", "SwiftTestUtils"], path: "./CodableExtensionsTests/Shared")
	]
)
