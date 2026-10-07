// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "klarna_network_payment",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "klarna-network-payment", targets: ["klarna_network_payment"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // The payment plugin resolves the shared `Klarna` instance from the core
        // plugin's `KnInstanceStore`, so it depends on the core SPM package.
        // Sibling-symlink path (like FlutterFramework above), not a path into
        // the repo tree: Flutter's own generated FlutterGeneratedPluginSwiftPackage
        // resolves this plugin the same way, and a differently-shaped path to the
        // same package causes SwiftPM to see two conflicting identities for it.
        .package(name: "klarna_network_core", path: "../klarna_network_core"),
        // Pin exactly. The native payment button lives in its own product
        // (KlarnaNetworkPaymentButton); bump in lockstep with the code.
        .package(url: "https://github.com/klarna/klarna-mobile-sdk-ios", exact: "2.15.0")
    ],
    targets: [
        .target(
            name: "klarna_network_payment",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "klarna-network-core", package: "klarna_network_core"),
                .product(name: "KlarnaNetworkPayment", package: "klarna-mobile-sdk-ios"),
                // The native Klarna Payment Button types live in this separate
                // product, used by KlarnaPaymentButtonView.
                .product(name: "KlarnaNetworkPaymentButton", package: "klarna-mobile-sdk-ios")
            ]
        ),
        .testTarget(
            name: "klarna_network_paymentTests",
            dependencies: ["klarna_network_payment"]
        )
    ]
)
