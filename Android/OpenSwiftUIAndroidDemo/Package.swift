// swift-tools-version: 6.3
import PackageDescription

// Keep Android's dependency lockfile separate from the default Darwin configuration.
let package = Package(
    name: "OpenSwiftUIAndroidApp",
    products: [
        .library(name: "OpenSwiftUIAndroidApp", type: .dynamic, targets: ["AndroidDemo"]),
    ],
    dependencies: [.package(path: "../..")],
    targets: [
        .target(
            name: "AndroidDemo",
            dependencies: [.product(name: "OpenSwiftUIAndroidHost", package: "OpenSwiftUI")],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
