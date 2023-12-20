//
//  PropertyList.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/18.
//  Lastest Version: iOS 15.5
//  Status: Empty
//  ID: 2B32D570B0B3D2A55DA9D4BFC1584D20

#if OPENSWIFTUI_USE_AG
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
        // 0x10
        let keyType: Any.Type
        // 0x18
        let before: Element?
        // 0x20
        let after: Element?
        let length: Int
        let keyFilter: BloomFilter
        let id: UniqueID

        init(keyType: Any.Type, before: Element?, after: Element?, length: Int, keyFilter: BloomFilter, id: UniqueID) {
            self.keyType = keyType
            self.before = before
            self.after = after
            self.length = length
            self.keyFilter = keyFilter
            self.id = id
        }

        @usableFromInline
        var description: String {
            ""
        }

        /*@objc*/
        @usableFromInline
        deinit {}

        func byPrepending(_ element: Element?) -> Element {
            self
        }
    }
}

// extension PropertyList {
//    class Tracker {
//        @UnsafeLockedPointer
//        var data: TrackerData // 0x10
//    }
// }


private struct TrackerData {
    var plistID: UniqueID
    var values: [ObjectIdentifier : AnyTrackedValue]
    var derivedValues: [ObjectIdentifier : AnyTrackedValue]
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
