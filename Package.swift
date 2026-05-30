// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "rahhhhhh",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "rahhhhhh", targets: ["App"]),
    ],
    targets: [
        .executableTarget(
            name: "App",
            path: "FILES",
            exclude: ["build_ipa.sh"],
            resources: [
                .copy("Info.plist")
            ]
        )
    ]
)
