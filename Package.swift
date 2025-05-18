// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Remote Input",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Remote Input",
            targets: ["Remote Input"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Remote Input",
            path: ".",
            exclude: [
                "RemoteInput/Assets.xcassets",
                "RemoteInput/Preview Content",
                "RemoteInput/RemoteInput.entitlements",
                "RemoteInputTests",
                "RemoteInputUITests"
            ],
            swiftSettings: [
                .unsafeFlags(["-framework", "AppKit"]),
                .unsafeFlags(["-framework", "CoreBluetooth"])
            ]
        )
    ]
)
