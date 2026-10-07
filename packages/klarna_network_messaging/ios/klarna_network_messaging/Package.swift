// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "klarna_network_messaging",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "klarna-network-messaging", targets: ["klarna_network_messaging"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Sibling-symlink path (like FlutterFramework); a repo-tree path gives SwiftPM two identities.
        .package(name: "klarna_network_core", path: "../klarna_network_core"),
        // Pin exactly, in lockstep with core/payment, so CI resolves one SDK version.
        .package(url: "https://github.com/klarna/klarna-mobile-sdk-ios", exact: "2.15.0")
    ],
    targets: [
        .target(
            name: "klarna_network_messaging",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "klarna-network-core", package: "klarna_network_core"),
                .product(name: "KlarnaNetworkMessaging", package: "klarna-mobile-sdk-ios")
            ]
        ),
        .testTarget(
            name: "klarna_network_messagingTests",
            dependencies: ["klarna_network_messaging"]
        )
    ]
)
