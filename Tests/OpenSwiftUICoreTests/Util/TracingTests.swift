//
//  TracingTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenGraphShims
import Testing

@Suite(.disabled(if: !attributeGraphEnabled, "Not implemented in OG yet"))
struct TracingTests {
    struct Demo {}
    
    @Test(
        .disabled(if: !attributeGraphEnabled, "OGTypeDescription is not implemented yet"),
        arguments: [
            (type: Int.self as Any.Type, nominalName: "Int"),
            (type: String.self as Any.Type, nominalName: "String"),
            (type: Demo.self as Any.Type, nominalName: "TracingTests.Demo"),
        ]
    )
    func name(type: Any.Type, nominalName: String) {
        #expect(Tracing.nominalTypeName(type) == nominalName)
    }
    
    @Test(
        .disabled(if: !attributeGraphEnabled, "OGTypeNominalDescriptor is not implemented yet"),
        arguments: [
            (type: Int.self as Any.Type, libraryName: "libswiftCore.dylib"),
            (type: String.self as Any.Type, libraryName: "libswiftCore.dylib"),
            (type: Demo.self as Any.Type, libraryName: "OpenSwiftUICoreTests"),
        ]
    )
    func library(type: Any.Type, libraryName: String) {
        #expect(Tracing.libraryName(defining: type) == libraryName)
    }
}
