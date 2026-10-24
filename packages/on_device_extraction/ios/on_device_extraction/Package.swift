// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "on_device_extraction",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "on-device-extraction", targets: ["on_device_extraction"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/moonshine-ai/moonshine-swift", exact: "0.1.5"),
    ],
    targets: [
        .target(
            name: "on_device_extraction",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MoonshineVoice", package: "moonshine-swift"),
            ],
            path: "Sources/on_device_extraction"
        )
    ]
)
