// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AuroraEditorCli",
    products: [
        .executable(name: "AuroraEditorCli", targets: ["AuroraEditorCli"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AuroraEditorCli"
        )
    ]
)
