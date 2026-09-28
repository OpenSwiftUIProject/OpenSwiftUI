//
//  AccessibilityNullableOptionSet.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3F072AF2D37E4BBD060A42F9AFFB5042 (SwiftUICore?)

package struct AccessibilityNullableOptionSet<T>: Equatable, Hashable, Codable
where T: Codable & Hashable & OptionSet, T.RawValue: Codable & FixedWidthInteger & UnsignedInteger {
    package private(set) var value: T
    package private(set) var mask: T

    package init() {
        value = T()
        mask = T()
    }

    package init(implying bits: T.Element...) {
        value = T(bits)
        mask = T()
    }

    package init(adding bits: T.Element...) {
        value = T(bits)
        mask = value
    }

    package init(removing bits: T.Element...) {
        value = T()
        mask = T(bits)
    }

    package init(adding: T.Element..., removing: T.Element...) {
        value = T(adding)
        mask = value
        mask.formUnion(T(removing))
    }

    package subscript(bit: T.Element, default defaultValue: Bool) -> Bool {
        self[bit] ?? defaultValue
    }

    package subscript(bit: T.Element) -> Bool? {
        get {
            if value.contains(bit) {
                return true
            }
            return mask.contains(bit) ? false : nil
        }
        set {
            if let newValue {
                mask.insert(bit)
                if newValue {
                    value.insert(bit)
                } else {
                    value.remove(bit)
                }
            } else {
                mask.remove(bit)
                value.remove(bit)
            }
        }
    }

    package var isDefault: Bool {
        mask.isEmpty && value.isEmpty
    }

    package func isSet(_ bit: T.Element) -> Bool {
        mask.contains(bit)
    }
}

extension AccessibilityNullableOptionSet: CustomStringConvertible {
    package var description: String {
        "AccessibilityNullableOptionSet"
    }
}

extension AccessibilityNullableOptionSet: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with other: Self) -> Bool {
        let newValue = other.value.subtracting(mask)
        let newMask = other.mask.subtracting(mask)
        mask.formUnion(other.mask)
        value.subtract(newMask)
        value.formUnion(newValue)
        return newValue.isEmpty || newMask.isEmpty
    }
}

extension AccessibilityNullableOptionSet: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.uint64Field(1, UInt64(value.rawValue))
        encoder.uint64Field(2, UInt64(mask.rawValue))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                value = T(rawValue: T.RawValue(try decoder.uint64Field(field)))
            case 2:
                mask = T(rawValue: T.RawValue(try decoder.uint64Field(field)))
            default:
                try decoder.skipField(field)
            }
        }
    }
}
