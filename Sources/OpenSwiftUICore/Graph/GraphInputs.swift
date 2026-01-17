//
//  GraphInputs.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 9FF97745734808976F608CE0DC13C39C (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - GraphInput [6.4.41]

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
        preconditionFailure("Reusable graph inputs must implement all reuse methods.")
    }
  
    @inlinable
    package static func tryToReuse(_: Value, by _: Self.Value, indirectMap _: IndirectAttributeMap, testOnly _: Bool) -> Bool {
        false
    }
}

// MARK: - GraphInput + GraphReusable [6.4.41]

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

// MARK: - GraphInputs [6.4.41]

public struct _GraphInputs {
    package var customInputs: PropertyList

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
        let inputs = customInputs[ReusableInputs.self]
        let stack = inputs.stack
        guard stack.top != T.self else {
            return
        }
        customInputs[ReusableInputs.self] = ReusableInputStorage(
            filter: inputs.filter.union(filter),
            stack: .node(value: T.self, next: stack)
        )
    }

    package var time: Attribute<Time>

    package struct Phase: Equatable {
        var value: UInt32

        @inline(__always)
        static var isBeingRemovedBitCount: Int { 1 }

        @inline(__always)
        static var isBeingRemovedMask: UInt32 { (1 << isBeingRemovedBitCount) - 1}

        @inline(__always)
        static var resetSeedMask: UInt32 { ~isBeingRemovedMask }

        @inlinable
        package init(value: UInt32) {
            self.value = value
        }

        @inlinable
        package init() {
            self.value = 0
        }

        package var resetSeed: UInt32 {
            @inlinable get { value >> Self.isBeingRemovedBitCount }
            @inlinable set { value = (newValue << Self.isBeingRemovedBitCount) | (value & Self.isBeingRemovedMask) }
        }

        package var isBeingRemoved: Bool {
            @inlinable get { (value & Self.isBeingRemovedMask) != 0 }
            @inlinable set { value = (newValue ? 1 : 0) | (value & Self.resetSeedMask) }
        }

        @inlinable
        package var isInserted: Bool { !isBeingRemoved }

        @inlinable
        package mutating func merge(_ other: _GraphInputs.Phase) {
            resetSeed = resetSeed &+ other.resetSeed
            isBeingRemoved = isBeingRemoved || other.isBeingRemoved
        }

        package static let invalid = Phase(value: 0xFFFF_FFF0)
    }

    package private(set) var cachedEnvironment: MutableBox<CachedEnvironment>

    package var environment: Attribute<EnvironmentValues> {
        get { cachedEnvironment.wrappedValue.environment }
        set {
            cachedEnvironment = MutableBox(CachedEnvironment(newValue))
            changedDebugProperties.insert(.environment)
        }
    }

    package var phase: Attribute<_GraphInputs.Phase> {
        didSet {
            changedDebugProperties.insert(.phase)
        }
    }

    package var transaction: Attribute<Transaction>

    package var changedDebugProperties: _ViewDebug.Properties

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

    package var options: _GraphInputs.Options

    package var animationsDisabled: Bool {
        get { options.contains(.animationsDisabled)  }
        set { options.setValue(newValue, for: .animationsDisabled) }
    }

    package var needsStableDisplayListIDs: Bool {
        options.contains(.needsStableDisplayListIDs)
    }

    package var mergedInputs: Set<AnyAttribute>

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
        self.mergedInputs = []
    }
    
    package static var invalid: _GraphInputs {
        _GraphInputs(
            time: Attribute(identifier: AnyAttribute.nil),
            phase: Attribute(identifier: AnyAttribute.nil),
            environment: Attribute(identifier: AnyAttribute.nil),
            transaction: Attribute(identifier: AnyAttribute.nil)
        )
    }

    package mutating func `import`(_ src: _GraphInputs) {
        customInputs = src.customInputs
        environment = src.environment
        phase = src.phase
        transaction = src.transaction
        changedDebugProperties.formUnion(src.changedDebugProperties.union(.all))
    }
    
    package mutating func merge(_ src: _GraphInputs) {
        merge(src, ignoringPhase: false)
    }
    
    package mutating func merge(_ src: _GraphInputs, ignoringPhase: Bool) {
        customInputs.merge(src.customInputs)
        if src.environment != environment {
            let (inserted, _) = mergedInputs.insert(src.environment.identifier)
            if inserted {
                environment = Attribute(MergedEnvironment(lhs: WeakAttribute(src.environment), rhs: environment))
            }
        }
        if src.transaction != transaction {
            let (inserted, _) = mergedInputs.insert(src.transaction.identifier)
            if inserted {
                transaction = Attribute(MergedTransaction(lhs: WeakAttribute(src.transaction), rhs: transaction))
            }
        }
        if !ignoringPhase, src.phase != phase {
            let (inserted, _) = mergedInputs.insert(src.phase.identifier)
            if inserted {
                phase = Attribute(MergedPhase(lhs: WeakAttribute(src.phase), rhs: phase))
            }
        }
        changedDebugProperties.formUnion(src.changedDebugProperties)
        mergedInputs.formUnion(src.mergedInputs)
        options.formUnion(src.options)
    }

    package func mapEnvironment<T>(id: CachedEnvironment.ID, _ body: @escaping (EnvironmentValues) -> T) -> Attribute<T> {
        cachedEnvironment.wrappedValue.attribute(id: id, body)
    }
    
    package mutating func copyCaches() {
        cachedEnvironment = MutableBox(cachedEnvironment.wrappedValue)
    }

    package mutating func resetCaches() {
        cachedEnvironment = MutableBox(CachedEnvironment(environment))
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
}

@available(*, unavailable)
extension _GraphInputs: Sendable {}

// MARK: - GraphInputsModifier [6.4.41]

/// Protocol for modifiers that only modify their children's inputs.
public protocol _GraphInputsModifier {
    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs)
}

// MARK: - GraphInputs + intern [6.4.41]

extension _GraphInputs {
    package func intern<T>(_ value: T, id: GraphHost.ConstantID) -> Attribute<T> {
        GraphHost.currentHost.intern(value, id: id)
    }
}

// MARK: - MergedEnvironment [6.4.41]

private struct MergedEnvironment: Rule, AsyncAttribute {
    @WeakAttribute private var lhs: EnvironmentValues?
    @Attribute private var rhs: EnvironmentValues

    init(lhs: WeakAttribute<EnvironmentValues>, rhs: Attribute<EnvironmentValues>) {
        _lhs = lhs
        _rhs = rhs
    }

    var value: EnvironmentValues {
        var result = rhs
        guard let src = lhs else {
            return result
        }
        result.plist.merge(src.plist)
        return result
    }
}

// MARK: - MergedTransaction [6.4.41]

private struct MergedTransaction: Rule, AsyncAttribute {
    @WeakAttribute private var lhs: Transaction?
    @Attribute private var rhs: Transaction

    init(lhs: WeakAttribute<Transaction>, rhs: Attribute<Transaction>) {
        _lhs = lhs
        _rhs = rhs
    }

    var value: Transaction {
        var result = rhs
        guard let src = lhs else {
            return result
        }
        result.plist.merge(src.plist)
        return result
    }
}

// MARK: - MergedPhase [6.4.41]

private struct MergedPhase: Rule, AsyncAttribute {
    @WeakAttribute private var lhs: _GraphInputs.Phase?
    @Attribute private var rhs: _GraphInputs.Phase

    init(lhs: WeakAttribute<_GraphInputs.Phase>, rhs: Attribute<_GraphInputs.Phase>) {
        _lhs = lhs
        _rhs = rhs
    }

    var value: _GraphInputs.Phase {
        var result = rhs
        guard let src = lhs else {
            return result
        }
        result.merge(src)
        return result
    }
}

// MARK: - ReusableInputStorage [6.4.41]

struct ReusableInputStorage {
    var filter: BloomFilter
    var stack: Stack<any GraphInput.Type>
}

struct ReusableInputs: GraphInput {
    static let defaultValue = ReusableInputStorage(filter: BloomFilter(), stack: Stack())
}
