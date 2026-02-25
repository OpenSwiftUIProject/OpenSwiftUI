//
//  DynamicPropertyCacheTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@testable import OpenSwiftUICore
import Testing

// FIXME: Remove after we implement forEachField
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct DynamicPropertyCacheTests {
    @Test
    func size() {
        #expect(MemoryLayout<DynamicPropertyCache.Fields>.size == 24)
        #expect(MemoryLayout<DynamicPropertyCache.Fields.Layout>.size == 17)
        #expect(MemoryLayout<DynamicPropertyCache.Fields?>.size == 24)
        #expect(MemoryLayout<DynamicPropertyBehaviors>.size == 4)
    }

    struct NormalP: DynamicProperty {
        var value: Int
    }

    struct AsyncP: DynamicProperty {
        var value: Int

        static var _propertyBehaviors: UInt32 {
            DynamicPropertyBehaviors.allowsAsync.rawValue
        }
    }

    struct MainP: DynamicProperty {
        var value: Int

        static var _propertyBehaviors: UInt32 {
            DynamicPropertyBehaviors.requiresMainThread.rawValue
        }
    }

    enum E {
        case normal(NormalP)
        case value(Int)
        case async(Double, AsyncP)
        case main(MainP, MainP)
    }

    @Test
    func enumFields() {
        let fieldsE = DynamicPropertyCache.fields(of: E.self)
        #expect(
            fieldsE.behaviors == [.requiresMainThread],
            "mix async and main properties will trigger an issue and remove async behavior"
        )
        #expect(fieldsE.name(at: 0) == nil, "Only product fields support name lookup via offset")
        guard case let .sum(type, taggedFields) = fieldsE.layout else {
            Issue.record("layout should be sum type for enum")
            return
        }
        #expect(type == E.self)
        #expect(taggedFields.count == 3)
        let normal = taggedFields[0]
        #expect(normal.tag == 0)
        #expect(normal.fields.count == 1)
        #expect(normal.fields[0].type == NormalP.self)
        #expect(normal.fields[0].offset == 0)
        #expect(normal.fields[0].name.map { String(cString: $0) } == "normal")

        let async = taggedFields[1]
        #expect(async.tag == 2)
        #expect(async.fields.count == 1)
        #expect(async.fields[0].type == AsyncP.self)
        #expect(async.fields[0].offset == 8)
        #expect(async.fields[0].name.map { String(cString: $0) } == "async")

        let main = taggedFields[2]
        #expect(main.tag == 3)
        #expect(main.fields.count == 2)
        #expect(main.fields[0].type == MainP.self)
        #expect(main.fields[0].offset == 0)
        #expect(main.fields[0].name.map { String(cString: $0) } == "main")
        #expect(main.fields[1].type == MainP.self)
        #expect(main.fields[1].offset == 8)
        #expect(main.fields[1].name.map { String(cString: $0) } == "main")
    }

    @Test
    func optionalFields() {
        let optionalP = DynamicPropertyCache.fields(of: Optional<NormalP>.self)
        #expect(optionalP.behaviors == [])
        #expect(optionalP.name(at: 0) == nil, "Only product fields support name lookup via offset")
        guard case let .sum(typeP, taggedFieldsP) = optionalP.layout else {
            Issue.record("layout should be sum type for optional")
            return
        }
        #expect(typeP == Optional<NormalP>.self)
        #expect(taggedFieldsP.count == 1)
        let normalP = taggedFieldsP[0]
        #expect(normalP.tag == 0)
        #expect(normalP.fields.count == 1)
        #expect(normalP.fields[0].type == NormalP.self)
        #expect(normalP.fields[0].offset == 0)
        #expect(normalP.fields[0].name.map { String(cString: $0) } == "some")

        let optionalE = DynamicPropertyCache.fields(of: Optional<E>.self)
        #expect(optionalE.behaviors == [])
        guard case let .sum(typeE, taggedFieldsE) = optionalE.layout else {
            Issue.record("layout should be sum type for optional")
            return
        }
        #expect(typeE == Optional<E>.self)
        #expect(taggedFieldsE.isEmpty)
    }

    @Test
    func structFields() {
        struct S {
            var p1: Int
            var p2: NormalP
            var p3: AsyncP
        }
        let fieldsS = DynamicPropertyCache.fields(of: S.self)
        #expect(fieldsS.behaviors == [.allowsAsync])
        #expect(fieldsS.name(at: 0) == nil)
        #expect(fieldsS.name(at: 8) == "p2")
        #expect(fieldsS.name(at: 9) == nil)
        #expect(fieldsS.name(at: 16) == "p3")
        guard case let .product(fields) = fieldsS.layout else {
            Issue.record("layout should be product type for struct")
            return
        }
        #expect(fields.count == 2)
        #expect(fields[0].type == NormalP.self)
        #expect(fields[0].offset == 8)
        #expect(fields[0].name.map { String(cString: $0) } == "p2")
        #expect(fields[1].type == AsyncP.self)
        #expect(fields[1].offset == 16)
        #expect(fields[1].name.map { String(cString: $0) } == "p3")
    }

    // FIXME: Figure this out when OAG implements forEachField
    @Test
    func tupleFields() {
        let tupleFields = DynamicPropertyCache.fields(of: (n: NormalP, m: MainP).self)
        print(tupleFields)
        #expect(tupleFields.behaviors == [])
        guard case let .product(fields) = tupleFields.layout else {
            Issue.record("layout should be product type for tuple")
            return
        }
        #expect(fields.isEmpty)
    }

    @Test
    func classFields() {
        class C {
            var p1: Int
            var p2: NormalP
            var p3: AsyncP

            init(p1: Int, p2: NormalP, p3: AsyncP) {
                self.p1 = p1
                self.p2 = p2
                self.p3 = p3
            }
        }
        let fieldsC = DynamicPropertyCache.fields(of: C.self)
        #expect(fieldsC.behaviors == [])
        guard case let .product(fields) = fieldsC.layout else {
            Issue.record("layout should be product type for class")
            return
        }
        #expect(fields.isEmpty)
    }
}
