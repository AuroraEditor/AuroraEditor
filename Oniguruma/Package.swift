// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftOniguruma",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftOniguruma",
            targets: ["SwiftOniguruma"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // .systemLibrary(name: "Oniguruma", pkgConfig: "Oniguruma"),
        .systemLibrary(name: "oniguruma", path: "Sources/oniguruma"),
        .target(name: "SwiftOniguruma", dependencies: ["oniguruma"])
    ]
)
