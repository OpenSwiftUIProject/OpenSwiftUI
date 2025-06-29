//
//  OpenGraphAdditionsTests.swift
//  OpenSwiftUICoreTests

import OpenGraphShims
import OpenSwiftUICore
import Testing

// MARK: - MetadataAdditionsTests

@Suite(.enabled(if: swiftToolchainSupported))
struct MetadataAdditionsTests {
    class T1 {}

    struct T2 {}

    enum T3 {}

    protocol P {}

    @Test
    func isValueType() {
        #expect(Metadata(T1.self).isValueType == false)
        #expect(Metadata(T2.self).isValueType == true)
        #expect(Metadata(T3.self).isValueType == true)
        #expect(Metadata(P.self).isValueType == false)

        #expect(Metadata(T1?.self).isValueType == true)
        #expect(Metadata((T1, T1).self).isValueType == true)
    }

    @Test
    func genericType() {
        struct T1<A, B, C> {}
        struct T2<A, B> where A: P, B: P {}

        struct P1: P {}
        struct P2: P {}
        let t1Type = Metadata(T1<Int, Double, Float>.self)
        #expect(t1Type.genericType(at: 0) == Int.self)
        #expect(t1Type.genericType(at: 1) == Double.self)
        #expect(t1Type.genericType(at: 2) == Float.self)

        let t2Type = Metadata(T2<P1, P2>.self)
        #expect(t2Type.genericType(at: 0) == P1.self)
        #expect(t2Type.genericType(at: 1) == P2.self)
    }

    @Test
    func projectEnum() {
        enum T: Equatable {
            case empty
            case int64(Int64)
            case int32(Int32)
        }

        var t = T.empty
        let metadata = Metadata(T.self)

        metadata.projectEnum(at: &t, tag: 0) { p in
            UnsafeMutableRawPointer(mutating: p)
                .assumingMemoryBound(to: Int64.self)
                .pointee = 1
        }
        #expect(t == .int64(1))

        metadata.projectEnum(at: &t, tag: 1) { p in
            UnsafeMutableRawPointer(mutating: p)
                .assumingMemoryBound(to: Int32.self)
                .pointee = 1
        }
        #expect(t == .int32(1))

        metadata.projectEnum(at: &t, tag: 2) { _ in }
        #expect(t == .empty)
    }

    @Test
    func compareEnumTagsTest() {
        enum A {
            case a, b, c
        }
        #expect(compareEnumTags(A.a, A.b) == false)
        #expect(compareEnumTags(A.a, A.a) == true)

        let v1: A? = .c
        let v2: A? = .a
        #expect(compareEnumTags(v1, nil) == false)
        #expect(compareEnumTags(v1, v2) == true)
    }
}
