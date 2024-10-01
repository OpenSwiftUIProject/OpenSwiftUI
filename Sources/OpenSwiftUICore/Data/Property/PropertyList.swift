//
//  PropertyList.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by merge & WIP in 2024
//  ID: 2B32D570B0B3D2A55DA9D4BFC1584D20 (RELEASE_2021)
//  ID: D64CE6C88E7413721C59A34C0C940F2C (RELEASE_2024)

internal import COpenSwiftUICore
internal import OpenGraphShims

// MARK: - PropertyList

/// A mutable container of key-value pairs
@usableFromInline
@frozen
package struct PropertyList: CustomStringConvertible {
    // FIXME: should be internal
    @usableFromInline
    package var elements: Element?
  
    @inlinable
    package init() {
        elements = nil
    }
    
    package init(data: AnyObject?) {
        guard let data else {
            elements = nil
            return
        }
        elements = (data as! Element)
    }
    
    @inlinable
    package var data: AnyObject? {
        elements
    }
    
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
        get { fatalError("TODO") }
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
        fatalError("TODO")
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
        guard keyFilter.match(element.flatMap(\.keyFilter)) else {
            return nil
        }
        if let before = element.map(\.before),
            let result = find(before, key: key, keyFilter: keyFilter) {
            return result
        }
        if element.flatMap(\.keyType) == Key.self {
            return element.map { $0 as? TypedElement<Key> }
        }
        guard let after = element.map(\.after) else {
            break
        }
        element = after
    } while(true)
    return nil
}

// MARK: - PropertyList.Element

extension PropertyList {
    @usableFromInline
    package class Element: CustomStringConvertible {
        let keyType: Any.Type
        let before: Element?
        let after: Element?
        let length: Int
        let keyFilter: BloomFilter
        let id = UniqueID()

        init(keyType: Any.Type, before: Element?, after: Element?) {
            self.keyType = keyType
            self.before = before
            self.after = after
            var length = 1
            var keyFilter = BloomFilter(type: keyType)
            if let before {
                length += before.length
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
        package var description: String { fatalError() }
        
        func matches(_: Element, ignoredTypes _: inout Set<ObjectIdentifier>) -> Bool {
            fatalError()
        }
        
        func hasMatchingValue(in _: Unmanaged<Element>?) -> Bool {
            fatalError()
        }
        
        func copy(before _: Element?, after _: Element?) -> Element {
            fatalError()
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

// MARK: - PropertyList.Tracker

extension PropertyList {
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
        
        package func value<Key: PropertyKey>(_ plist: PropertyList, for keyType: Key.Type) -> Key.Value {
            $data.access { data in
                guard match(data: data, plist: plist) else {
                    data.unrecordedDependencies = true
                    return plist[keyType]
                }
                if let trackedValue = data.values[ObjectIdentifier(Key.self)] {
                    return trackedValue.unwrap()
                } else {
                    let value = plist[keyType]
                    let trackedValue = TrackedValue<Key>(value: value)
                    data.values[ObjectIdentifier(Key.self)] = trackedValue
                    return value
                }
            }
        }
        
        package func initializeValues(from: PropertyList) {
            data.plistID = from.elements?.id ?? .invalid
        }
        
        package func invalidateValue<Key: PropertyKey>(for keyType: Key.Type, from: PropertyList, to: PropertyList) {
            $data.access { data in
                guard let id = match(data: data, from: from, to: to) else {
                    return
                }
                let removedValue = data.values.removeValue(forKey: ObjectIdentifier(Key.self))
                if let removedValue {
                    data.invalidValues.append(removedValue)
                }
                move(&data.derivedValues, to: &data.invalidValues)
                data.plistID = id
            }
        }

        package func invalidateAllValues(from: PropertyList, to: PropertyList) {
            $data.access { data in
                guard let id = match(data: data, from: from, to: to) else {
                    return
                }
                move(&data.values, to: &data.invalidValues)
                move(&data.derivedValues, to: &data.invalidValues)
                data.plistID = id
            }
        }
        
        package func reset() {
            $data.access { data in
                data.plistID = .invalid
                data.values.removeAll(keepingCapacity: true)
                data.derivedValues.removeAll(keepingCapacity: true)
                data.invalidValues.removeAll(keepingCapacity: true)
                data.unrecordedDependencies = false
            }
        }
    
        package func hasDifferentUsedValues(_ plist: PropertyList) -> Bool {
            let data = data
            guard !data.unrecordedDependencies else {
                return true
            }
            guard match(data: data, plist: plist) else {
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
            }
            return false
        }
    }
}

// MARK: - PropertyList.Tracker Helper functions

@inline(__always)
private func match(data: TrackerData, plist: PropertyList) -> Bool {
    if let elements = plist.elements,
       data.plistID == elements.id {
        true
    } else if plist.elements == nil, data.plistID == .invalid {
        true
    } else {
        false
    }
}

@inline(__always)
private func match(data: TrackerData, from: PropertyList, to: PropertyList) -> UniqueID? {
    if let fromElement = from.elements,
       fromElement.id == data.plistID {
        if let toElement = to.elements {
            toElement.id != data.plistID ? toElement.id : nil
        } else {
            data.plistID != .invalid ? .invalid : nil
        }
    } else if from.elements == nil,
              data.plistID == .invalid,
              let toElement = to.elements,
              toElement.id != data.plistID {
        toElement.id
    } else {
        nil
    }
}

private func move(_ values: inout [ObjectIdentifier: any AnyTrackedValue], to invalidValues: inout [any AnyTrackedValue]) {
    guard !values.isEmpty else { return }
    invalidValues.append(contentsOf: values.values)
    values.removeAll(keepingCapacity: true)
}

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
    var invalidValues: [AnyTrackedValue]
    var unrecordedDependencies: Bool
}

// MARK: - AnyTrackedValue

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
