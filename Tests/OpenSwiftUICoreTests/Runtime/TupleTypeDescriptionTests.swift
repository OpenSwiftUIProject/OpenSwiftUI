//
//  TupleTypeDescriptionTests.swift
//  OpenSwiftUICoreTests

import Testing
@testable import OpenSwiftUICore
import OpenGraphShims

extension TestProtocolDescriptor: TupleDescriptor {
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<Self>] = [:]
}

struct TupleTypeDescriptionTests {
    // Types that conform to TestProtocol
    struct P1: TestProtocol {}
    struct P2: TestProtocol {}

    // Types that don't conform to TestProtocol
    struct P3 {}

    @Test
    func emptyTuple() throws {
        let tupleType = TupleType(Void.self)
        let description = TupleTypeDescription<TestProtocolDescriptor>(tupleType)
        
        #expect(description.contentTypes.isEmpty)
    }

    @Test
    func allConformingTypes() throws {
        let tupleType = TupleType((P1, P2).self)
        let description = TupleTypeDescription<TestProtocolDescriptor>(tupleType)
        
        #expect(description.contentTypes.count == 2)
        #expect(description.contentTypes[0].0 == 0)
        #expect(description.contentTypes[1].0 == 1)
        #expect(description.contentTypes[0].1.type == P1.self)
        #expect(description.contentTypes[1].1.type == P2.self)
    }

    @Test
    func mixedConformance() throws {
        let tupleType = TupleType((P1, P3, P2).self)
        let description = TupleTypeDescription<TestProtocolDescriptor>(tupleType)
        
        #expect(description.contentTypes.count == 2)
        #expect(description.contentTypes[0].0 == 0)
        #expect(description.contentTypes[1].0 == 2)
        #expect(description.contentTypes[0].1.type == P1.self)
        #expect(description.contentTypes[1].1.type == P2.self)
    }
    
    @Test
    func testNoConformingTypes() throws {
        let tupleType = TupleType((P3, P3).self)
        let description = TupleTypeDescription<TestProtocolDescriptor>(tupleType)
        #expect(description.contentTypes.isEmpty)
    }

    @Test
    func tupleTypeCache() throws {
        let tupleType = TupleType((P1, P2, Int).self)

        let description1 = TestProtocolDescriptor.tupleDescription(tupleType)
        #expect(TestProtocolDescriptor.typeCache.count == 1)

        #expect(TestProtocolDescriptor.typeCache.contains {
            $0.key == ObjectIdentifier((P1, P2, Int).self)
        })

        let description2 = TestProtocolDescriptor.tupleDescription(tupleType)
        #expect(TestProtocolDescriptor.typeCache.count == 1)
        
        #expect(description1.contentTypes.count == description2.contentTypes.count)
        #expect(description1.contentTypes[0].0 == description2.contentTypes[0].0)
        #expect(description1.contentTypes[1].0 == description2.contentTypes[1].0)
    }
}
