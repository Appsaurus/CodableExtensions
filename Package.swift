// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CodableExtensions",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS("9.2"), .watchOS("3.0")
    ],
	products: [
		.library(name: "CodableExtensions", targets: ["CodableExtensions"])
	],
	dependencies: [
		.package(url: "https://github.com/yonaskolb/Codability.git", from: "0.2.0"),
		.package(url: "https://github.com/Appsaurus/RuntimeExtensions",  from: "1.0.1"),
		.package(url: "https://github.com/Appsaurus/SwiftTestUtils",  from: "1.0.0")
	],
	targets: [
		.target(name: "CodableExtensions", dependencies: ["RuntimeExtensions", "Codability"], path: "./Sources/Shared"),
		.testTarget(name: "CodableExtensionsTests", dependencies: ["CodableExtensions", "SwiftTestUtils"], path: "./CodableExtensionsTests/Shared")
	]
)
