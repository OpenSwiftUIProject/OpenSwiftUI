//
//  GestureInputs.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import OpenGraphShims

// MARK: - GestureInputs [6.5.4]

/// Input (aka inherited) attributes for gesture objects.
@available(OpenSwiftUI_v1_0, *)
public struct _GestureInputs {
    package var viewInputs: _ViewInputs

    package var viewSubgraph: Subgraph

    package var preferences: PreferencesInputs

    package var events: Attribute<[EventID : any EventType]>

    package var resetSeed: Attribute<UInt32>

    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
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
        intern(.failed, id: .failedValue)
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
        self.viewInputs = inputs
        self.viewInputs.time = time
        self.viewSubgraph = viewSubgraph
        self.preferences = .init(hostKeys: gesturePreferenceKeys)
        self.events = events
        self.resetSeed = resetSeed
        self.inheritedPhase = inheritedPhase
        self.options = []
        self.platformInputs = .init()
    }

    package mutating func mergeViewInputs(
        _ other: _ViewInputs,
        viewSubgraph: Subgraph
    ) {
        self.viewInputs = other
        self.viewInputs.copyCaches()
        self.viewSubgraph = viewSubgraph
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
        let phase: Attribute<GesturePhase<Value>> = intern(.defaultValue, id: .defaultValue)
        var outputs = _GestureOutputs(phase: IndirectAttribute(source: phase).projectedValue)
        if options.contains(.includeDebugOutput) {
            let debugData: Attribute<GestureDebug.Data> = intern(.defaultValue, id: .defaultValue)
            outputs.debugData = IndirectAttribute(source: debugData).projectedValue
        }
        outputs.preferences = preferences.makeIndirectOutputs()
        return outputs
    }

    package func makeDefaultOutputs<Value>() -> _GestureOutputs<Value> {
        let phase = Attribute(DefaultRule<GesturePhase<Value>>())
        var outputs = _GestureOutputs(phase: phase)
        if options.contains(.includeDebugOutput) {
            let debugData = Attribute(DefaultRule<GestureDebug.Data>())
            outputs.debugData = debugData
        }
        outputs.preferences = preferences.makeIndirectOutputs()
        return outputs
    }

    package mutating func copyCaches() {
        viewInputs.copyCaches()
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
