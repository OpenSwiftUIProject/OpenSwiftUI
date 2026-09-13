//
//  LayoutGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 05F3243F43C616B77CCF383885E80E96 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims

// MARK: - LayoutGesture

package protocol LayoutGesture: PrimitiveDebuggableGesture, PrimitiveGesture where Value == () {
    var responder: MultiViewResponder { get }

    func updateEventBindings(
        _ events: inout [EventID: any EventType],
        proxy: LayoutGestureChildProxy
    )
}

extension LayoutGesture {
    package static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Void> {
        let box = LayoutGestureBox(inputs: inputs)
        let boxValue = Attribute(UpdateLayoutGestureBox(
            gesture: gesture.value,
            events: inputs.events,
            resetSeed: inputs.resetSeed,
            box: box
        ))
        let phase = Attribute(LayoutPhase(gesture: gesture.value, boxValue: boxValue))
        var outputs = _GestureOutputs(phase: phase)
        if inputs.options.contains(.includeDebugOutput) {
            outputs.debugData = Attribute(LayoutDebug(
                gestureType: Self.self,
                phase: phase,
                boxValue: boxValue,
                resetSeed: inputs.resetSeed,
                position: inputs.position,
                size: inputs.size,
                transform: inputs.transform
            ))
        }
        for key in inputs.preferences.keys {
            func project<K: PreferenceKey>(_ key: K.Type) {
                outputs[key] = Attribute(LayoutGesturePreferenceCombiner<Self, K>(
                    gesture: gesture.value,
                    boxValue: boxValue
                ))
            }
            project(key)
        }
        return outputs
    }

    package func updateEventBindings(
        _ events: inout [EventID: any EventType],
        proxy: LayoutGestureChildProxy
    ) {
        _openSwiftUIEmptyStub()
    }

    fileprivate func childEvents(
        events: [EventID: any EventType],
        index: Int,
        box: LayoutGestureBox
    ) -> [EventID: any EventType] {
        let child = box.children[index]
        if child.seenEventIDs.isEmpty {
            return events.optimisticFilter { _, event in
                event.binding.map(child.binds) ?? false
            }
        }
        var result: [EventID: any EventType] = [:]
        for (id, event) in events {
            if let binding = event.binding, child.binds(binding) {
                result[id] = event
            } else if child.seenEventIDs.contains(id) {
                var event = event
                event.binding = nil
                result[id] = event
            }
        }
        return result
    }

    fileprivate func phase(box: LayoutGestureBox) -> GesturePhase<Void> {
        box.children.filter { !$0.seenEventIDs.isEmpty }
            .map { $0.phase!.value.withValue(()) }
            .merged()
    }

    fileprivate func preferenceValue<K: PreferenceKey>(
        key: K.Type,
        box: LayoutGestureBox
    ) -> K.Value {
        var value = K.defaultValue
        var isFirst = true
        for child in box.children {
            guard !child.seenEventIDs.isEmpty,
                  let preferences = child.preferences,
                  let attribute = preferences[key] else {
                continue
            }
            if isFirst {
                value = attribute.value
            } else {
                K.reduce(value: &value) { attribute.value }
            }
            isFirst = false
        }
        return value
    }
}

// MARK: - DefaultLayoutGesture

package struct DefaultLayoutGesture: LayoutGesture {
    package var responder: MultiViewResponder

    package typealias Body = Never
    package typealias Value = ()
}

// MARK: - LayoutGestureBox

private final class LayoutGestureBox {
    let inputs: _GestureInputs
    weak var bindingManager: EventBindingManager?
    let parentSubgraph: Subgraph
    var children: [Child] = []
    var nextUniqueId: UInt32 = 0
    var seed: UInt32 = 0
    var resetSeed: UInt32 = 0

    struct Value {
        let box: LayoutGestureBox
        let seed: UInt32
    }

    struct Child {
        let responder: ViewResponder
        let uniqueId: UInt32
        var resetDelta: UInt32 = 0
        var subgraph: Subgraph?
        var phase: Attribute<GesturePhase<Void>>?
        var events: [EventID: any EventType] = [:]
        var seenEventIDs: Set<EventID> = []
        var debugData: DebugData?
        var preferences: PreferencesOutputs?

        enum DebugData {
            case reset(GestureDebug.Data)
            case attribute(Attribute<GestureDebug.Data>)
        }

        func binds(_ binding: EventBinding) -> Bool {
            binding.responder.isDescendant(of: responder)
        }

        mutating func reset() {
            guard !seenEventIDs.isEmpty else {
                return
            }
            if phase != nil {
                if case let .attribute(attribute)? = debugData {
                    debugData = .reset(attribute.value)
                }
                phase = nil
                subgraph?.willInvalidate(isInserted: true)
                subgraph?.invalidate()
                subgraph = nil
                responder.resetGesture()
            }
            events = [:]
            seenEventIDs = []
            resetDelta &+= 1
        }
    }

    init(inputs: _GestureInputs) {
        self.inputs = inputs
        bindingManager = EventBindingManager.current
        parentSubgraph = Subgraph.current!
    }

    func updateResetSeed(_ resetSeed: UInt32) {
        guard self.resetSeed != resetSeed else {
            return
        }
        self.resetSeed = resetSeed
        for index in children.indices {
            children[index].reset()
            seed &+= 1
        }
        seed &+= 1
    }

    func updateResponder(_ responder: MultiViewResponder) {
        var count = children.count
        var index = 0
        var changed = false
        for responder in responder.children {
            if let match = (index..<count).first(where: { children[$0].responder === responder }) {
                if match != index {
                    children.swapAt(index, match)
                    changed = true
                }
            } else {
                children.append(Child(responder: responder, uniqueId: nextUniqueId))
                nextUniqueId &+= 1
                if index < count {
                    children.swapAt(index, count)
                }
                count += 1
                changed = true
            }
            index += 1
        }
        while index < count {
            count -= 1
            children[count].reset()
            seed &+= 1
            children.removeLast()
            changed = true
        }
        if changed {
            seed &+= 1
        }
    }

    func willSendEvents<G: LayoutGesture>(
        _ events: [EventID: any EventType],
        gesture: G,
        boxValueAttribute: Attribute<Value>
    ) {
        for index in children.indices where !children[index].events.isEmpty {
            children[index].events = [:]
            seed &+= 1
        }
        guard !events.isEmpty else {
            return
        }
        var events = events
        gesture.updateEventBindings(&events, proxy: LayoutGestureChildProxy(box: self))
        for index in children.indices {
            let childEvents = gesture.childEvents(events: events, index: index, box: self)
            guard !childEvents.isEmpty else {
                continue
            }
            children[index].seenEventIDs.formUnion(childEvents.keys)
            children[index].events = childEvents
            seed &+= 1
            guard children[index].phase == nil else {
                continue
            }
            let outputs: _GestureOutputs<Void>
            if parentSubgraph.isValid {
                let uniqueId = children[index].uniqueId
                let subgraph = Subgraph(graph: parentSubgraph.graph)
                parentSubgraph.addChild(subgraph)
                outputs = subgraph.apply {
                    var inputs = self.inputs
                    inputs.copyCaches()
                    inputs.events = Attribute(LayoutChildEvents<G>(
                        boxValue: boxValueAttribute,
                        uniqueId: uniqueId
                    ))
                    inputs.resetSeed = Attribute(LayoutChildSeed<G>(
                        boxValue: boxValueAttribute,
                        uniqueId: uniqueId
                    ))
                    return children[index].responder.makeGesture(inputs: inputs)
                }
                children[index].subgraph = subgraph
            } else {
                outputs = _GestureOutputs(phase: inputs.failedPhase)
            }
            children[index].phase = outputs.phase
            children[index].debugData = outputs.debugData.map(Child.DebugData.attribute)
            children[index].preferences = outputs.preferences
        }
    }

    func resetTerminalChildren<G: LayoutGesture>(gesture: G) {
        for index in children.indices {
            guard !children[index].seenEventIDs.isEmpty,
                  children[index].phase!.value.isTerminal else {
                continue
            }
            children[index].reset()
            seed &+= 1
        }
    }
}

// MARK: - LayoutGestureChildProxy

package struct LayoutGestureChildProxy: RandomAccessCollection {
    fileprivate let box: LayoutGestureBox

    package struct Child {
        fileprivate let base: LayoutGestureBox.Child

        package func binds(_ binding: EventBinding) -> Bool {
            base.binds(binding)
        }

        package func containsGlobalLocation(_ p: PlatformPoint) -> Bool {
            base.responder.containsGlobalPoints([p], cacheKey: nil, options: []).mask[0]
        }
    }

    package var startIndex: Int { 0 }

    package var endIndex: Int { box.children.count }

    package subscript(index: Int) -> LayoutGestureChildProxy.Child {
        Child(base: box.children[index])
    }

    package func bindChild(
        index: Int,
        event: any EventType,
        id: EventID
    ) -> (from: EventBinding?, to: EventBinding?)? {
        var responder = box.children[index].responder
        if let event = HitTestableEvent(event) {
            responder = responder.hitTest(
                globalPoint: event.hitTestLocation,
                radius: event.hitTestRadius,
                cacheKey: nil,
                options: []
            ) ?? responder
        }
        guard let change = box.bindingManager?.rebindEvent(id, to: responder) else {
            return nil
        }
        if let oldBinding = change.from,
           let index = box.children.firstIndex(where: { $0.binds(oldBinding) }) {
            box.children[index].resetDelta &+= 1
            box.seed &+= 1
        }
        return change
    }
}

// MARK: - UpdateLayoutGestureBox

private struct UpdateLayoutGestureBox<G: LayoutGesture>: Rule {
    @Attribute var gesture: G
    @Attribute var events: [EventID: any EventType]
    @Attribute var resetSeed: UInt32
    let box: LayoutGestureBox

    var value: LayoutGestureBox.Value {
        box.updateResetSeed(resetSeed)
        let (gesture, changed) = $gesture.changedValue()
        if changed {
            box.updateResponder(gesture.responder)
        }
        box.willSendEvents(events, gesture: gesture, boxValueAttribute: attribute)
        return .init(box: box, seed: box.seed)
    }
}

// MARK: - LayoutChildEvents

private struct LayoutChildEvents<G: LayoutGesture>: Rule {
    @Attribute var boxValue: LayoutGestureBox.Value
    let uniqueId: UInt32

    var value: [EventID: any EventType] {
        boxValue.box.children.first { $0.uniqueId == uniqueId }?.events ?? [:]
    }
}

// MARK: - LayoutChildSeed

private struct LayoutChildSeed<G: LayoutGesture>: Rule {
    @Attribute var boxValue: LayoutGestureBox.Value
    let uniqueId: UInt32

    var value: UInt32 {
        let box = boxValue.box
        let delta = box.children.first { $0.uniqueId == uniqueId }?.resetDelta ?? 0x10000
        return box.resetSeed &+ delta
    }
}

// MARK: - LayoutPhase

private struct LayoutPhase<G: LayoutGesture>: Rule {
    @Attribute var gesture: G
    @Attribute var boxValue: LayoutGestureBox.Value

    var value: GesturePhase<Void> {
        let box = boxValue.box
        let phase = gesture.phase(box: box)
        box.resetTerminalChildren(gesture: gesture)
        return phase
    }
}

// MARK: - LayoutGesturePreferenceCombiner

private struct LayoutGesturePreferenceCombiner<G: LayoutGesture, K: PreferenceKey>: Rule, AsyncAttribute {
    @Attribute var gesture: G
    @Attribute var boxValue: LayoutGestureBox.Value

    static var initialValue: K.Value? { K.defaultValue }

    var value: K.Value {
        gesture.preferenceValue(key: K.self, box: boxValue.box)
    }
}

// MARK: - LayoutDebug

private struct LayoutDebug<G: LayoutGesture>: Rule {
    var gestureType: G.Type
    @Attribute var phase: GesturePhase<Void>
    @Attribute var boxValue: LayoutGestureBox.Value
    @Attribute var resetSeed: UInt32
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform

    var value: GestureDebug.Data {
        let children = boxValue.box.children.compactMap { child -> GestureDebug.Data? in
            switch child.debugData {
            case let .reset(data)?: data
            case let .attribute(attribute)?: attribute.value
            case nil: nil
            }
        }
        let origin = transform.convert(.localToSpace(.global), point: position)
        return GestureDebug.Data(
            kind: .combiner,
            type: gestureType,
            children: .init(children),
            phase: phase,
            attribute: $boxValue.identifier,
            resetSeed: resetSeed,
            frame: CGRect(origin: origin, size: size.value),
            properties: .init()
        )
    }
}

// MARK: - GesturePhase Collection + merged

extension Collection where Element == GesturePhase<Void> {
    fileprivate func merged() -> GesturePhase<Void> {
        var allFailed = true
        var allTerminal = true
        var hasActiveOrEnded = false
        var allHaveValue = true
        for phase in self {
            switch phase {
            case .failed:
                break
            case let .possible(value):
                allFailed = false
                allTerminal = false
                if value == nil {
                    allHaveValue = false
                }
            case .active:
                allFailed = false
                allTerminal = false
                hasActiveOrEnded = true
            case .ended:
                allFailed = false
                hasActiveOrEnded = true
            }
        }
        if allFailed {
            return .failed
        } else if allTerminal {
            return .ended(())
        } else if hasActiveOrEnded {
            return .active(())
        } else {
            return .possible(allHaveValue ? () : nil)
        }
    }
}
