//
//  TracingTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenAttributeGraphShims
import Testing

@Suite(.disabled(if: !attributeGraphEnabled, "Not implemented in OAG yet"))
struct TracingTests {
    struct Demo {}
    
    @Test(
        .disabled(if: !attributeGraphEnabled, "OAGTypeDescription is not implemented yet"),
        arguments: [
            (type: Int.self, nominalName: "Int"),
            (type: String.self, nominalName: "String"),
            (type: Demo.self, nominalName: "TracingTests.Demo"),
        ] as [(Any.Type, String)]
    )
    func name(type: Any.Type, nominalName: String) {
        #expect(Tracing.nominalTypeName(type) == nominalName)
    }
    
    @Test(
        .enabled(if: swiftToolchainSupported),
        arguments: [
            (type: Int.self as Any.Type, libraryNames: ["libswiftCore.dylib"]),
            (type: String.self as Any.Type, libraryNames: ["libswiftCore.dylib"]),
            (type: Demo.self as Any.Type, libraryNames: ["OpenSwiftUICoreTests", "OpenSwiftUIPackageTests"]),
        ]
    )
    func library(type: Any.Type, libraryNames: [String]) {
        #expect(libraryNames.contains(Tracing.libraryName(defining: type)))
    }
}
