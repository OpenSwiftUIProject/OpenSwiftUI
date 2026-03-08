// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ShaftExample",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .executable(name: "ShaftExample", targets: ["ShaftExample"]),
    ],
    dependencies: [
        .package(path: "../../"),  // OpenSwiftUI
    ],
    targets: [
        .executableTarget(
            name: "ShaftExample",
            dependencies: [
                .product(name: "OpenSwiftUI", package: "OpenSwiftUI"),
                .product(name: "OpenSwiftUIShaftBackend", package: "OpenSwiftUI"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17,
)

