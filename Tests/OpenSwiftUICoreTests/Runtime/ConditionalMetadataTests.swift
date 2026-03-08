//
//  ConditionalMetadataTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@testable import OpenSwiftUICore
import Testing

extension TestProtocolDescriptor: ConditionalProtocolDescriptor {
    static var conditionalCache: [ObjectIdentifier: ConditionalTypeDescriptor<TestProtocolDescriptor>] = [:]

    static func fetchConditionalType(key: ObjectIdentifier) -> ConditionalTypeDescriptor<TestProtocolDescriptor>? {
        conditionalCache[key]
    }

    static func insertConditionalType(key: ObjectIdentifier, value: ConditionalTypeDescriptor<TestProtocolDescriptor>) {
        conditionalCache[key] = value
    }
}

@Suite(.serialized)
struct ConditionalMetadataTests {
    struct EmptyP: TestProtocol {}
    struct P1: TestProtocol {}
    struct P2: TestProtocol {}

    typealias EitherType = _ConditionalContent<P1, P2>

    @Test
    func conditionalMetadata() {
        // atomic
        let p1Metadata = ConditionalMetadata(ConditionalTypeDescriptor<TestProtocolDescriptor>(P1.self))
        #expect(p1Metadata.ids.count == 1)

        let p2Metadata = ConditionalMetadata(ConditionalTypeDescriptor<TestProtocolDescriptor>(P1.self))
        #expect(p2Metadata.ids.count == 1)

        #expect(p1Metadata.ids != p2Metadata.ids)

        // optional
        let optionalMetadata = Optional<P1>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(optionalMetadata.ids.count == 2)

        // either
        let eitherMetadata = ConditionalMetadata(ConditionalTypeDescriptor<TestProtocolDescriptor>(EitherType.self))
        #expect(eitherMetadata.ids.count == 2)

        // nested
        let optionalEitherMetadata = Optional<EitherType>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(optionalEitherMetadata.ids.count == 3)

        let nestedOptionalMetadata = Optional<Optional<EitherType>>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(nestedOptionalMetadata.ids.count == 4)
    }

    @Test
    func conditionalTypeDescriptorCaching() {
        struct P3: TestProtocol {}

        let firstMetadata = Optional<P3>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(TestProtocolDescriptor.conditionalCache.contains { $0.key == ObjectIdentifier(P3.self) })

        let secondMetadata = Optional<P3>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(firstMetadata.ids != secondMetadata.ids)
    }

    #if OPENSWIFTUI_SUPPORT_2024_API
    @Test
    func childInfo() throws {
        // optional
        let optionalMetadata = Optional<P1>.makeConditionalMetadata(TestProtocolDescriptor.self)
        let value: P1? = P1()
        withUnsafePointer(to: value) { ptr in
            let (type, id) = optionalMetadata.childInfo(ptr: ptr, emptyType: EmptyP.self)
            #expect(type == P1.self)
            #expect(id != nil)
        }
        let nilP: P1? = nil
        withUnsafePointer(to: nilP) { ptr in
            let (type, id) = optionalMetadata.childInfo(ptr: ptr, emptyType: EmptyP.self)
            #expect(type == EmptyP.self)
            #expect(id != nil)
        }

        // either
        let eitherMetadata = ConditionalMetadata(ConditionalTypeDescriptor<TestProtocolDescriptor>(EitherType.self))
        let trueValue = EitherType(__storage: .trueContent(P1()))
        withUnsafePointer(to: trueValue) { ptr in
            let (type, id) = eitherMetadata.childInfo(ptr: ptr, emptyType: EmptyP.self)
            #expect(type == P1.self)
            #expect(id != nil)
        }
        let falseValue = EitherType(__storage: .falseContent(P2()))
        withUnsafePointer(to: falseValue) { ptr in
            let (type, id) = eitherMetadata.childInfo(ptr: ptr, emptyType: EmptyP.self)
            #expect(type == P2.self)
            #expect(id != nil)
        }
        let otherValue = 0
        withUnsafePointer(to: otherValue) { ptr in
            let (type, id) = eitherMetadata.childInfo(ptr: ptr, emptyType: EmptyP.self)
            #expect(type == P1.self)
            #expect(id != nil)
        }
    }
    #endif
}
