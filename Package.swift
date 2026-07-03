// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Test App",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "Test App", targets: ["App"]),
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
