// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "klarna_network_core",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "klarna-network-core", targets: ["klarna_network_core"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Pin exactly so CI resolves deterministically (a floating `from:` now
        // drifts to 2.12.0, which restructured the SDK). Bump deliberately.
        .package(url: "https://github.com/klarna/klarna-mobile-sdk-ios", exact: "2.12.0")
    ],
    targets: [
        .target(
            name: "klarna_network_core",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                // The native SDK ships KlarnaNetworkCore only as a binary target,
                // not as a standalone SPM product — every product that exposes the
                // KlarnaNetworkCore module bundles a feature module alongside it.
                // We pull KlarnaNetworkPayment, the feature this SDK targets.
                .product(name: "KlarnaNetworkPayment", package: "klarna-mobile-sdk-ios")
            ]
        )
    ]
)
