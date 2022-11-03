// swift-tools-version:5.7
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
        .package(url: "https://github.com/kiranmadhav/CleanroomLogger", from: "1.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.10.0"),
        .package(url: "https://github.com/SlaunchaMan/GCDWebServer.git", branch: "935e2736044e71e5341663c3cc9a335ba6867a2b")
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
