//
//  GestureGraph.swift
//  OpenSwiftUICore
//
//  Status: WIP

import OpenGraphShims

// MARK: - GestureGraphDelegate [6.5.4]

package protocol GestureGraphDelegate: AnyObject {
    func enqueueAction(_ action: @escaping () -> Void)
}

// MARK: - GestureGraph [6.5.4] [WIP]

final package class GestureGraph: GraphHost, EventGraphHost, CustomStringConvertible {
    weak var rootResponder: AnyGestureResponder?
    weak var delegate: GestureGraphDelegate?
    package let eventBindingManager: EventBindingManager
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
    var nextUpdateTime: Time

    init(rootResponder: AnyGestureResponder) {
        self.rootResponder = rootResponder
        preconditionFailure("TODO")
    }

    package var description: String {
        "GestureGraph<\(rootResponder.map { String(describing: $0.gestureType) } ?? "nil")> \(self)"
    }

    override package func instantiateOutputs() {
        preconditionFailure("TODO")
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
        preconditionFailure("TODO")
    }

    package func resetEvents() {
        uninstantiate(immediately: false)
    }

    package func enqueueAction(_ action: @escaping () -> Void) {
        delegate?.enqueueAction(action)
    }

    package func gestureCategory() -> GestureCategory? {
        guard let rootResponder, rootResponder.isValid else {
            return nil
        }
        return Update.perform {
            instantiateIfNeeded()
            return gestureCategoryAttr
        }
    }
}

extension GestureGraph {
    package static var current: GestureGraph {
        GraphHost.currentHost as! GestureGraph
    }
}
