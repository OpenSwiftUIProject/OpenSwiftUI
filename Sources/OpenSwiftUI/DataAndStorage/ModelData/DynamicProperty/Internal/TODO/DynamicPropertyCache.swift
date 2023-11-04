
struct DynamicPropertyCache {
    // TODO
    static func fields(of: Any.Type) -> Fields {
        .init(layout: .product([]), behaviors: [])
    }
}

extension DynamicPropertyCache {
    struct Field {
        var type: DynamicProperty.Type
        var offset: Int
        var name: UnsafePointer<Int8>?
    }

    struct Fields {
        var layout: Layout
        var behaviors: DynamicPropertyBehaviors

        enum Layout {
            case product([Field])
            case sum(Any.Type, [TaggedFields])
        }
    }
}

extension DynamicPropertyCache {
    struct TaggedFields {
        var tag: Int
        var fields: [Field]
        var name: UnsafePointer<Int8>?
    }
}


struct DynamicPropertyBehaviors: OptionSet {
    let rawValue: UInt32
}
