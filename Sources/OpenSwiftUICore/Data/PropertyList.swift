//
//  PropertyList.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by merge & WIP in 2024
//  ID: 2B32D570B0B3D2A55DA9D4BFC1584D20 (SwiftUI)
//  ID: D64CE6C88E7413721C59A34C0C940F2C (SwiftUICore)

import OpenSwiftUI_SPI
import OpenGraphShims

// MARK: - PropertyKey

package protocol PropertyKey {
    associatedtype Value

    static var defaultValue: Value { get }

    static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool
}

extension PropertyKey where Value: Equatable {
    package static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        lhs == rhs
    }
}

extension PropertyKey {
    package static func valuesEqual(_ lhs: Value, _ rhs: Value) -> Bool {
        compareValues(lhs, rhs)
    }
}

// MARK: - DerivedPropertyKey

package protocol DerivedPropertyKey {
    associatedtype Value: Equatable

    static func value(in: PropertyList) -> Value
}

// MARK: - PropertyKeyLookup

package protocol PropertyKeyLookup {
    associatedtype Primary: PropertyKey

    associatedtype Secondary: PropertyKey

    static func lookup(in: Secondary.Value) -> Primary.Value?
}

// MARK: - PropertyList

/// A mutable container of key-value pairs
@usableFromInline
@frozen
package struct PropertyList: CustomStringConvertible {
    @usableFromInline
    var elements: Element?

    @inlinable
    package init() {
        elements = nil
    }

    package init(data: AnyObject?) {
        guard let data else {
            return
        }
        elements = (data as! Element)
    }

    @inlinable
    package var data: AnyObject? { elements }

    @inlinable
    package var isEmpty: Bool {
        elements === nil
    }

    package var id: UniqueID {
        elements?.id ?? .invalid
    }

    package mutating func override(with other: PropertyList) {
        let newElements: Element?
        if let elements {
            if let otherElements = other.elements {
                if elements.before != nil {
                    newElements = TypedElement<EmptyKey>(value: (), before: otherElements, after: elements)
                } else {
                    newElements = elements.copy(before: otherElements, after: elements.after)
                }
            } else {
                newElements = elements
            }
        } else {
            newElements = other.elements
        }
        elements = newElements
    }

    package subscript<K>(key: K.Type) -> K.Value where K: PropertyKey {
        get {
            withExtendedLifetime(elements) {
                guard let result = find(
                    elements.map { .passUnretained($0) },
                    key: key
                ) else {
                    return K.defaultValue
                }
                return result.takeUnretainedValue().value
            }
        }
        set {
            guard let result = find(
                elements.map { .passUnretained($0) },
                key: key
            ), K.valuesEqual(newValue, result.takeUnretainedValue().value)
            else {
                elements = TypedElement<K>(value: newValue, before: nil, after: elements)
                return
            }
        }
    }

    package subscript<K>(key: K.Type) -> K.Value where K: DerivedPropertyKey {
        K.value(in: self)
    }

    package func valueWithSecondaryLookup<L>(_ key: L.Type) -> L.Primary.Value where L: PropertyKeyLookup {
        // TDOO
        self[L.Primary.self]
    }

    // TODO
    package mutating func prependValue<K>(_ value: K.Value, for key: K.Type) where K: PropertyKey {
        preconditionFailure("TODO")
    }

    // TODO
    package func mayNotBeEqual(to: PropertyList) -> Bool {
        preconditionFailure("TODO")
//        let equalResult: Bool
//        if let elements {
//            var ignoredTypes = Set<ObjectIdentifier>()
//            equalResult = elements.isEqual(to: to.elements, ignoredTypes: &ignoredTypes)
//        } else {
//            equalResult = to.elements == nil
//        }
//        return !equalResult
    }

    // TODO
    @_transparent
    package mutating func set(_ other: PropertyList) {
        preconditionFailure("TODO")
    }

    @usableFromInline
    package var description: String {
        var description = "["
        var index = 0
        if let elements {
            elements.forEach(filter: BloomFilter()) { element, stop in
                if index != 0 {
                    description.append(", ")
                }
                description.append(element.takeUnretainedValue().description)
                index += 1
            }
        }
        description.append("]")
        return description
    }

    // TODO
    package func forEach<K>(keyType: K.Type, _ body: (K.Value, inout Bool) -> Void) where K: PropertyKey {
        preconditionFailure("TODO")

//        guard let elements else {
//            return
//        }
//        elements.forEach { element, stop in
//            let element = element.takeUnretainedValue()
//            guard element.keyType == K.self else {
//                return
//            }
//            body((element as! TypedElement<K>).value, &stop)
//        }
    }

    package mutating func merge(_ plist: PropertyList) {
//         preconditionFailure("TODO")
    }

    package func merging(_ other: PropertyList) -> PropertyList {
         preconditionFailure("TODO")
    }

    package static func value<T>(as _: T.Type, from element: Element) -> T {
        element.value(as: T.self)
    }
}

@available(*, unavailable)
extension PropertyList: Sendable {}

// MARK: - PropertyList Helper Functions

private func find<Key>(
    _ element: Unmanaged<PropertyList.Element>?,
    key: Key.Type,
) -> Unmanaged<TypedElement<Key>>? where Key: PropertyKey {
    find1(element, key: key, filter: BloomFilter(type: key))
}

private func find1<Key>(
    _ element: Unmanaged<PropertyList.Element>?,
    key: Key.Type,
    filter: BloomFilter
) -> Unmanaged<TypedElement<Key>>? where Key: PropertyKey {
    guard let element else {
        return nil
    }
    var currentElement = element.takeUnretainedValue()
    repeat {
        guard currentElement.skipFilter.mayContain(filter) else {
            if currentElement.skip != nil {
                continue
            } else {
                return nil
            }
        }
        if let before = currentElement.before {
            let result = find1(.passUnretained(before), key: key, filter: filter)
            if let result { return result }
        }
        if currentElement.keyType == Key.self {
            return .fromOpaque(Unmanaged.passUnretained(currentElement).toOpaque())
        }
        guard let after = currentElement.after else {
            return nil
        }
        currentElement = after
    } while(true)
}

// MARK: - PropertyList.Tracker

extension PropertyList {
    @usableFromInline
    package class Tracker {
        @AtomicBox
        private var data: TrackerData

        package init() {
            _data = AtomicBox(wrappedValue: .init(
                plistID: .invalid,
                values: [:],
                derivedValues: [:],
                invalidValues: [],
                unrecordedDependencies: false
            ))
        }

        final package func reset() {
            $data.access { data in
                data.plistID = .invalid
                data.values.removeAll(keepingCapacity: true)
                data.derivedValues.removeAll(keepingCapacity: true)
                data.invalidValues.removeAll(keepingCapacity: true)
                data.unrecordedDependencies = false
            }
        }

        final package func value<K>(_ plist: PropertyList, for key: K.Type) -> K.Value where K: PropertyKey {
            $data.access { data in
                guard data.plistID == plist.id else {
                    data.unrecordedDependencies = true
                    return plist[K.self]
                }
                let keyID = ObjectIdentifier(K.self)
                guard let trackedValue = data.values[keyID] else {
                    let value = plist[K.self]
                    let trackedValue = TrackedValue<K>(value: value)
                    data.values[keyID] = trackedValue
                    return value
                }
                return trackedValue.unwrap()
            }
        }

        final package func valueWithSecondaryLookup<Lookup>(_ plist: PropertyList, secondaryLookupHandler: Lookup.Type) -> Lookup.Primary.Value where Lookup: PropertyKeyLookup {
            $data.access { data in
                guard data.plistID == plist.id else {
                    data.unrecordedDependencies = true
                    return plist.valueWithSecondaryLookup(secondaryLookupHandler)
                }
                let keyID = ObjectIdentifier(Lookup.Primary.self)
                guard let trackedValue = data.values[keyID] else {
                    let value = plist.valueWithSecondaryLookup(secondaryLookupHandler)
                    let trackedValue = SecondaryLookupTrackedValue<Lookup>(value: value)
                    data.values[keyID] = trackedValue
                    return value
                }
                return trackedValue.unwrap()
            }
        }

        final package func derivedValue<K>(_ plist: PropertyList, for key: K.Type) -> K.Value where K: DerivedPropertyKey {
            $data.access { data in
                guard data.plistID == plist.id else {
                    data.unrecordedDependencies = true
                    return K.value(in: plist)
                }
                let keyID = ObjectIdentifier(K.self)
                guard let trackedValue = data.derivedValues[keyID] else {
                    let value = K.value(in: plist)
                    let derivedValue = DerivedValue<K>(value: value)
                    data.derivedValues[keyID] = derivedValue
                    return value
                }
                return trackedValue.unwrap()
            }
        }

        final package func initializeValues(from plist: PropertyList) {
            data.plistID = plist.id
        }

        final package func invalidateValue<K>(for key: K.Type, from oldPlist: PropertyList, to newPlist: PropertyList) where K: PropertyKey {
            $data.access { data in
                guard data.plistID == oldPlist.id, data.plistID != newPlist.id else {
                    return
                }
                let removedValue = data.values.removeValue(forKey: ObjectIdentifier(K.self))
                if let removedValue {
                    data.invalidValues.append(removedValue)
                }
                move(&data.derivedValues, to: &data.invalidValues)
                data.plistID = newPlist.id
            }
        }

        final package func invalidateAllValues(from oldPlist: PropertyList, to newPlist: PropertyList) {
            $data.access { data in
                guard data.plistID == oldPlist.id, data.plistID != newPlist.id else {
                    return
                }
                move(&data.values, to: &data.invalidValues)
                move(&data.derivedValues, to: &data.invalidValues)
                data.plistID = newPlist.id
            }
        }

        final package func hasDifferentUsedValues(_ plist: PropertyList) -> Bool {
            let data = data
            guard !data.unrecordedDependencies else {
                return true
            }
            guard data.plistID != plist.id else {
                return false
            }
            guard compare(data.values, against: plist) else {
                return true
            }
            guard compare(data.derivedValues, against: plist) else {
                return true
            }
            for invalidValue in data.invalidValues {
                guard invalidValue.hasMatchingValue(in: plist) else {
                    return true
                }
                continue
            }
            return false
        }

        final package func formUnion(_ other: Tracker) {
            data.formUnion(other.data)
        }
    }
}

@available(*, unavailable)
extension PropertyList.Tracker: Sendable {}

// MARK: - PropertyList.Tracker Helper Functions

@inline(never)
private func move(_ source: inout [ObjectIdentifier: any AnyTrackedValue], to destination: inout [any AnyTrackedValue]) {
    guard !source.isEmpty else { return }
    destination.append(contentsOf: source.values)
    source.removeAll(keepingCapacity: true)
}

@inline(never)
private func compare(_ values: [ObjectIdentifier: any AnyTrackedValue], against plist: PropertyList) -> Bool {
    for (_, value) in values {
        guard value.hasMatchingValue(in: plist) else {
            return false
        }
    }
    return true
}

// MARK: - TrackerData

private struct TrackerData {
    var plistID: UniqueID
    var values: [ObjectIdentifier: any AnyTrackedValue]
    var derivedValues: [ObjectIdentifier: any AnyTrackedValue]
    var invalidValues: [any AnyTrackedValue]
    var unrecordedDependencies: Bool

    mutating func formUnion(_ other: TrackerData) {
        guard other.plistID != .invalid && plistID != other.plistID else {
            return
        }
        if plistID == .invalid {
            plistID = other.plistID
            values = other.values
            derivedValues = other.derivedValues
            invalidValues = other.invalidValues
            unrecordedDependencies = other.unrecordedDependencies
        } else {
            plistID = other.plistID
            values.merge(other.values) { first, _ in first }
            derivedValues.merge(other.derivedValues) { first, _ in first }
            invalidValues.append(contentsOf: other.invalidValues)
            unrecordedDependencies = unrecordedDependencies || other.unrecordedDependencies
        }
    }
}

// MARK: - AnyTrackedValue

private protocol AnyTrackedValue {
    func unwrap<Value>() -> Value
    func hasMatchingValue(in: PropertyList) -> Bool
}

// MARK: - TrackedValue

private struct TrackedValue<Key>: AnyTrackedValue where Key: PropertyKey {
    var value: Key.Value

    func unwrap<Value>() -> Value {
        unsafeBitCast(value, to: Value.self)
    }

    func hasMatchingValue(in plist: PropertyList) -> Bool {
        Key.valuesEqual(value, plist[Key.self])
    }
}

// MARK: - DerivedValue

private struct DerivedValue<Key>: AnyTrackedValue where Key: DerivedPropertyKey {
    var value: Key.Value

    func unwrap<Value>() -> Value {
        unsafeBitCast(value, to: Value.self)
    }

    func hasMatchingValue(in plist: PropertyList) -> Bool {
        value == Key.value(in: plist)
    }
}

private struct SecondaryLookupTrackedValue<Lookup>: AnyTrackedValue where Lookup: PropertyKeyLookup {
    var value: Lookup.Primary.Value

    init(value: Lookup.Primary.Value) {
        self.value = value
    }

    func unwrap<Value>() -> Value {
        unsafeBitCast(value, to: Value.self)
    }

    func hasMatchingValue(in plist: PropertyList) -> Bool {
        Lookup.Primary.valuesEqual(value, plist.valueWithSecondaryLookup(Lookup.self))
    }
}

// MARK: - PropertyList.Element

extension PropertyList {
    @usableFromInline
    package class Element: CustomStringConvertible {
        let keyType: any Any.Type
        let before: Element?
        var after: Element?
        var skip: Unmanaged<Element>?
        let length: UInt32
        let skipCount: UInt32
        let skipFilter: BloomFilter
        let id = UniqueID()

        fileprivate init(keyType: any Any.Type, before: Element?, after: Element?) {
            self.keyType = keyType
            self.before = before
            self.after = after

            var filter = BloomFilter(type: keyType)
            if let before {
                var length = before.length + 1
                if let after { length += after.length }
                self.length = length
                self.skipCount = 0
                filter.value = .max
                self.skipFilter = filter
                self.skip = .passUnretained(self)
            } else {
                if let after {
                    let length = after.length + 1
                    if after.skipCount > 15 {
                        self.length = length
                        self.skipCount = 1
                        self.skipFilter = filter
                        self.skip = .passUnretained(after)
                    } else {
                        self.length = length
                        self.skipCount = after.skipCount &+ 1
                        self.skipFilter = after.skipFilter.union(filter)
                        self.skip = after.skip
                    }
                } else {
                    self.length = 1
                    self.skipCount = 1
                    self.skipFilter = filter
                    self.skip = nil
                }
            }
        }

        @discardableResult
        final func forEach(
            filter: BloomFilter,
            _ body: (Unmanaged<Element>, inout Bool) -> Void
        ) -> Bool {
            var currentElement = self
            var stop = false
            repeat {
                guard currentElement.skipFilter.mayContain(filter) else {
                    if currentElement.skip != nil {
                        continue
                    } else {
                        return true
                    }
                }
                if let before = currentElement.before {
                    let result = before.forEach(filter: filter, body)
                    stop = !result
                    guard result else { return false }
                }
                _ = body(.passUnretained(currentElement), &stop)
                guard !stop else { return false }
                guard let after = currentElement.after else {
                    return true
                }
                currentElement = after
            } while(true)
        }

        @usableFromInline
        package var description: String { preconditionFailure("") }

        func matches(_ other: Element, ignoredTypes: inout [ObjectIdentifier]) -> Bool {
            preconditionFailure("")
        }

        func copy(before: Element?, after: Element?) -> Element {
            preconditionFailure("")
        }

        func value<T>(as type: T.Type) -> T {
            preconditionFailure("")
        }
//
//        final func isEqual(to element: Element?, ignoredTypes: inout Set<ObjectIdentifier>) -> Bool {
//            guard let element else {
//                return false
//            }
//            guard length == element.length else {
//                return false
//            }
//            guard self !== element else {
//                return true
//            }
//            guard matches(element, ignoredTypes: &ignoredTypes) else {
//                return false
//            }
//            var element1 = self
//            var element2 = element
//            repeat {
//                if let before1 = element1.before {
//                    guard before1.isEqual(to: element2.before, ignoredTypes: &ignoredTypes) else {
//                        return false
//                    }
//                } else {
//                    guard element2.before == nil else {
//                        return false
//                    }
//                }
//                if let after1 = element1.after {
//                    guard let after2 = element2.after else {
//                        return false
//                    }
//                    guard after1 !== after2 else {
//                        return true
//                    }
//                    guard after1.isEqual(to: after2, ignoredTypes: &ignoredTypes) else {
//                        return false
//                    }
//                    element1 = after1
//                    element2 = after2
//                } else {
//                    return element.after == nil
//                }
//            } while(true)
//        }
    }
}

@available(*, unavailable)
extension PropertyList.Element: Sendable {}

// MARK: - TypedElement

private class TypedElement<Key>: PropertyList.Element where Key: PropertyKey {
    let value: Key.Value

    init(value: Key.Value, before: PropertyList.Element?, after: PropertyList.Element?) {
        self.value = value
        super.init(keyType: Key.self, before: before, after: after)
    }

    override var description: String {
        "\(Key.self) = \(value)"
    }

    override func matches(_ other: PropertyList.Element, ignoredTypes: inout [ObjectIdentifier]) -> Bool {
        guard other.keyType == keyType else {
            return false
        }
        let keyID = ObjectIdentifier(Key.self)
        guard !ignoredTypes.contains(keyID) else {
            return true
        }
        guard Key.valuesEqual(value, other.value(as: Key.Value.self)) else {
            return false
        }
        ignoredTypes.append(keyID)
        return true
    }

    override func copy(before: PropertyList.Element?, after: PropertyList.Element?) -> PropertyList.Element {
        TypedElement(value: value, before: before, after: after)
    }

    override func value<T>(as type: T.Type) -> T {
        unsafeBitCast(value, to: type)
    }
}

// MARK: - EmptyKey

private struct EmptyKey: PropertyKey {
    static var defaultValue: Void { () }
}
