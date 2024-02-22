// swift-tools-version:5.7
import PackageDescription

let version = "8.2.3"
let checksum = "a20e8dc31a68d151278973c660949a72337f4ef515e0620db9ee3cd746bb7eeb"

let package = Package(
    name: "AuthenticVisionSDK",
    products: [
        .library(
            name: "AuthenticVisionSDK",
            targets: ["AuthenticVisionSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "AuthenticVisionSDK",
            url: "https://github.com/EmanuelMairoll/AVSDK-mirror/releases/download/v\(version)/AuthenticVisionSDK.xcframework.zip",
            checksum: checksum
        )
    ]
)
