//
//  PropertyList.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 2B32D570B0B3D2A55DA9D4BFC1584D20 (SwiftUI)
//  ID: D64CE6C88E7413721C59A34C0C940F2C (SwiftUICore)

import OpenSwiftUI_SPI
import OpenGraphShims

// MARK: - PropertyKey

/// A protocol that defines a key for use in a PropertyList.
/// 
/// Types conforming to PropertyKey serve as strongly-typed keys with associated values
/// that can be stored and retrieved from a PropertyList.
package protocol PropertyKey {
    /// The type of value associated with this key.
    associatedtype Value

    /// The default value to return when no value is found for this key in a PropertyList.
    static var defaultValue: Value { get }

    /// Compares two values of this key's type for equality.
    ///
    /// - Parameters:
    ///   - lhs: The first value to compare.
    ///   - rhs: The second value to compare.
    /// - Returns: `true` if the values are equal, otherwise `false`.
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

/// A protocol that defines a key for a value derived from other values in a PropertyList.
///
/// Types conforming to DerivedPropertyKey can compute their values based on 
/// other values stored in a PropertyList.
package protocol DerivedPropertyKey {
    /// The type of value associated with this key.
    associatedtype Value: Equatable

    /// Computes the derived value from the provided PropertyList.
    ///
    /// - Parameter list: The PropertyList from which to derive the value.
    /// - Returns: The derived value.
    static func value(in: PropertyList) -> Value
}

// MARK: - PropertyKeyLookup

/// A protocol that defines a relationship between two property keys.
///
/// Types conforming to PropertyKeyLookup provide a way to look up a primary value
/// using a secondary value from a PropertyList.
package protocol PropertyKeyLookup {
    /// The primary key type used for the lookup result.
    associatedtype Primary: PropertyKey

    /// The secondary key type used for the lookup source.
    associatedtype Secondary: PropertyKey

    /// Looks up a primary value from a secondary value.
    ///
    /// - Parameter secondaryValue: The secondary value to use for lookup.
    /// - Returns: The primary value if found, or `nil` if not found.
    static func lookup(in: Secondary.Value) -> Primary.Value?
}

// MARK: - PropertyList

/// A mutable container of key-value pairs.
///
/// PropertyList provides a type-safe way to store and retrieve values using keys
/// that conform to `PropertyKey`. It efficiently manages the storage of multiple
/// property values and supports value overriding and merging operations.
@usableFromInline
@frozen
package struct PropertyList: CustomStringConvertible {
    @usableFromInline
    var elements: Element?

    /// Creates an empty PropertyList.
    @inlinable
    package init() {
        elements = nil
    }

    /// Creates a PropertyList with the specified data.
    ///
    /// - Parameter data: The data object to initialize the PropertyList with.
    package init(data: AnyObject?) {
        guard let data else {
            return
        }
        elements = (data as! Element)
    }

    /// The underlying data object of the PropertyList.
    @inlinable
    package var data: AnyObject? { elements }

    /// Returns a Boolean value indicating whether the PropertyList is empty.
    ///
    /// - Returns: `true` if the PropertyList contains no elements, otherwise `false`.
    @inlinable
    package var isEmpty: Bool {
        elements === nil
    }

    @inlinable
    package func isIdentical(to other: PropertyList) -> Bool {
        elements === other.elements
    }

    /// The unique identifier for this PropertyList.
    ///
    /// - Returns: A UniqueID that identifies this PropertyList, or `.invalid` if empty.
    package var id: UniqueID {
        elements?.id ?? .invalid
    }

    /// Overrides the current PropertyList with values from another PropertyList.
    ///
    /// This method gives priority to values from the other PropertyList when both
    /// PropertyLists contain values for the same key.
    ///
    /// - Parameter other: The PropertyList to override with.
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

    /// Gets or sets the value for the specified key type.
    ///
    /// When getting a value, returns the stored value for the key, or the key's default value
    /// if no value is stored. When setting a value, stores the new value only if it's different
    /// from the current value.
    ///
    /// - Parameter key: The key type to get or set the value for.
    /// - Returns: The value associated with the key.
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
                prependValue(newValue, for: key)
                return
            }
        }
    }

    /// Gets the derived value for the specified key type.
    ///
    /// - Parameter key: The derived key type to get the value for.
    /// - Returns: The derived value associated with the key.
    package subscript<K>(key: K.Type) -> K.Value where K: DerivedPropertyKey {
        K.value(in: self)
    }

    /// Gets a value using a secondary lookup.
    ///
    /// Searches for a value using the specified lookup handler to convert between
    /// primary and secondary keys.
    ///
    /// - Parameter key: The lookup handler type to use for the search.
    /// - Returns: The primary value if found, or the primary key's default value if not found.
    package func valueWithSecondaryLookup<L>(_ key: L.Type) -> L.Primary.Value where L: PropertyKeyLookup {
        withExtendedLifetime(elements) {
            guard let result = findValueWithSecondaryLookup(
                elements.map { .passUnretained($0) },
                secondaryLookupHandler: key,
                filter: BloomFilter(type: L.Primary.self),
                secondaryFilter: BloomFilter(type: L.Secondary.self)
            ) else {
                return L.Primary.defaultValue
            }
            return result
        }
    }

    /// Prepends a value to the PropertyList for the specified key.
    ///
    /// - Parameters:
    ///   - value: The value to prepend.
    ///   - key: The key type to associate with the value.
    package mutating func prependValue<K>(_ value: K.Value, for key: K.Type) where K: PropertyKey {
        elements = TypedElement<K>(value: value, before: nil, after: elements)
    }

    /// Checks if this PropertyList might not be equal to another PropertyList.
    ///
    /// - Parameter other: The PropertyList to compare with.
    /// - Returns: `true` if the PropertyLists might not be equal, otherwise `false`.
    package func mayNotBeEqual(to other: PropertyList) -> Bool {
        var ignoredTypes = [ObjectIdentifier]()
        return mayNotBeEqual(to: other, ignoredTypes: &ignoredTypes)
    }

    /// Checks if this PropertyList might not be equal to another PropertyList, ignoring specified types.
    ///
    /// - Parameters:
    ///   - other: The PropertyList to compare with.
    ///   - ignoredTypes: Types to ignore during comparison.
    /// - Returns: `true` if the PropertyLists might not be equal, otherwise `false`.
    package func mayNotBeEqual(to other: PropertyList, ignoredTypes: inout [ObjectIdentifier]) -> Bool {
        guard let elements,
              let otherElements = other.elements else {
            return !isEmpty || !other.isEmpty
        }
        return !compareLists(
            .passUnretained(elements),
            .passUnretained(otherElements),
            ignoredTypes: &ignoredTypes
        )
    }

    /// Sets this PropertyList to be the same as another PropertyList.
    ///
    /// - Parameter other: The PropertyList to set from.
    @_transparent
    package mutating func set(_ other: PropertyList) {
        guard other.elements !== elements else {
            return
        }
        elements = other.elements
    }

    /// A textual representation of the PropertyList.
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

    /// Iterates through all values of a specific key type in the PropertyList.
    ///
    /// - Parameters:
    ///   - keyType: The key type to filter values by.
    ///   - body: A closure to execute for each matching value. Set the second parameter to `true` to stop iteration.
    package func forEach<K>(keyType: K.Type, _ body: (K.Value, inout Bool) -> Void) where K: PropertyKey {
        guard let elements else {
            return
        }
        elements.forEach(filter: BloomFilter(type: K.self)) { element, stop in
            guard element.takeUnretainedValue().keyType == K.self else {
                return
            }
            body(Unmanaged<TypedElement<K>>.fromOpaque(element.toOpaque()).takeUnretainedValue().value, &stop)
        }
    }

    /// Merges another PropertyList into this PropertyList.
    ///
    /// - Parameter other: The PropertyList to merge from.
    package mutating func merge(_ other: PropertyList) {
        guard let selfElements = self.elements else {
            elements = other.elements
            return
        }
        guard let otherElements = other.elements else {
            return
        }
        guard elements !== otherElements else {
            return
        }
        var copyCount = 0
        var currentSelfElement = selfElements
        var currentOptionalSelfElement: Element? = elements
        var currentOtherElement = otherElements
        var currentOptinoalOtherElement: Element? = otherElements
        repeat {
            if currentOtherElement.length >= currentSelfElement.length {
                copyCount += 1
                currentOptinoalOtherElement = currentOtherElement.after
                if let after = currentOtherElement.after {
                    currentOtherElement = after
                    continue
                } else {
                    break
                }
            } else {
                currentOptionalSelfElement = currentSelfElement.after
                if let after = currentSelfElement.after {
                    currentSelfElement = after
                    continue
                } else {
                    break
                }
            }
        } while currentSelfElement !== currentOtherElement
        guard let currentOptionalSelfElement,
              let currentOptinoalOtherElement,
              currentOptionalSelfElement === currentOptinoalOtherElement
        else {
            override(with: other)
            return
        }
        guard currentOptionalSelfElement !== otherElements else {
            return
        }
        guard currentOptionalSelfElement !== selfElements else {
            elements = otherElements
            return
        }
        guard copyCount != 0 else {
            return
        }
        withUnsafeTuple(of: TupleType(Element.self), count: copyCount) { tuple in
            let pointer = tuple.address(as: Element.self)
            var current: Element! = otherElements
            for index in 0 ..< copyCount {
                pointer[index] = current
                current = current.after
            }
            for index in 0 ..< copyCount {
                let element = pointer[copyCount - index - 1]
                elements = element.copy(before: element.before, after: elements)
            }
        }
    }

    /// Creates a new PropertyList by merging this PropertyList with another.
    ///
    /// - Parameter other: The PropertyList to merge with.
    /// - Returns: A new PropertyList containing values from both PropertyLists.
    package func merging(_ other: PropertyList) -> PropertyList {
        var value = self
        value.merge(other)
        return value
    }

    /// Extracts a value of the specified type from an Element.
    ///
    /// - Parameters:
    ///   - type: The type to extract the value as.
    ///   - element: The Element to extract the value from.
    /// - Returns: The extracted value.
    package static func value<T>(as _: T.Type, from element: Element) -> T {
        element.value(as: T.self)
    }
}

@available(*, unavailable)
extension PropertyList: Sendable {}

// MARK: - PropertyList Helper Functions

private func find<Key>(
    _ element: Unmanaged<PropertyList.Element>?,
    key: Key.Type
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
    } while true
}

private func findValueWithSecondaryLookup<Lookup>(
    _ element: Unmanaged<PropertyList.Element>?,
    secondaryLookupHandler: Lookup.Type,
    filter: BloomFilter,
    secondaryFilter: BloomFilter
) -> Lookup.Primary.Value? where Lookup: PropertyKeyLookup {
    guard let element else {
        return nil
    }
    var currentElement = element.takeUnretainedValue()
    repeat {
        let skipFilter = currentElement.skipFilter
        guard skipFilter.mayContain(filter) || skipFilter.mayContain(secondaryFilter) else {
            if currentElement.skip != nil {
                continue
            } else {
                return nil
            }
        }
        if let before = currentElement.before {
            let result = findValueWithSecondaryLookup(
                .passUnretained(before),
                secondaryLookupHandler: secondaryLookupHandler,
                filter: filter,
                secondaryFilter: secondaryFilter
            )
            if let result { return result }
        }
        let keyType = currentElement.keyType
        if keyType == Lookup.Primary.self {
            let element: Unmanaged<TypedElement<Lookup.Primary>> = .fromOpaque(Unmanaged.passUnretained(currentElement).toOpaque())
            return element.takeUnretainedValue().value
        } else if keyType == Lookup.Secondary.self {
            let element: Unmanaged<TypedElement<Lookup.Secondary>> = .fromOpaque(Unmanaged.passUnretained(currentElement).toOpaque())
            if let value = Lookup.lookup(in: element.takeUnretainedValue().value) {
                return value
            }
        }
        guard let after = currentElement.after else {
            return nil
        }
        currentElement = after
    } while true
}

private func compareLists(
    _ lhs: Unmanaged<PropertyList.Element>,
    _ rhs: Unmanaged<PropertyList.Element>,
    ignoredTypes: inout [ObjectIdentifier]
) -> Bool {
    let lhsElement = lhs.takeUnretainedValue()
    let rhsElement = rhs.takeUnretainedValue()
    guard lhsElement.length == rhsElement.length else {
        return false
    }
    guard lhsElement !== rhsElement else {
        return true
    }
    guard lhsElement.matches(rhsElement, ignoredTypes: &ignoredTypes) else {
        return false
    }
    var currentLhsElement = lhsElement
    var currentRhsElement = rhsElement
    repeat {
        let lhsBefore = currentLhsElement.before
        let rhsBefore = currentRhsElement.before
        if let lhsBefore, let rhsBefore {
            if !compareLists(.passUnretained(lhsBefore), .passUnretained(rhsBefore), ignoredTypes: &ignoredTypes) {
                return false
            }
        } else if lhsBefore != nil || rhsBefore != nil {
            return false
        }
        let lhsAfter = currentLhsElement.after
        let rhsAfter = currentRhsElement.after
        guard let lhsAfter, let rhsAfter else {
            return lhsAfter == nil && rhsAfter == nil
        }
        if lhsAfter === rhsAfter {
            return true
        }
        currentLhsElement = lhsAfter
        currentRhsElement = rhsAfter
    } while true
}

// MARK: - PropertyList.Tracker

extension PropertyList {
    /// A class that tracks property accesses and detects changes in a PropertyList.
    ///
    /// Tracker is used to efficiently determine when relevant values in a PropertyList
    /// have changed, which can help avoid unnecessary updates in UI system.
    @usableFromInline
    package class Tracker {
        @AtomicBox
        private var data: TrackerData

        /// Creates a new Tracker instance.
        package init() {
            _data = AtomicBox(wrappedValue: .init(
                plistID: .invalid,
                values: [:],
                derivedValues: [:],
                invalidValues: [],
                unrecordedDependencies: false
            ))
        }

        /// Resets the tracker to its initial state.
        ///
        /// This removes all tracked values and dependencies.
        final package func reset() {
            $data.access { data in
                data.plistID = .invalid
                data.values.removeAll(keepingCapacity: true)
                data.derivedValues.removeAll(keepingCapacity: true)
                data.invalidValues.removeAll(keepingCapacity: true)
                data.unrecordedDependencies = false
            }
        }

        /// Gets a tracked value for the specified key from the PropertyList.
        ///
        /// - Parameters:
        ///   - plist: The PropertyList to get the value from.
        ///   - key: The key type to get the value for.
        /// - Returns: The value associated with the key.
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

        /// Gets a tracked value using a secondary lookup from the PropertyList.
        ///
        /// - Parameters:
        ///   - plist: The PropertyList to get the value from.
        ///   - secondaryLookupHandler: The lookup handler type to use.
        /// - Returns: The primary value if found.
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

        /// Gets a tracked derived value for the specified key from the PropertyList.
        ///
        /// - Parameters:
        ///   - plist: The PropertyList to get the derived value from.
        ///   - key: The derived key type to get the value for.
        /// - Returns: The derived value associated with the key.
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

        /// Initializes the tracker with values from a PropertyList.
        ///
        /// - Parameter plist: The PropertyList to initialize values from.
        final package func initializeValues(from plist: PropertyList) {
            data.plistID = plist.id
        }

        /// Invalidates the tracked value for a specific key when moving from one PropertyList to another.
        ///
        /// - Parameters:
        ///   - key: The key type whose value should be invalidated.
        ///   - oldPlist: The original PropertyList.
        ///   - newPlist: The new PropertyList.
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

        /// Invalidates all tracked values when moving from one PropertyList to another.
        ///
        /// - Parameters:
        ///   - oldPlist: The original PropertyList.
        ///   - newPlist: The new PropertyList.
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

        /// Checks if the PropertyList has different values for any of the tracked keys.
        ///
        /// - Parameter plist: The PropertyList to check against.
        /// - Returns: `true` if any tracked value differs, otherwise `false`.
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

        /// Combines the tracked values from another Tracker into this one.
        ///
        /// - Parameter other: The Tracker to merge values from.
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
    /// A base class for elements stored in a PropertyList.
    ///
    /// Element provides the foundation for type-safe storage of key-value pairs
    /// in a PropertyList, with support for efficient traversal and comparison.
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

        /// Executes a closure for each element that matches the filter.
        ///
        /// - Parameters:
        ///   - filter: A bloom filter to quickly skip elements that don't match.
        ///   - body: A closure to execute for each matching element. Set the second parameter to `true` to stop iteration.
        /// - Returns: `false` if iteration was stopped, otherwise `true`.
        @discardableResult
        final func forEach(
            filter: BloomFilter,
            _ body: (Unmanaged<Element>, inout Bool) -> Void
        ) -> Bool {
            var currentElement = self
            var stop = false
            repeat {
                guard currentElement.skipFilter.mayContain(filter) else {
                    if let skip = currentElement.skip {
                        currentElement = skip.takeUnretainedValue()
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
            } while true
        }

        /// A textual representation of the element.
        @usableFromInline
        package var description: String { openSwiftUIBaseClassAbstractMethod() }

        /// Checks if this element matches another element, ignoring specified types.
        ///
        /// - Parameters:
        ///   - other: The element to compare with.
        ///   - ignoredTypes: Types to ignore during comparison.
        /// - Returns: `true` if the elements match, otherwise `false`.
        func matches(_ other: Element, ignoredTypes: inout [ObjectIdentifier]) -> Bool {
            openSwiftUIBaseClassAbstractMethod()
        }

        /// Creates a copy of this element with the specified before and after elements.
        ///
        /// - Parameters:
        ///   - before: The element to link before this one.
        ///   - after: The element to link after this one.
        /// - Returns: A new element with the same value but different links.
        func copy(before: Element?, after: Element?) -> Element {
            openSwiftUIBaseClassAbstractMethod()
        }

        /// Extracts a value of the specified type from this element.
        ///
        /// - Parameter type: The type to extract the value as.
        /// - Returns: The extracted value.
        func value<T>(as type: T.Type) -> T {
            openSwiftUIBaseClassAbstractMethod()
        }
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
