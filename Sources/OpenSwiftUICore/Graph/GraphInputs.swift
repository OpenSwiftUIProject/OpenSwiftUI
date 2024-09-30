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
    
//    package var time: Attribute<Time>
//  package struct Phase : Equatable {
//    @inlinable package init(value: UInt32)
//    @inlinable package init()
//    package var resetSeed: UInt32 {
//      @inlinable get
//      @inlinable set
//    }
//    package var isBeingRemoved: Bool {
//      @inlinable get
//      @inlinable set
//    }
//    @inlinable package var isInserted: Bool {
//      get
//    }
//    @inlinable package mutating func merge(_ other: _GraphInputs.Phase)
//    package static let invalid: _GraphInputs.Phase
//    package static func == (a: _GraphInputs.Phase, b: _GraphInputs.Phase) -> Bool
//  }
//  package var cachedEnvironment: MutableBox<CachedEnvironment> {
//    get
//  }
//  package var environment: Attribute<EnvironmentValues> {
//    get
//    set
//  }
//  package var phase: Attribute<_GraphInputs.Phase> {
//    get
//    set
//  }
    package var transaction: Attribute<Transaction>
//  package var changedDebugProperties: _ViewDebug.Properties
//  package struct Options : OptionSet {
//    package let rawValue: UInt32
//    @inlinable package init(rawValue: UInt32)
//    @inlinable package static var animationsDisabled: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewRequestsLayoutComputer: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewStackOrientationIsDefined: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewStackOrientationIsHorizontal: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewDisplayListAccessibility: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewNeedsGeometry: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewNeedsGeometryAccessibility: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var viewNeedsRespondersAccessibility: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var needsStableDisplayListIDs: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var supportsVariableFrameDuration: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var needsDynamicLayout: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var needsAccessibility: _GraphInputs.Options {
//      get
//    }
//    @inlinable package static var doNotScrape: _GraphInputs.Options {
//      get
//    }
//    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
//    package typealias ArrayLiteralElement = _GraphInputs.Options
//    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
//    package typealias Element = _GraphInputs.Options
//    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
//    package typealias RawValue = UInt32
//  }
//  package var options: _GraphInputs.Options
//  package var animationsDisabled: Bool {
//    get
//    set
//  }
//  package var needsStableDisplayListIDs: Bool {
//    get
//  }
//  package var mergedInputs: Set<AnyAttribute>
//  package init(time: Attribute<Time>, phase: Attribute<_GraphInputs.Phase>, environment: Attribute<EnvironmentValues>, transaction: Attribute<Transaction>)
//  package static var invalid: _GraphInputs {
//    get
//  }
//  package mutating func `import`(_ src: _GraphInputs)
//  package mutating func merge(_ src: _GraphInputs)
//  package mutating func merge(_ src: _GraphInputs, ignoringPhase: Bool)
//  package func mapEnvironment<T>(_ keyPath: KeyPath<EnvironmentValues, T>) -> Attribute<T>
//  package mutating func copyCaches()
//  package mutating func resetCaches()
//  package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T : GraphInput, T.Value == Stack<U>
//  package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T : GraphInput, U : GraphReusable, T.Value == Stack<U>
//  #if compiler(>=5.3) && $NoncopyableGenerics
//  package mutating func popLast<T, U>(_ key: T.Type) -> U? where T : GraphInput, T.Value == Stack<U>
//  #else
//  package mutating func popLast<T, U>(_ key: T.Type) -> U? where T : GraphInput, T.Value == Stack<U>
//  #endif
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
