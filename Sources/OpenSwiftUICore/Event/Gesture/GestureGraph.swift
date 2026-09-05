//
//  GestureGraph.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

// MARK: - GestureGraphDelegate

package protocol GestureGraphDelegate: AnyObject {
    func enqueueAction(_ action: @escaping () -> Void)
}

// MARK: - GestureGraph

final package class GestureGraph: GraphHost, EventGraphHost, CustomStringConvertible {
    weak var rootResponder: AnyGestureResponder?
    weak var delegate: GestureGraphDelegate?
    package let eventBindingManager = EventBindingManager()
    @Attribute private var gestureTime: Time
    @Attribute private var gestureEvents: [EventID: any EventType]
    @Attribute private var inheritedPhase: _GestureInputs.InheritedPhase
    @Attribute private var gestureResetSeed: UInt32
    @OptionalAttribute private var rootPhase: GesturePhase<()>?
    @OptionalAttribute private var gestureDebug: GestureDebug.Data?
    @OptionalAttribute private var gestureCategoryAttr: GestureCategory?
    @OptionalAttribute private var gestureLabelAttr: String??
    @OptionalAttribute private var isCancellableAttr: Bool?
    @OptionalAttribute private var requiredTapCountAttr: Int??
    @OptionalAttribute private var gestureDependencyAttr: GestureDependency?
    @Attribute private var gesturePreferenceKeys: PreferenceKeys
    var nextUpdateTime: Time = .infinity

    init(rootResponder: AnyGestureResponder) {
        precondition(GestureContainerFeature.isEnabled, "Feature flag is disabled.")
        self.rootResponder = rootResponder
        let data = GraphHost.Data()
        let oldSubgraph = Subgraph.current
        Subgraph.current = data.globalSubgraph
        defer { Subgraph.current = oldSubgraph }
        _gestureTime = Attribute(value: .zero)
        _gestureEvents = Attribute(value: [:])
        _inheritedPhase = Attribute(value: .failed)
        _gestureResetSeed = Attribute(value: .zero)
        _gesturePreferenceKeys = Attribute(value: PreferenceKeys())
        super.init(data: data)
        eventBindingManager.host = self
    }

    package var description: String {
        let gestureType = if let rootResponder {
            String(describing: rootResponder.gestureType)
        } else {
            "nil"
        }
        return "GestureGraph<\(gestureType)> \(address(of: self))"
    }

    override package func instantiateOutputs() {
        guard let rootResponder else {
            return
        }
        var inputs = _GestureInputs(
            rootResponder.inputs,
            viewSubgraph: rootResponder.viewSubgraph,
            events: $gestureEvents,
            time: data.$time,
            resetSeed: $gestureResetSeed,
            inheritedPhase: $inheritedPhase,
            gesturePreferenceKeys: $gesturePreferenceKeys
        )
        inputs.options = [.skipCombiners, .gestureGraph]
        if _eventDebugTriggers.contains(.gestures) {
            inputs.options = [.skipCombiners, .includeDebugOutput, .gestureGraph]
        }
        inputs.preferences.requiresGestureLabel = true
        inputs.preferences.requiresIsCancellable = true
        inputs.preferences.requiresRequiredTapCount = true
        inputs.preferences.requiresGestureDependency = true
        let outputs = rootSubgraph.apply {
            rootResponder.makeGesture(inputs: inputs)
        }
        $rootPhase = outputs.phase
        $gestureDebug = outputs.debugData
        $gestureCategoryAttr = outputs.preferences.gestureCategory
        $gestureLabelAttr = outputs.preferences.gestureLabel
        $isCancellableAttr = outputs.preferences.isCancellable
        $requiredTapCountAttr = outputs.preferences.requiredTapCount
        $gestureDependencyAttr = outputs.preferences.gestureDependency
    }

    override package func uninstantiateOutputs() {
        $rootPhase = nil
        _ = gestureEvents
        gestureEvents = [:]
        inheritedPhase = .failed
        gestureResetSeed = .zero
        gesturePreferenceKeys = .init()
        if let rootResponder {
            rootResponder.resetGesture()
        }
    }

    override package func timeDidChange() {
        nextUpdateTime = .infinity
    }

    package var responderNode: ResponderNode? {
        rootResponder
    }

    package var focusedResponder: ResponderNode? {
        guard let rootResponder,
              let host = rootResponder.host,
              let eventGraphHost = host.as(EventGraphHost.self) else {
            return nil
        }
        return eventGraphHost.focusedResponder
    }

    package var nextGestureUpdateTime: Time {
        nextUpdateTime
    }

    package func setInheritedPhase(_ phase: _GestureInputs.InheritedPhase) {
        inheritedPhase = phase
    }

    package func sendEvents(
        _ events: [EventID: any EventType],
        rootNode: ResponderNode,
        at time: Time
    ) -> GesturePhase<Void> {
        guard let rootResponder, rootResponder.isValid else {
            return .failed
        }
        instantiateIfNeeded()
        startTransactionUpdate()
        if data.time != time {
            data.time = time
            data.updateSeed.unsafeIncrement() // not setTime due to this
            timeDidChange()
        }
        gestureEvents = events
        var phase: GesturePhase<Void> = .failed
        finishTransactionUpdate(in: globalSubgraph) { again in
            guard rootResponder.isValid else {
                return
            }
            if again {
                if !events.isEmpty {
                    gestureEvents = [:]
                }
            } else {
                phase = rootPhase!
            }
        }
        printGestures(data: gestureDebug, host: self)
        return phase
    }

    package func resetEvents() {
        uninstantiate(immediately: false)
    }

    package func enqueueAction(_ action: @escaping () -> Void) {
        delegate?.enqueueAction(action)
    }

    @inline(__always)
    func access<T>(_ body: @autoclosure () -> T) -> T {
        Update.perform {
            instantiateIfNeeded()
            return body()
        }
    }

    package func gestureCategory() -> GestureCategory? {
        guard let rootResponder, rootResponder.isValid else {
            return nil
        }
        return access(gestureCategoryAttr)
    }

    @inline(__always)
    var gestureLabel: String? {
        access(gestureLabelAttr ?? nil)
    }

    @inline(__always)
    var isCancellable: Bool {
        access(isCancellableAttr ?? false)
    }

    @inline(__always)
    var requiredTapCount: Int? {
        access(requiredTapCountAttr ?? nil)
    }

    @inline(__always)
    var gestureDependency: GestureDependency {
        access(gestureDependencyAttr ?? .none)
    }
}

extension GestureGraph {
    package static var current: GestureGraph {
        GraphHost.currentHost as! GestureGraph
    }
}
