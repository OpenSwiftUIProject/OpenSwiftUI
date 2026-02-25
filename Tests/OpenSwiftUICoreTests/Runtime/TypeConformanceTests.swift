//
//  TypeConformanceTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore
import OpenAttributeGraphShims

protocol TestProtocol {}

struct TestProtocolDescriptor: ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer {
        unsafeBitCast(TestProtocol.self, to: UnsafeRawPointer.self)
            .advanced(by: 16)
            .assumingMemoryBound(to: UnsafeRawPointer.self)
            .pointee
    }
}

@Suite
struct TypeConformanceTests {
    struct P1: TestProtocol {}
    struct P2 {}

    @Test
    func typeConformance() throws {
        let conformance = try #require(TestProtocolDescriptor.conformance(of: P1.self))
        #expect(conformance.type == P1.self)

        #expect(TestProtocolDescriptor.conformance(of: P2.self) == nil)
    }

    @Test
    func conform() {
        #expect(conformsToProtocol(P1.self, TestProtocolDescriptor.descriptor) == true)
        #expect(conformsToProtocol(P2.self, TestProtocolDescriptor.descriptor) == false)
    }
}
