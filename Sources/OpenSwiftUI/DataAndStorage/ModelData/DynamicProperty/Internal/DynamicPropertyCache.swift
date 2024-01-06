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
        let kind = OGTypeID(type).kind
        switch kind {
        case .enum, .optional:
            break
        default:
            break
        }
        Log.runtimeIssues("%s is marked async, but contains properties that require the main thread.", ["TODO"])
        return .init(layout: .product([]))
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
            self.layout = layout
            // FIXME
            self.behaviors = .init(rawValue: 0)
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
        var name: UnsafePointer<Int8>?
    }
}
