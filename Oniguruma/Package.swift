// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftOniguruma",
    targets: [
        // .systemLibrary(name: "oniguruma", pkgConfig: "oniguruma"),
        .systemLibrary(name: "oniguruma", path: "Sources/oniguruma"),
        .target(name: "SwiftOniguruma", dependencies: ["oniguruma"])
    ]
)