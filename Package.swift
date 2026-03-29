// swift-tools-version: 6.2

import PackageDescription

let mainActorSettings: [SwiftSetting] = [
  .defaultIsolation(MainActor.self),
]

let package = Package(
  name: "LifecycleKit",
  platforms: [
    .iOS(.v26),
    .tvOS(.v26),
    .watchOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(name: "CombineExtensions", targets: ["CombineExtensions"]),
    .library(name: "Lifecycle", targets: ["Lifecycle"]),
    .library(name: "SPIR", targets: ["SPIR"]),
    .library(name: "MVVM", targets: ["MVVM"]),
    .library(name: "RIBs", targets: ["RIBs"]),
  ],
  dependencies: [
    .package(url: "https://github.com/uber/needle.git", from: "0.25.0"),
  ],
  targets: [
    .target(name: "CombineExtensions"),
    .testTarget(name: "CombineExtensionsTests", dependencies: ["CombineExtensions"]),
    .target(name: "Lifecycle", dependencies: ["CombineExtensions"], swiftSettings: mainActorSettings),
    .testTarget(name: "LifecycleTests", dependencies: ["Lifecycle"]),
    .target(name: "SPIR", dependencies: ["Lifecycle"], swiftSettings: mainActorSettings),
    .testTarget(
      name: "SPIRTests",
      dependencies: ["SPIR", .product(name: "NeedleFoundation", package: "needle")]
    ),
    .target(name: "MVVM", dependencies: ["Lifecycle"], swiftSettings: mainActorSettings),
    .testTarget(
      name: "MVVMTests",
      dependencies: ["MVVM", .product(name: "NeedleFoundation", package: "needle")]
    ),
    .target(name: "RIBs", dependencies: ["Lifecycle"], swiftSettings: mainActorSettings),
    .testTarget(
      name: "RIBsTests",
      dependencies: ["RIBs", .product(name: "NeedleFoundation", package: "needle")]
    ),
  ]
)
