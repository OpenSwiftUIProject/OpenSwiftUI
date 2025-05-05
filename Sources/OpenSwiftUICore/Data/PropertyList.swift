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
        if let element = elements {
            // TO BE AUDITED in 2024
            elements = element.byPrepending(other.elements)
        } else {
            elements = other.elements
        }
    }
    
    // TO BE AUDITED in 2024 BEGIN
    
    package subscript<K>(key: K.Type) -> K.Value where K: PropertyKey {
        get {
            withExtendedLifetime(key) {
                guard let result = find(elements.map { .passUnretained($0) }, key: key) else {
                    return K.defaultValue
                }
                return result.takeUnretainedValue().value
            }
        }
        set {
            if let result = find(elements.map { .passUnretained($0) }, key: key) {
                guard !compareValues(
                    newValue,
                    result.takeUnretainedValue().value
                ) else {
                    return
                }
            }
            elements = TypedElement<K>(value: newValue, before: nil, after: elements)
        }
    }
    
    package subscript<K>(key: K.Type) -> K.Value where K: DerivedPropertyKey {
        // TODO
        K.value(in: self)
    }

    func valueWithSecondaryLookup<L>(_ key: L.Type) -> L.Primary.Value where L: PropertyKeyLookup {
        // TDOO
        self[L.Primary.self]
    }

    @usableFromInline
    package var description: String {
        var description = "["
        var shouldAddSeparator = false
        elements?.forEach { element, stop in
            let element = element.takeUnretainedValue()
            if shouldAddSeparator {
                description.append(", ")
            } else {
                shouldAddSeparator = true
            }
            description.append(element.description)
        }
        description.append("]")
        return description
    }
    
    func forEach<Key: PropertyKey>(keyType: Key.Type, _ body: (Key.Value, inout Swift.Bool) -> Void) {
        guard let elements else {
            return
        }
        elements.forEach { element, stop in
            let element = element.takeUnretainedValue()
            guard element.keyType == Key.self else {
                return
            }
            body((element as! TypedElement<Key>).value, &stop)
        }
    }
    
    func mayNotBeEqual(to: PropertyList) -> Bool {
        let equalResult: Bool
        if let elements {
            var ignoredTypes = Set<ObjectIdentifier>()
            equalResult = elements.isEqual(to: to.elements, ignoredTypes: &ignoredTypes)
        } else {
            equalResult = to.elements == nil
        }
        return !equalResult
    }
    
    mutating func merge(_ plist: PropertyList) {
        // preconditionFailure("TODO")
    }
}

@available(*, unavailable)
extension PropertyList: Sendable {}

// MARK: - PropertyList Help functions

private func find<Key: PropertyKey>(
    _ element: Unmanaged<PropertyList.Element>?,
    key: Key.Type,
    keyFilter: BloomFilter = BloomFilter(type: Key.self)
) -> Unmanaged<TypedElement<Key>>? {
    guard var element else {
        return nil
    }
    repeat {
        guard keyFilter.match(element.map(\.keyFilter)) else {
            return nil
        }
        if let before = element.map(\.before),
            let result = find(before, key: key, keyFilter: keyFilter) {
            return result
        }
        if element.map(\.keyType) == Key.self {
            return element.map { $0 as? TypedElement<Key> }
        }
        guard let after = element.map(\.after) else {
            break
        }
        element = after
    } while(true)
    return nil
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

// MARK: - PropertyList.Tracker Helper functions

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
        let keyType: Any.Type
        let before: Element?
        var after: Element?
        var skip: Unmanaged<Element>?
        let length: UInt32
        let skipCount: UInt32
        let keyFilter: BloomFilter // skipFilter
        let id = UniqueID()

        init(keyType: Any.Type, before: Element?, after: Element?) {
            self.keyType = keyType
            self.before = before
            self.after = after
            var length: UInt32 = 1
            var keyFilter = BloomFilter(type: keyType)
            if let before {
                length += before.length
                keyFilter.value |= before.keyFilter.value
            }
            if let after {
                length += after.length
                keyFilter.value |= after.keyFilter.value
            }
            self.skipCount = 0
            self.length = length
            self.keyFilter = keyFilter
        }
        
        @usableFromInline
        package var description: String { preconditionFailure("") }
        
        func matches(_: Element, ignoredTypes _: inout Set<ObjectIdentifier>) -> Bool {
            preconditionFailure("")
        }
        
        func hasMatchingValue(in _: Unmanaged<Element>?) -> Bool {
            preconditionFailure("")
        }
        
        func copy(before _: Element?, after _: Element?) -> Element {
            preconditionFailure("")
        }
        
        final package func byPrepending(_ element: Element?) -> Element {
            guard let element else {
                return self
            }
            return if before != nil {
                TypedElement<EmptyKey>(value: EmptyKey.defaultValue, before: element, after: self)
            } else {
                copy(before: element, after: after)
            }
        }
        
        final package func isEqual(to element: Element?, ignoredTypes: inout Set<ObjectIdentifier>) -> Bool {
            guard let element else {
                return false
            }
            guard length == element.length else {
                return false
            }
            guard self !== element else {
                return true
            }
            guard matches(element, ignoredTypes: &ignoredTypes) else {
                return false
            }
            var element1 = self
            var element2 = element
            repeat {
                if let before1 = element1.before {
                    guard before1.isEqual(to: element2.before, ignoredTypes: &ignoredTypes) else {
                        return false
                    }
                } else {
                    guard element2.before == nil else {
                        return false
                    }
                }
                if let after1 = element1.after {
                    guard let after2 = element2.after else {
                        return false
                    }
                    guard after1 !== after2 else {
                        return true
                    }
                    guard after1.isEqual(to: after2, ignoredTypes: &ignoredTypes) else {
                        return false
                    }
                    element1 = after1
                    element2 = after2
                } else {
                    return element.after == nil
                }
            } while(true)
        }
        
        final func forEach(_ body: (
            _ element: Unmanaged<Element>,
            _ stop: inout Bool
        ) -> Void) {
            var element = self
            var stop = false
            repeat {
                if let before = element.before {
                    before.forEach(body)
                }
                body(.passUnretained(element), &stop)
                guard !stop else { break }
                guard let after = element.after else {
                    break
                }
                element = after
            } while(true)
        }
    }
}

// MARK: - TypedElement

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
        guard compareValues(value, typedElement.value) else {
            return false
        }
        ignoredTypes.insert(ObjectIdentifier(Key.self))
        return true
    }
        
    override func copy(before: PropertyList.Element?, after: PropertyList.Element?) -> PropertyList.Element {
        TypedElement(value: value, before: before, after: after)
    }
}

// MARK: - EmptyKey

private struct EmptyKey: PropertyKey {
    static var defaultValue: Void { () }
}
