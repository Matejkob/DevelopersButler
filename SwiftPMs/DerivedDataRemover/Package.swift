// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DerivedDataRemover",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DerivedDataRemover",
            targets: ["DerivedDataRemover"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.47.2"
        )
    ],
    targets: [
        .target(
            name: "DerivedDataRemover",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DerivedDataRemoverTests",
            dependencies: ["DerivedDataRemover"],
            path: "Tests"
        ),
    ]
)
