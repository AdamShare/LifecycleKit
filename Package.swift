// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LifecycleKit",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CombineExtensions",
            targets: ["CombineExtensions"]
        ),
        .library(
            name: "Lifecycle",
            targets: ["Lifecycle"]
        ),
        .library(
            name: "SPIR",
            targets: ["SPIR"]
        ),
        .library(
            name: "MVVM",
            targets: ["MVVM"]
        ),
        .library(
            name: "RIBs",
            targets: ["RIBs"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/uber/needle.git", branch: "master"),
    ],
    targets: [
        .target(name: "CombineExtensions",
                dependencies: []),
        .testTarget(name: "CombineExtensionsTests",
                    dependencies: ["CombineExtensions"]),
        .target(name: "Lifecycle",
                dependencies: ["CombineExtensions"]),
        .testTarget(name: "LifecycleTests",
                    dependencies: ["Lifecycle"]),
        .target(name: "SPIR",
                dependencies: ["Lifecycle"]),
        .testTarget(name: "SPIRTests",
                    dependencies: ["SPIR",
                                   .product(name: "NeedleFoundation", package: "needle")]),
        .target(name: "MVVM",
                dependencies: ["Lifecycle"]),
        .testTarget(name: "MVVMTests",
                    dependencies: ["MVVM",
                                   .product(name: "NeedleFoundation", package: "needle")]),
        .target(name: "RIBs",
                dependencies: ["Lifecycle"]),
        .testTarget(name: "RIBsTests",
                    dependencies: [
                        "RIBs",
                                   .product(name: "NeedleFoundation", package: "needle")
                    ]),
    ]
)
