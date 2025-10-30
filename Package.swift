// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FAC1-Controller",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FAC1-Controller",
            targets: ["FAC1-Controller"]
        )
    ],
    dependencies: [
        .package(path: "../feetech-servo-swift/SCServoSwift")
    ],
    targets: [
        .executableTarget(
            name: "FAC1-Controller",
            dependencies: [
                .product(name: "SCServoSDK", package: "SCServoSwift")
            ],
            path: "Sources"
        )
    ]
)
