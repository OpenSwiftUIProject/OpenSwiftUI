// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let exampleTarget = Target.executableTarget(
    name: "Example",
    dependencies: [
        .product(name: "OpenSwiftUI", package: "OpenSwiftUI"),
    ],
    path: "Example",
    sources: ["ExampleApp.swift", "ContentView.swift"]
)

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [.executable(name: "Example", targets: ["Example"])],
    dependencies: [
        .package(path: "../"),
        .package(path: "../../OpenGraph")
    ],
    targets: [
        exampleTarget,
    ]
)

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[key] else {
        return defaultValue
    }
    if value == "1" {
        return true
    } else if value == "0" {
        return false
    } else {
        return defaultValue
    }
}

#if os(macOS)
let attributeGraphCondition = envEnable("OPENGRAPH_ATTRIBUTEGRAPH", default: true)
#else
let attributeGraphCondition = envEnable("OPENGRAPH_ATTRIBUTEGRAPH")
#endif

extension Target {
    func addAGSettings() {
        // FIXME: Weird SwiftPM behavior for binary Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'AttributeGraph.framework'"
        dependencies.append(.product(name: "AttributeGraph", package: "OpenGraph"))

        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENGRAPH_ATTRIBUTEGRAPH"))
        self.swiftSettings = swiftSettings
    }
}

if attributeGraphCondition {
    exampleTarget.addAGSettings()
}
