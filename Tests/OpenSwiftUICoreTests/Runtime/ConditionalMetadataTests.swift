//
//  ConditionalMetadataTests.swift
//  OpenSwiftUICoreTests

import OpenGraphShims
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

@Suite(.enabled(if: swiftToolchainSupported), .serialized)
struct ConditionalMetadataTests {
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
    func conditionalTypeDescriptorCaching() throws {
        struct P3: TestProtocol {}

        let firstMetadata = Optional<P3>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(TestProtocolDescriptor.conditionalCache.contains { $0.key == ObjectIdentifier(P3.self) })

        let secondMetadata = Optional<P3>.makeConditionalMetadata(TestProtocolDescriptor.self)
        #expect(firstMetadata.ids != secondMetadata.ids)
    }
}
