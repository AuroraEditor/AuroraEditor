// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Editor",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_13),
        .iOS(SupportedPlatform.IOSVersion.v12),
        .tvOS(SupportedPlatform.TVOSVersion.v12),
        .watchOS(SupportedPlatform.WatchOSVersion.v4)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "EditorCore",
            targets: ["EditorCore"]),
        .library(
            name: "EditorUI",
            targets: ["EditorUI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on
        // products in packages which this package depends on.
        .target(
            name: "EditorCore",
            dependencies: []),
        .testTarget(
            name: "EditorCoreTests",
            dependencies: ["EditorCore"]),
        .target(
            name: "EditorUI",
            dependencies: ["EditorCore"])
    ]
)
