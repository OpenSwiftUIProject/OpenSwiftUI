//
//  PropertyList.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/18.
//  Lastest Version: iOS 15.5
//  Status: Empty
//  ID: 2B32D570B0B3D2A55DA9D4BFC1584D20

#if OPENSWIFTUI_ATTRIBUTEGRAPH
internal import AttributeGraph
#else
internal import OpenGraph
#endif

@usableFromInline
@frozen
struct PropertyList: CustomStringConvertible {
    @usableFromInline
    var elements: Element?
  
    @inlinable
    init() { elements = nil }
  
    // TODO: See Element implementatation
    @usableFromInline
    var description: String {
        var description = "["
        var elements = elements
        while let element = elements {
            description.append(element.description)
            elements = element.after
            if elements != nil {
                description.append(", ")
            }
        }
        description.append("]")
        return description
    }

    // TODO
    subscript<Key: PropertyKey>(_ key: Key.Type) -> Key.Value {
        get { fatalError("TODO") }
        set { fatalError("TODO") }
    }
}

extension PropertyList {
    @usableFromInline
    class Element: CustomStringConvertible {
        let keyType: Any.Type
        let before: Element?
        let after: Element?
        let length: Int
        let keyFilter: BloomFilter
        let id = OGUniqueID()

        init(keyType: Any.Type, before: Element?, after: Element?) {
            self.keyType = keyType
            self.before = before
            self.after = after
            var keyFilter = BloomFilter(type: keyType)
            var length = 0
            if let before {
                length = before.length + 1
                keyFilter.value |= before.keyFilter.value
            }
            if let after {
                length += after.length
                keyFilter.value |= after.keyFilter.value
            }
            self.length = length
            self.keyFilter = keyFilter
        }

        @usableFromInline
        var description: String { fatalError() }

        @usableFromInline
        deinit {}
        
        func matches(_: Element, ignoredTypes _: inout Set<ObjectIdentifier>) -> Bool {
            fatalError()
        }
        
        func copy(before _: Element?, after _: Element?) -> Element {
            fatalError()
        }
        
        final func byPrepending(_ element: Element?) -> Element {
            guard let element else {
                return self
            }
            if let before {
            } else {}
            return self
        }
        }
    }
}

private class TypedElement<Key: PropertyKey>: PropertyList.Element {
    var value: Key.Value
    
    init(value: Key.Value, before: PropertyList.Element?, after: PropertyList.Element?) {
        self.value = value
        super.init(keyType: Key.self, before: before, after: after)
    }
    
    override var description: String {
        "\(Key.self) = \(value)"
    }
    
    override func matches(_ element: PropertyList.Element, ignoredTypes: inout Set<ObjectIdentifier>) -> Bool {
        guard let typedElement = element as? TypedElement<Key> else {
            return false
        }
        
        guard !ignoredTypes.contains(ObjectIdentifier(Key.self)) else {
            return true
        }
        guard compareValues(value, typedElement.value, mode: ._3) else {
            return false
        }
        ignoredTypes.insert(ObjectIdentifier(Key.self))
        return true
    }
        
    override func copy(before: PropertyList.Element?, after: PropertyList.Element?) -> PropertyList.Element {
        TypedElement(value: value, before: before, after: after)
    }
}

extension PropertyList {
    class Tracker {
        @UnsafeLockedPointer
        private var data: TrackerData
        
        init() {
            _data = UnsafeLockedPointer(wrappedValue: .init(
                plistID: .zero,
                values: [:],
                derivedValues: [:],
                invalidValues: [],
                unrecordedDependencies: false
            ))
        }
        
        deinit {
            $data.destroy()
        }
        
        func initializeValues(from _: PropertyList) {
        }
        
        func invalidateValue(for _: (some PropertyKey).Type, from _: PropertyList, to _: PropertyList) {}
        
        func invalidateAllValues(from _: PropertyList, to _: PropertyList) {}
    
        func hasDifferentUsedValues(_: PropertyList) -> Bool {
            .random()
        }
    }
}

private struct TrackerData {
    var plistID: UniqueID
    var values: [ObjectIdentifier: AnyTrackedValue]
    var derivedValues: [ObjectIdentifier: AnyTrackedValue]
    var invalidValues: [AnyTrackedValue]
    var unrecordedDependencies: Bool
}

private protocol AnyTrackedValue {
    func unwrap<Value>() -> Value
    func hasMatchingValue(in: PropertyList) -> Bool
}

private struct TrackedValue<Key: PropertyKey>: AnyTrackedValue {
    var value: Key.Value

    func unwrap<Value>() -> Value {
        value as! Value
    }

    func hasMatchingValue(in plist: PropertyList) -> Bool {
        compareValues(value, plist[Key.self])
    }
}

private struct DerivedValue<Key: DerivedPropertyKey>: AnyTrackedValue {
    var value: Key.Value

    func unwrap<Value>() -> Value {
        value as! Value
    }

    func hasMatchingValue(in plist: PropertyList) -> Bool {
        value == Key.value(in: plist)
    }
}

private struct EmptyKey: PropertyKey {
    static var defaultValue: Void { () }
}
