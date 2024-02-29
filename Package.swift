// swift-tools-version:5.7
import PackageDescription

let version = "8.2.2"
let checksum = "210585b41e167b5779a32980c9b0c6a8a5e6edc1394a742b34768d211083c221"

let package = Package(
    name: "AuthenticVisionSDK",
    platforms: [
        .iOS(.v12)
    ],
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
