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
        .package(url: "https://github.com/FyrbyAdditive/feetech-servo-sdk-swift.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "FAC1-Controller",
            dependencies: [
                .product(name: "SCServoSDK", package: "feetech-servo-sdk-swift")
            ],
            path: "Sources"
        )
    ]
)
