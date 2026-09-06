//
//  TracingTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@testable import OpenSwiftUICore
import Testing

@Suite(.disabled(if: attributeGraphVendor == .oag, "Not implemented in OAG yet"))
struct TracingTests {
    struct Demo {}
    
    @Test(
        arguments: [
            (type: Int.self, nominalName: "Int"),
            (type: String.self, nominalName: "String"),
            (type: Demo.self, nominalName: "TracingTests.Demo"),
        ] as [(Any.Type, String)]
    )
    func name(type: Any.Type, nominalName: String) {
        #expect(Tracing.nominalTypeName(type) == nominalName)
    }
    
    #if os(Linux)
    @Test(
        arguments: [
            (type: Int.self as Any.Type, libraryNames: ["libswiftCore.so"]),
            (type: String.self as Any.Type, libraryNames: ["libswiftCore.so"]),
            (type: Demo.self as Any.Type, libraryNames: ["OpenSwiftUIPackageTests.xctest"]),
        ]
    )
    #else
    @Test(
        arguments: [
            (type: Int.self as Any.Type, libraryNames: ["libswiftCore.dylib"]),
            (type: String.self as Any.Type, libraryNames: ["libswiftCore.dylib"]),
            (type: Demo.self as Any.Type, libraryNames: ["OpenSwiftUICoreTests", "OpenSwiftUIPackageTests"]),
        ]
    )
    #endif
    func library(type: Any.Type, libraryNames: [String]) {
        #expect(libraryNames.contains(Tracing.libraryName(defining: type)))
    }
}
