// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteInput",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "RemoteInput",
            targets: ["RemoteInput"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "RemoteInput",
            resources: [
            ],
            swiftSettings: [
                .unsafeFlags(["-framework", "AppKit"]),
                .unsafeFlags(["-framework", "CoreBluetooth"])
            ]
        )
    ]
)
