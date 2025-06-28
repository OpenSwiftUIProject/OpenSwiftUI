//
//  StandardLibraryAdditions.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: DE8DAFA613257BEA44770487175C185C (SwiftUICore)

package import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

// MARK: - bind

package func bind<T>(_ action: ((T) -> Void)?, _ value: T) -> (() -> Void)? {
    guard let action else {
        return nil
    }
    return { action(value) }
}

// MARK: - FloatingPoint + Misc [6.5.4]

extension Float {
    package func mix(with other: Float, by t: Double) -> Float {
        (other - self) * Float(t) + self
    }
}

extension CGFloat {
    package func mix(with other: CGFloat, by t: Double) -> CGFloat {
        (other - self) * CGFloat(t) + self
    }
}

extension Double {
    package func mix(with other: Double, by t: Double) -> Double {
        (other - self) * t + self
    }
}

extension Double {
    package var quantized: Double {
        CGFloat(self).quantized
    }
}

extension Float {
    package var quantized: Float {
        #if canImport(Darwin)
        Darwin.round(self * 256.0) / 256.0
        #elseif canImport(Glibc)
        Glibc.round(self * 256.0) / 256.0
        #else
        #error("Unsupported Platform")
        #endif
    }
}

extension CGFloat {
    package var quantized: CGFloat {
        #if canImport(Darwin)
        Darwin.round(self * 256.0) / 256.0
        #elseif canImport(Glibc)
        Glibc.round(self * 256.0) / 256.0
        #else
        #error("Unsupported Platform")
        #endif
    }
}

extension FloatingPoint {
    package func mappingNaN(to value: Self) -> Self {
        isNaN ? value : self
    }
}

extension BinaryFloatingPoint {
    package func ensuringNonzeroValue() -> Self {
        isZero ? Self.leastNonzeroMagnitude : self
    }
}

// MARK: - unsafeIncrement [6.5.4]

extension UInt32 {
    package mutating func unsafeIncrement() {
        self = self &+ 1
    }
}

// MARK: - FixedWidthInteger + clamping [6.5.4]

extension FixedWidthInteger {
    package init<T>(clamping value: T) where T: BinaryFloatingPoint {
        self.init(value.clamp(min: T(Self.min), max: T(Self.max)))
    }
}

// MARK: - Duration Conversion [6.5.4]

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Double {
    package init(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        self = Double(seconds) + Double(attoseconds) / 1e18
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
package func abs(_ duration: Duration) -> Duration {
    (duration < .zero) ? (.zero - duration) : duration
}

// MARK: - Date + Extension [6.5.4]

extension Date {
    package var nextUp: Date {
        Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.nextUp)
    }

    package var nextDown: Date {
        Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.nextDown)
    }
}

// MARK: - Pairt [6.5.4]

package struct Pair<First, Second> {
    package var first: First
    package var second: Second

    package init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    private enum CodingKeys: CodingKey {
        case first
        case second
    }
}

extension Pair: Equatable where First: Equatable, Second: Equatable {
    package static func == (a: Pair<First, Second>, b: Pair<First, Second>) -> Bool {
        return a.first == b.first && a.second == b.second
    }
}

extension Pair: Hashable where First: Hashable, Second: Hashable {
    package func hash(into hasher: inout Hasher) {
        hasher.combine(first)
        hasher.combine(second)
    }

    package var hashValue: Int {
        var hasher = Hasher()
        hash(into: &hasher)
        return hasher.finalize()
    }
}

extension Pair: Codable where First: Decodable, First: Encodable, Second: Decodable, Second: Encodable {
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(first, forKey: .first)
        try container.encode(second, forKey: .second)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        first = try container.decode(First.self, forKey: .first)
        second = try container.decode(Second.self, forKey: .second)
    }
}

// MARK: - ArrayID [6.5.4]

package struct ArrayID: Hashable {
    private let objectIdentifier: ObjectIdentifier

    package init<T>(_ items: [T]) {
        self.objectIdentifier = ObjectIdentifier(items as AnyObject)
    }
}

// MARK: - address(of:) [6.5.4]

package func address(of object: AnyObject) -> UnsafeRawPointer {
    unsafeBitCast(object, to: UnsafeRawPointer.self)
}

// MARK: - UnsafeMutableBufferProjectionPointer [6.5.4]

package struct UnsafeMutableBufferProjectionPointer<Scene, Subject>: RandomAccessCollection, MutableCollection {
    package var startIndex: Int { 0 }

    private let _start: UnsafeMutableRawPointer

    package let endIndex: Int

    @inline(__always)
    package init() {
        _start = UnsafeMutableRawPointer(mutating: UnsafePointer<Subject>.null)
        endIndex = 0
    }

    @inline(__always)
    package init(start: UnsafeMutablePointer<Subject>, count: Int) {
        _start = UnsafeMutableRawPointer(start)
        endIndex = count
    }

    @inline(__always)
    package init(
        _ base: UnsafeMutableBufferPointer<Scene>,
        _ keyPath: WritableKeyPath<Scene, Subject>
    ) {
        if base.isEmpty {
            _start = UnsafeMutableRawPointer(mutating: UnsafePointer<Subject>.null)
        } else {
            // FIXME: We should use a more safer call. eg. swift_modifyAtWritableKeyPath
            _start = UnsafeMutableRawPointer(base.baseAddress!.pointer(to: keyPath)!)
        }
        endIndex = base.count
    }

    package subscript(i: Int) -> Subject {
        @_transparent
        unsafeAddress {
            UnsafeRawPointer(_start)
                .advanced(by: MemoryLayout<Scene>.stride * i)
                .assumingMemoryBound(to: Subject.self)
        }
        @_transparent
        nonmutating unsafeMutableAddress {
            _start
                .advanced(by: MemoryLayout<Scene>.stride * i)
                .assumingMemoryBound(to: Subject.self)
        }
    }

    package typealias Element = Subject
}

// MARK: - Numeric Extension [6.5.4]

extension Numeric {
    package var isNaN: Bool {
        self != self
    }

    package var isFinite: Bool {
        (self - self) == 0
    }
}

// MARK: - Sequence.first(ofType:) [6.5.4]

extension Sequence {
    package func first<T>(ofType: T.Type) -> T? {
        first { $0 is T } as? T
    }
}

// MARK: - Collection + prefix and suffix [6.5.4]

extension Collection where Self.Element: Equatable {
    package func commonPrefix<Other>(with other: Other) -> (Self.SubSequence, Other.SubSequence) where Other: Collection, Element == Other.Element {
        var selfIndex = startIndex
        var otherIndex = other.startIndex

        while selfIndex != endIndex && otherIndex != other.endIndex && self[selfIndex] == other[otherIndex] {
            formIndex(after: &selfIndex)
            other.formIndex(after: &otherIndex)
        }

        return (self[startIndex ..< selfIndex], other[other.startIndex ..< otherIndex])
    }
}

extension BidirectionalCollection where Self.Element: Equatable {
    package func commonSuffix<Other>(with other: Other) -> (Self.SubSequence, Other.SubSequence) where Other: BidirectionalCollection, Self.Element == Other.Element {
        var selfIndex = endIndex
        var otherIndex = other.endIndex

        while selfIndex != startIndex && otherIndex != other.startIndex {
            formIndex(before: &selfIndex)
            other.formIndex(before: &otherIndex)

            if self[selfIndex] != other[otherIndex] {
                formIndex(after: &selfIndex)
                other.formIndex(after: &otherIndex)
                break
            }
        }

        return (self[selfIndex ..< endIndex], other[otherIndex ..< other.endIndex])
    }
}

// MARK: - CountingIndexCollection [6.5.4]

package struct CountingIndexCollection<Base> where Base: BidirectionalCollection {
    package let base: Base

    package init(_ base: Base) {
        self.base = base
    }
}

extension CountingIndexCollection: BidirectionalCollection {
    package typealias Index = CountingIndex<Base.Index>
    package typealias Element = Base.Element

    package var startIndex: CountingIndexCollection<Base>.Index {
        CountingIndex(base: base.startIndex, offset: base.isEmpty ? nil : 0)
    }

    package var endIndex: CountingIndexCollection<Base>.Index {
        CountingIndex(base: base.endIndex, offset: nil)
    }

    package func index(before i: CountingIndexCollection<Base>.Index) -> CountingIndexCollection<Base>.Index {
        let newBase = base.index(before: i.base)
        guard newBase != base.startIndex else {
            return CountingIndex(base: newBase, offset: nil)
        }
        let newOffset = i.offset! - 1
        return CountingIndex(base: newBase, offset: newOffset)
    }

    package func index(after i: CountingIndexCollection<Base>.Index) -> CountingIndexCollection<Base>.Index {
        let newBase = base.index(after: i.base)
        guard newBase != base.endIndex else {
            return CountingIndex(base: newBase, offset: nil)
        }
        let newOffset = i.offset! + 1
        return CountingIndex(base: newBase, offset: newOffset)
    }

    package func index(
        _ i: CountingIndex<Base.Index>,
        offsetBy distance: Int,
        limitedBy limit: CountingIndex<Base.Index>
    ) -> CountingIndex<Base.Index>? {
        guard let newBase = base.index(i.base, offsetBy: distance, limitedBy: limit.base) else {
            return nil
        }
        guard newBase != base.endIndex else {
            return CountingIndex(base: newBase, offset: nil)
        }
        let newOffset = i.offset! + distance
        return CountingIndex(base: newBase, offset: newOffset)
    }

    package subscript(position: CountingIndexCollection<Base>.Index) -> CountingIndexCollection<Base>.Element {
        base[position.base]
    }

    package typealias Indices = DefaultIndices<CountingIndexCollection<Base>>
    package typealias Iterator = IndexingIterator<CountingIndexCollection<Base>>
    package typealias SubSequence = Slice<CountingIndexCollection<Base>>
}

// MARK: - CountingIndex [6.5.4]

package struct CountingIndex<Base>: Equatable where Base: Comparable {
    package let base: Base
    package let offset: Int?

    package init(base: Base, offset: Int?) {
        self.base = base
        self.offset = offset
    }
}

extension CountingIndex: Comparable {
    package static func < (lhs: CountingIndex<Base>, rhs: CountingIndex<Base>) -> Bool {
        return lhs.base < rhs.base
    }
}

extension CountingIndex: CustomStringConvertible {
    package var description: String {
        "(base: \(base) | offset: \(offset?.description ?? "nil"))"
    }
}

// MARK: - 4 elements equal [6.5.4]

package func == <A, B, C, D>(
    lhs: ((A, B), (C, D)),
    rhs: ((A, B), (C, D))
) -> Bool where A: Equatable, B: Equatable, C: Equatable, D: Equatable {
    return lhs.0.0 == rhs.0.0 && lhs.0.1 == rhs.0.1 && lhs.1.0 == rhs.1.0 && lhs.1.1 == rhs.1.1
}

// MARK: - Optional + if-then [6.5.4]

extension Optional {
    package init(if condition: Bool, then value: @autoclosure () -> Wrapped) {
        self = condition ? value() : nil
    }
}

// MARK: - min and max with optional [6.5.4]

package func min<C>(_ a: C, ifPresent b: C?) -> C where C: Comparable {
    guard let b else { return a }
    return Swift.min(a, b)
}

package func max<C>(_ a: C, ifPresent b: C?) -> C where C: Comparable {
    guard let b else { return a }
    return Swift.max(a, b)
}

// MARK: - IndirectOptional [6.5.4]

@propertyWrapper
package enum IndirectOptional<Wrapped>: ExpressibleByNilLiteral {
    case none
    indirect case some(Wrapped)

    package init(_ value: Wrapped) {
        self = .some(value)
    }

    package init(nilLiteral: ()) {
        self = .none
    }

    package init(wrappedValue: Wrapped?) {
        if let value = wrappedValue {
            self = .some(value)
        } else {
            self = .none
        }
    }

    package var wrappedValue: Wrapped? {
        switch self {
        case .none: nil
        case let .some(wrapped): wrapped
        }
    }
}

extension IndirectOptional: Equatable where Wrapped: Equatable {}

extension IndirectOptional: Hashable where Wrapped: Hashable {}

// MARK: - Cache 3 [6.0.87]

/// A simple fixed-size cache that stores up to three key-value pairs.
///
/// Cache3 provides a lightweight, efficient cache implementation with LRU (Least Recently Used)
/// eviction behavior. When a new item is added to a full cache, the oldest item is evicted.
///
/// Example usage:
///
///     var cache = Cache3<String, Int>()
///     cache.put("one", value: 1)
///     cache.put("two", value: 2)
///     let value = cache.get("three") { 3 }  // Creates and caches value 3
///
package struct Cache3<Key, Value> where Key: Equatable {
    /// Internal tuple-based storage for the cached items.
    /// The first element represents the most recently used item.
    var store: ((key: Key, value: Value)?, (key: Key, value: Value)?, (key: Key, value: Value)?)

    /// Creates a new empty cache.
    package init() {
        self.store = (nil, nil, nil)
    }

    /// Looks up a value in the cache by key without changing cache order.
    ///
    /// - Parameter key: The key to look up.
    /// - Returns: The value associated with the key, or `nil` if the key is not in the cache.
    @inline(__always)
    package func find(_ key: Key) -> Value? {
        if let item = store.0, item.key == key {
            return item.value
        }
        if let item = store.1, item.key == key {
            return item.value
        }
        if let item = store.2, item.key == key {
            return item.value
        }
        return nil
    }

    /// Inserts a new value into the cache with the specified key.
    ///
    /// This method adds a new key-value pair to the cache, making it the most recently used item.
    /// If the cache already has 3 items, the least recently used item is evicted.
    ///
    /// - Parameters:
    ///   - key: The key to associate with the value.
    ///   - value: The value to cache.
    @inline(__always)
    package mutating func put(_ key: Key, value: Value) {
        store = ((key, value), store.0, store.1)
    }

    /// Retrieves a value from the cache by key, creating it if not present.
    ///
    /// This method first checks if the key exists in the cache. If found, it returns the
    /// associated value. If not found, it calls the provided closure to create a new value,
    /// caches it, and returns the newly created value.
    ///
    /// - Parameters:
    ///   - key: The key to look up.
    ///   - makeValue: A closure that creates a new value if the key is not found.
    /// - Returns: The value associated with the key, either retrieved from cache or newly created.
    @inline(__always)
    package mutating func get(_ key: Key, makeValue: () -> Value) -> Value {
        guard let value = find(key) else {
            let value = makeValue()
            put(key, value: value)
            return value
        }
        return value
    }
}

// TODO:

// MARK: - CollectionOfTwo [6.5.4]

package struct CollectionOfTwo<T>: RandomAccessCollection, MutableCollection {
    package var startIndex: Int { 0 }

    package var endIndex: Int { 2 }

    package var elements: (T, T)

    package init(_ first: T, _ second: T) {
        self.elements = (first, second)
    }

    package subscript(i: Int) -> T {
        get {
            switch i {
            case 0: return elements.0
            case 1: return elements.1
            default: preconditionFailure("index out of range")
            }
        }
        set {
            switch i {
            case 0: elements.0 = newValue
            case 1: elements.1 = newValue
            default: preconditionFailure("index out of range")
            }
        }
    }
}

// MARK: - EquatableOptionalObject [6.5.4]

@propertyWrapper
package struct EquatableOptionalObject<T>: Equatable where T: AnyObject {
    package var wrappedValue: T?

    package init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    package static func == (lhs: EquatableOptionalObject<T>, rhs: EquatableOptionalObject<T>) -> Bool {
        return lhs.wrappedValue === rhs.wrappedValue
    }
}
