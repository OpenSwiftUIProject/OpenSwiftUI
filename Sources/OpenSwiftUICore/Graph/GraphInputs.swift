//
//  GraphInputs.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP
//  ID: 9FF97745734808976F608CE0DC13C39C

package import OpenGraphShims

// MARK: - GraphInput

package protocol GraphInput: PropertyKey {
    static var isTriviallyReusable: Bool { get }
    static func makeReusable(indirectMap: IndirectAttributeMap, value: inout Value)
    static func tryToReuse(_ value: Value, by other: Value, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool
}

extension GraphInput {
    @inlinable
    package static var isTriviallyReusable: Bool {
        false
    }
    
    package static func makeReusable(indirectMap: IndirectAttributeMap, value: inout Value) {
        fatalError("Reusable graph inputs must implement all reuse methods.")
    }
  
    @inlinable
    package static func tryToReuse(_: Value, by _: Self.Value, indirectMap _: IndirectAttributeMap, testOnly _: Bool) -> Bool {
        false
    }
}

// MARK: - GraphInput + GraphReusable

extension GraphInput where Value: GraphReusable {
    @inlinable
    package static var isTriviallyReusable: Bool {
        Value.isTriviallyReusable
    }
    
    @inlinable
    package static func makeReusable(indirectMap: IndirectAttributeMap, value: inout Value) {
        value.makeReusable(indirectMap: indirectMap)
    }
    
    @inlinable
    package static func tryToReuse(_ value: Value, by other: Value, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        value.tryToReuse(by: other, indirectMap: indirectMap, testOnly: testOnly)
    }
}

// MARK: - ReusableInputs

struct ReusableInputStorage {
    var filter: BloomFilter
    var stack: Stack<any GraphInput.Type>
}

struct ReusableInputs: GraphInput {
    static let defaultValue = ReusableInputStorage(filter: BloomFilter(), stack: Stack())
}

// MARK: - _GraphInputs [WIP]

public struct _GraphInputs {
    package var customInputs: PropertyList
    package var time: Attribute<Time>
    package private(set) var cachedEnvironment: MutableBox<CachedEnvironment>
    package var phase: Attribute<_GraphInputs.Phase>
    package var transaction: Attribute<Transaction>
    package var changedDebugProperties: _ViewDebug.Properties
    package var options: _GraphInputs.Options
    #if canImport(Darwin)
    package var mergedInputs: Set<AnyAttribute>
    #endif
    
    package init(
        time: Attribute<Time>,
        phase: Attribute<_GraphInputs.Phase>,
        environment: Attribute<EnvironmentValues>,
        transaction: Attribute<Transaction>
    ) {
        self.customInputs = PropertyList()
        self.time = time
        self.cachedEnvironment = MutableBox(CachedEnvironment(environment))
        self.phase = phase
        self.transaction = transaction
        self.changedDebugProperties = .all
        self.options = []
        
        #if canImport(Darwin)
        self.mergedInputs = []
        #endif
    }
    
    package static var invalid: _GraphInputs {
        _GraphInputs(
            time: Attribute(identifier: .nil),
            phase: Attribute(identifier: .nil),
            environment: Attribute(identifier: .nil),
            transaction: Attribute(identifier: .nil)
        )
    }
    
    package subscript<T>(input: T.Type) -> T.Value where T: GraphInput {
        get { customInputs[input] }
        set { customInputs[input] = newValue }
    }
    
    package subscript<T>(input: T.Type) -> T.Value where T: GraphInput, T.Value: GraphReusable {
        get { customInputs[input] }
        set {
            recordReusableInput(input)
            customInputs[input] = newValue
        }
    }
    
    private mutating func recordReusableInput<T>(_ input: T.Type) where T: GraphInput, T.Value: GraphReusable {
        let filter = BloomFilter(type: input)
        let reusableInputs = customInputs[ReusableInputs.self]
        if reusableInputs.stack.top == T.self {
            return
        }
        customInputs[ReusableInputs.self] = ReusableInputStorage(
            filter: reusableInputs.filter.union(filter),
            stack: .node(value: T.self, next: reusableInputs.stack)
        )
    }
    
    package var environment: Attribute<EnvironmentValues> {
        get { cachedEnvironment.wrappedValue.environment }
        set {
            cachedEnvironment.wrappedValue = CachedEnvironment(newValue)
            changedDebugProperties.insert(.environment)
        }
    }
    
    package var animationsDisabled: Bool {
        get { options.contains(.animationsDisabled)  }
        set { options.formUnion(.animationsDisabled) }
    }
    
    package var needsStableDisplayListIDs: Bool {
        options.contains(.needsStableDisplayListIDs)
    }
    
    package mutating func `import`(_ src: _GraphInputs) {
        fatalError("TODO")
    }
    
    package mutating func merge(_ src: _GraphInputs) {
        fatalError("TODO")
    }
    
    package mutating func merge(_ src: _GraphInputs, ignoringPhase: Bool) {
        fatalError("TODO")
    }
    
    package func mapEnvironment<T>(_ keyPath: KeyPath<EnvironmentValues, T>) -> Attribute<T> {
        cachedEnvironment.wrappedValue.attribute(keyPath: keyPath)
    }
    
    package mutating func copyCaches() {
        // Blocked by cachedEnvironment
        fatalError("TODO")
    }
    package mutating func resetCaches() {
        // Blocked cachedEnvironment
        fatalError("TODO")
    }
    
    package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T: GraphInput, T.Value == Stack<U> {
        var stack = customInputs[T.self]
        stack.push(newValue)
        customInputs[T.self] = stack
    }
    
    package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T: GraphInput, U: GraphReusable, T.Value == Stack<U> {
        recordReusableInput(T.self)
        var stack = customInputs[T.self]
        stack.push(newValue)
        customInputs[T.self] = stack
    }
    
    package mutating func popLast<T, U>(_ key: T.Type) -> U? where T : GraphInput, T.Value == Stack<U> {
        var stack = customInputs[T.self]
        defer { customInputs[T.self] = stack }
        return stack.pop()
    }
    
    package struct Phase: Equatable {
        var value: UInt32
        
        @inlinable
        package init(value: UInt32) {
            self.value = value
        }
        
        @inlinable
        package init() {
            self.value = 0
        }
        
        @inlinable
        package var resetSeed: UInt32 {
            get { value >> 1 }
            set { value = (newValue << 1) | (value & 1) }
        }

        package var isBeingRemoved: Bool {
            get { value & 1 != 0 }
            set { value = (newValue ? 1 : 0) | (value & 0xFFFF_FFFE) }
        }

        @inlinable
        package var isInserted: Bool {
            value & 1 == 0
        }

        @inlinable
        package mutating func merge(_ other: _GraphInputs.Phase) {
            resetSeed = resetSeed + other.resetSeed
            isBeingRemoved = isBeingRemoved || other.isBeingRemoved
        }
        
        package static let invalid = Phase(value: 0xFFFF_FFF0)
    }
    
    package struct Options: OptionSet {
        package let rawValue: UInt32
        
        @inlinable
        package init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        @inlinable
        package static var animationsDisabled: _GraphInputs.Options { Options(rawValue: 1 << 0) }
        
        @inlinable
        package static var viewRequestsLayoutComputer: _GraphInputs.Options { Options(rawValue: 1 << 1) }
        
        @inlinable
        package static var viewStackOrientationIsDefined: _GraphInputs.Options { Options(rawValue: 1 << 2) }
        
        @inlinable
        package static var viewStackOrientationIsHorizontal: _GraphInputs.Options { Options(rawValue: 1 << 3) }
        
        @inlinable
        package static var viewDisplayListAccessibility: _GraphInputs.Options { Options(rawValue: 1 << 4) }
        
        @inlinable
        package static var viewNeedsGeometry: _GraphInputs.Options { Options(rawValue: 1 << 5) }
        
        @inlinable
        package static var viewNeedsGeometryAccessibility: _GraphInputs.Options { Options(rawValue: 1 << 6) }
        
        @inlinable
        package static var viewNeedsRespondersAccessibility: _GraphInputs.Options { Options(rawValue: 1 << 7) }
        
        @inlinable
        package static var needsStableDisplayListIDs: _GraphInputs.Options { Options(rawValue: 1 << 8) }
        
        @inlinable
        package static var supportsVariableFrameDuration: _GraphInputs.Options { Options(rawValue: 1 << 10) }
        
        @inlinable
        package static var needsDynamicLayout: _GraphInputs.Options { Options(rawValue: 1 << 11) }
        
        @inlinable
        package static var needsAccessibility: _GraphInputs.Options { Options(rawValue: 1 << 12) }
        
        @inlinable
        package static var doNotScrape: _GraphInputs.Options { Options(rawValue: 1 << 13) }
    }
}

@available(*, unavailable)
extension _GraphInputs: Sendable {}

/// Protocol for modifiers that only modify their children's inputs.
public protocol _GraphInputsModifier {
    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs)
}

//extension _GraphInputs {
//    package func intern<T>(_ value: T, id: GraphHost.ConstantID) -> Attribute<T>
//}

// FIXME: TO BE REMOVED
extension _GraphInputs {

    // MARK: - cachedEnvironment

    @inline(__always)
    package func detechedEnvironmentInputs() -> Self {
//        var newInputs = self
//        newInputs.cachedEnvironment = MutableBox(cachedEnvironment.wrappedValue)
//        return newInputs
        fatalError("TO BE REMOVED")
    }

    // MARK: - changedDebugProperties

    @inline(__always)
    package func withEmptyChangedDebugPropertiesInputs<R>(_ body: (_GraphInputs) -> R) -> R {
//        var inputs = self
//        inputs.changedDebugProperties = []
//        return body(inputs)
        fatalError("TO BE REMOVED")
    }

    // MARK: - options

    @inline(__always)
    package var enableLayout: Bool {
        false
//        get { options.contains(.enableLayout) }
        // TODO: setter
    }
}


// FIXME
extension _GraphInputs {
    package typealias ConstantID = Int

    package func intern<Value>(_ value: Value, id: ConstantID) -> Attribute<Value> {
        cachedEnvironment.wrappedValue.intern(value, id: id.internID)
    }
}

extension _GraphInputs.ConstantID {
    @inline(__always)
    package var internID: Self { self & 0x1 }
}
