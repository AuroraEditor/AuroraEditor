// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftOniguruma",
    targets: [
        // .systemLibrary(name: "Oniguruma", pkgConfig: "Oniguruma"),
        .systemLibrary(name: "Oniguruma", path: "Sources/Oniguruma"),
        .target(name: "SwiftOniguruma", dependencies: ["Oniguruma"])
    ]
)