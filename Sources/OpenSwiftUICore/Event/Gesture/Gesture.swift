//
//  Gesture.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import OpenGraphShims
import OpenSwiftUI_SPI

// MARK: - Gesture [6.5.4] [Blocked by GestureDebug]

/// An instance that matches a sequence of events to a gesture, and returns a
/// stream of values for each of its states.
///
/// Create custom gestures by declaring types that conform to the `Gesture`
/// protocol.
@available(OpenSwiftUI_v1_0, *)
@MainActor
@preconcurrency
public protocol Gesture<Value> {
    /// The type representing the gesture's value.
    associatedtype Value

    nonisolated static func _makeGesture(gesture: _GraphValue<Self>, inputs: _GestureInputs) -> _GestureOutputs<Value>

    /// The type of gesture representing the body of `Self`.
    associatedtype Body : Gesture

    /// The content and behavior of the gesture.
    var body: Body { get }
}

package protocol PrimitiveGesture: Gesture where Body == Never {}

package protocol PubliclyPrimitiveGesture: PrimitiveGesture {
    associatedtype InternalBody: Gesture where Value == InternalBody.Value

    var internalBody: InternalBody { get }
}

@available(OpenSwiftUI_v1_0, *)
extension PubliclyPrimitiveGesture {
    public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        makeGesture(gesture: gesture, inputs: inputs)
    }

    package static func makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Value> {
        preconditionFailure("TODO") // GestureDebug
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Never: Gesture {
    public typealias Value = Never
}

@available(OpenSwiftUI_v1_0, *)
extension PrimitiveGesture {
    public var body: Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Gesture where Value == Body.Value {
    public static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Self.Body.Value> {
        preconditionFailure("TODO")
    }
}

// MARK: - GestureInputs [6.5.4] [WIP]

/// Input (aka inherited) attributes for gesture objects.
@available(OpenSwiftUI_v1_0, *)
public struct _GestureInputs {
    package var viewInputs: _ViewInputs

    package var viewSubgraph: Subgraph

    package var preferences: PreferencesInputs

    package var events: Attribute<[EventID : any EventType]>

    package var resetSeed: Attribute<UInt32>

    @_spi(ForOpenSwiftUIOnly)
    public struct InheritedPhase: OptionSet, Defaultable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        package static let failed: _GestureInputs.InheritedPhase = .init(rawValue: 1 << 0)

        package static let active: _GestureInputs.InheritedPhase = .init(rawValue: 1 << 1)

        package static let defaultValue: _GestureInputs.InheritedPhase = .failed
    }

    package var inheritedPhase: Attribute<_GestureInputs.InheritedPhase>

    package var failedPhase: Attribute<GesturePhase<Void>> {
        get { preconditionFailure("TODO") }
    }

    package var options: _GestureInputs.Options

    package var platformInputs: PlatformGestureInputs

    package init(
        _ inputs: _ViewInputs,
        viewSubgraph: Subgraph,
        events: Attribute<[EventID : any EventType]>,
        time: Attribute<Time>,
        resetSeed: Attribute<UInt32>,
        inheritedPhase: Attribute<_GestureInputs.InheritedPhase>,
        gesturePreferenceKeys: Attribute<PreferenceKeys>
    ) {

        preconditionFailure("TODO")
    }

    package mutating func mergeViewInputs(
        _ other: _ViewInputs,
        viewSubgraph: Subgraph
    ) {
        preconditionFailure("TODO")
    }

    package func animatedPosition() -> Attribute<ViewOrigin> {
        viewSubgraph.apply {
            viewInputs.animatedPosition()
        }
    }

    package func intern<T>(
        _ value: T,
        id: GraphHost.ConstantID
    ) -> Attribute<T> {
        GraphHost.currentHost.intern(value, id: id)
    }

    package func makeIndirectOutputs<Value>() -> _GestureOutputs<Value> {
        preconditionFailure("TODO")
    }

    package func makeDefaultOutputs<Value>() -> _GestureOutputs<Value> {
        preconditionFailure("TODO")
    }
}

extension _GestureInputs {
    package struct Options: OptionSet {
        package let rawValue: UInt32

        @inlinable
        package init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        @inlinable
        package static var preconvertedEventLocations: _GestureInputs.Options {
            .init(rawValue: 1 << 0)
        }

        @inlinable
        package static var allowsIncompleteEventSequences: _GestureInputs.Options {
            .init(rawValue: 1 << 1)
        }

        @inlinable
        package static var skipCombiners: _GestureInputs.Options {
            .init(rawValue: 1 << 2)
        }

        @inlinable
        package static var includeDebugOutput: _GestureInputs.Options {
            .init(rawValue: 1 << 3)
        }

        @inlinable
        package static var gestureGraph: _GestureInputs.Options {
            .init(rawValue: 1 << 4)
        }
    }
}

@available(*, unavailable)
extension _GestureInputs: Sendable {}

@available(*, unavailable)
extension _GestureInputs.InheritedPhase: Sendable {}

// MARK: - GestureOutputs [6.5.4] [WIP]

/// Output (aka synthesized) attributes for gesture objects.
@available(OpenSwiftUI_v1_0, *)
public struct _GestureOutputs<Value> {
    package var phase: Attribute<GesturePhase<Value>>

    package var preferences: PreferencesOutputs

//    package var debugData: Attribute<GestureDebug.Data>? {
//        get { preconditionFailure("TODO") }
//        set { preconditionFailure("TODO") }
//    }

    package init(phase: Attribute<GesturePhase<Value>>) {
        preconditionFailure("TODO")
    }

    package func withPhase<T>(_ phase: Attribute<GesturePhase<T>>) -> _GestureOutputs<T> {
        preconditionFailure("TODO")
    }

    package func overrideDefaultValues(_ childOutputs: _GestureOutputs<Value>) {
        preconditionFailure("TODO")
    }

    package func setIndirectDependency(_ dependency: AnyAttribute?) {
        preconditionFailure("TODO")
    }

    package func attachIndirectOutputs(_ childOutputs: _GestureOutputs<Value>) {
        preconditionFailure("TODO")
    }

    package func detachIndirectOutputs() {
        preconditionFailure("TODO")
    }

    package subscript(anyKey key: any AnyPreferenceKey.Type) -> AnyAttribute? {
        get { preconditionFailure("TODO") }
        set { preconditionFailure("TODO") }
    }

    package subscript<K>(key: K.Type) -> Attribute<K.Value>? where K: PreferenceKey {
        get { preconditionFailure("TODO") }
        set { preconditionFailure("TODO") }
    }

    package mutating func appendPreference<K>(
        key: K.Type,
        value: Attribute<K.Value>
    ) where K: PreferenceKey {
        preconditionFailure("TODO")
    }

    package func forEachPreference(_ body: (any AnyPreferenceKey.Type, AnyAttribute) -> Void) {
        preconditionFailure("TODO")
    }
}

// MARK: - GestureCategory [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public struct GestureCategory: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let magnify: GestureCategory = .init(rawValue: 1 << 0)

    package static let rotate: GestureCategory = .init(rawValue: 1 << 1)

    package static let drag: GestureCategory = .init(rawValue: 1 << 2)

    package static let select: GestureCategory = .init(rawValue: 1 << 3)

    package static let longPress: GestureCategory = .init(rawValue: 1 << 4)

    package struct Key: PreferenceKey {
        package static let _includesRemovedValues: Bool = true

        package static let defaultValue: GestureCategory = .magnify

        package static func reduce(
            value: inout GestureCategory.Key.Value,
            nextValue: () -> GestureCategory.Key.Value
        ) {
            value = GestureCategory(rawValue: value.rawValue | nextValue().rawValue)
        }
    }
}

@available(*, unavailable)
extension GestureCategory: Sendable {}

// MARK: - GestureDescriptor [6.5.4]

package struct GestureDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<GestureDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_gestureProtocolDescriptor()
    }
}

// MARK: - GestureModifierDescriptor [6.5.4]

package struct GestureModifierDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<GestureModifierDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_gestureModifierProtocolDescriptor()
    }
}

// MARK: - PlatformGestureInputs [6.5.4]

package struct PlatformGestureInputs {}
