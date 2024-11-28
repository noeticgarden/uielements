// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "UIElements",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "UIElements",
            targets: ["UIElements"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "UIElements"
        ),
    ],
    swiftLanguageVersions: [.v5, .version("6")]
)
