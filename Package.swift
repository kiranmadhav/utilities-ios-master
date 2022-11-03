// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Utilities",
            targets: ["Utilities"]),
    ],
    dependencies: [
        // CleanroomLogger at a commit on master, until there's a release supporting spm.
        .package(url: "https://github.com/emaloney/CleanroomLogger", .revision("d732baead85b77471505daf290212700b9d87a05")),
        .package(url: "https://github.com/mxcl/PromiseKit", .exact("6.10.0")),
        .package(url: "https://github.com/SlaunchaMan/GCDWebServer.git", .branch("swift-package-manager"))
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: ["CleanroomLogger", "PromiseKit", "GCDWebServer"],
            path: "Utilities/Utilities",
            exclude: ["Info.plist"],
            resources: [.copy("PackageResources")]),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"],
            path: "Utilities/UtilitiesTests",
            exclude: ["Info.plist"],
            resources: [.copy("PackageResources")])
    ]
)
