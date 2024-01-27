//
//  DynamicPropertyCache.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/1/10.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 49D2A32E637CD497C6DE29B8E060A506

internal import OpenGraphShims

struct DynamicPropertyCache {
    private static var cache = MutableBox([ObjectIdentifier: Fields]())
    
    // TODO
    static func fields(of type: Any.Type) -> Fields {
        if let fields = cache.value[ObjectIdentifier(type)] {
            return fields
        }
        let fields: Fields
        defer { cache.value[ObjectIdentifier(type)] = fields }
        let typeID = OGTypeID(type)
        switch typeID.kind {
        case .enum, .optional:
            var taggedFields: [TaggedFields] = []
            _ = typeID.forEachField(options: [._2, ._4]) { name, index, fieldType in
                var fields: [Field] = []
                let tupleType = OGTupleType(fieldType)
                for index in tupleType.indices {
                    guard let dynamicPropertyType = tupleType.type(at: index) as? DynamicProperty.Type else {
                        break
                    }
                    let offset = tupleType.offset(at: index)
                    let field = Field(type: dynamicPropertyType, offset: offset, name: name)
                    fields.append(field)
                }
                if !fields.isEmpty {
                    let taggedField = TaggedFields(tag: index, fields: fields)
                    taggedFields.append(taggedField)
                }
                return true
            }
            fields = Fields(layout: .sum(type, taggedFields))
            // TODO
        default:
            fatalError("TODO")
            break
        }
        Log.runtimeIssues("%s is marked async, but contains properties that require the main thread.", ["TODO"])
        return fields
    }
}

extension DynamicPropertyCache {
    struct Fields {
        var layout: Layout
        var behaviors: DynamicPropertyBehaviors

        enum Layout {
            case product([Field])
            case sum(Any.Type, [TaggedFields])
        }
        
        init(layout: Layout) {
            var behaviors: UInt32 = 0
            switch layout {
            case let .product(fields):
                for field in fields {
                    behaviors |= field.type._propertyBehaviors
                }
            case let .sum(_, taggedFields):
                for taggedField in taggedFields {
                    for field in taggedField.fields {
                        behaviors |= field.type._propertyBehaviors
                    }
                }
            }
            self.layout = layout
            self.behaviors = .init(rawValue: behaviors)
        }
    }
}

extension DynamicPropertyCache {
    struct Field {
        var type: DynamicProperty.Type
        var offset: Int
        var name: UnsafePointer<Int8>?
    }
}

extension DynamicPropertyCache {
    struct TaggedFields {
        var tag: Int
        var fields: [Field]
    }
}
