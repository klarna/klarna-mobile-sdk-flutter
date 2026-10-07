// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "klarna_mobile_sdk_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "klarna-mobile-sdk-flutter", targets: ["klarna_mobile_sdk_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Pin exactly so CI resolves deterministically. Bump deliberately.
        .package(url: "https://github.com/klarna/klarna-mobile-sdk-ios", exact: "2.15.0")
    ],
    targets: [
        .target(
            name: "klarna_mobile_sdk_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                // The post-purchase SDK lives in the KlarnaMobileSDK product.
                .product(name: "KlarnaMobileSDK", package: "klarna-mobile-sdk-ios")
            ]
        )
    ]
)
