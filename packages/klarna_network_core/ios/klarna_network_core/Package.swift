// swift-tools-version: 5.9
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
        // Pinned exactly for deterministic CI resolution and to match
        // klarna_network_payment (a floating `from:` can drift). Bump deliberately.
        .package(url: "https://github.com/klarna/klarna-mobile-sdk-ios", exact: "2.15.0")
    ],
    targets: [
        .target(
            name: "klarna_network_core",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                // The SDK ships KlarnaNetworkCore only as a binary target, so pull
                // the KlarnaNetworkPayment feature product that bundles it.
                .product(name: "KlarnaNetworkPayment", package: "klarna-mobile-sdk-ios")
            ]
        )
    ]
)
