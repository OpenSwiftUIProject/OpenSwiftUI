//
//  TracingTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenGraphShims
import Testing

@Suite(.disabled(if: !attributeGraphEnabled, "Not implemented in OG yet"))
struct TracingTests {
    struct Demo {}
    
    @Test(.disabled(if: !attributeGraphEnabled, "OGTypeDescription is not implemented yet"))
    func name() {
        #expect(Tracing.nominalTypeName(Int.self) == "Int")
        #expect(Tracing.nominalTypeName(String.self) == "String")
        #expect(Tracing.nominalTypeName(Demo.self) == "TracingTests.Demo")
    }
    
    @Test(.disabled(if: !attributeGraphEnabled, "OGTypeNominalDescriptor is not implemented yet"))
    func library() async throws {
        #expect(Tracing.libraryName(defining: Int.self) == "libswiftCore.dylib")
        #expect(Tracing.libraryName(defining: String.self) == "libswiftCore.dylib")
        #expect(Tracing.libraryName(defining: Demo.self) == "OpenSwiftUICoreTests")
    }
}
