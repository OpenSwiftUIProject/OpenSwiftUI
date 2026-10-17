//
//  PanGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B91FD4B193E991093C77979850E18C8F (SwiftUI)

public import Foundation
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - PanGesture

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct PanGesture: PubliclyPrimitiveGesture, Gesture {
    public struct Value: Equatable {
        var timestamp: Time

        public var translation: CGSize

        public var touchType: TouchType

        var velocity: _Velocity<CGSize>
    }

    var minimumDistance: CGFloat

    var allowedDirections: _EventDirections = .all

    public init(allowedDirections: _EventDirections = .all, minimumDistance: CGFloat = 10) {
        self.minimumDistance = minimumDistance
        self.allowedDirections = allowedDirections
    }

    @available(*, deprecated, message: "Removed without replacement")
    @usableFromInline
    init(allowedDirections: _EventDirections = .all, minimumDistance: CGFloat = 10, requiresTwoFingerTouch: Bool) {
        self.minimumDistance = minimumDistance
        self.allowedDirections = allowedDirections
    }

    package var internalBody: some Gesture<Value> {
        RawPanGesture(
            minimumDistance: minimumDistance,
            allowedDirections: allowedDirections
        )
        .dependency(.pausedWhileActive)
    }

    public typealias Body = Never
}

@_spi(Private)
@available(*, unavailable)
extension PanGesture.Value: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension PanGesture: Sendable {}

// MARK: - RawPanGesture

struct RawPanGesture: Gesture {
    struct StateType: GestureStateProtocol {
        fileprivate struct EventInfo {
            var globalTranslation: CGSize
            var translation: CGSize
        }

        fileprivate var eventInfo: [EventID: EventInfo]
        var phase: GesturePhase<Void>
        var phaseValue: PanGesture.Value
        var globalTranslation: CGSize

        init() {
            eventInfo = [:]
            phase = .possible(nil)
            phaseValue = PanGesture.Value(
                timestamp: .zero,
                translation: .zero,
                touchType: .indirect,
                velocity: _Velocity(valuePerSecond: .zero)
            )
            globalTranslation = .zero
        }
    }

    var minimumDistance: CGFloat

    var allowedDirections: _EventDirections = .all

    init(minimumDistance: CGFloat, allowedDirections: _EventDirections) {
        self.minimumDistance = minimumDistance
        self.allowedDirections = allowedDirections
    }

    var body: some Gesture<PanGesture.Value> {
        StateType.gesture(
            content: MultiEventListener<PanEvent>(allowsFailure: true)
        ) { state, childPhase in
            update(state: &state, childPhase: childPhase)
            return state.phase.withValue(state.phaseValue)
        }
    }

    private func update(
        state: inout StateType,
        childPhase: GesturePhase<[EventID: PanEvent]>
    ) {
        if case .failed = childPhase {
            state.phase = .failed
            return
        }
        guard let events = childPhase.unwrapped else {
            return
        }
        var timestamp = Time.zero
        var translation = CGSize.zero
        var globalTranslation = CGSize.zero
        var count = 0
        var hasEnded = false
        for (id, event) in events {
            switch event.phase {
            case .began, .active:
                let eventInfo = StateType.EventInfo(
                    globalTranslation: event.globalTranslation,
                    translation: event.translation
                )
                if let info = state.eventInfo[id] {
                    timestamp = max(timestamp, event.timestamp)
                    translation += event.translation - info.translation
                    globalTranslation += event.globalTranslation - info.globalTranslation
                    state.eventInfo[id] = eventInfo
                    count += 1
                } else {
                    state.eventInfo[id] = eventInfo
                    if case .possible = state.phase {
                        state.phaseValue = PanGesture.Value(
                            timestamp: event.timestamp,
                            translation: .zero,
                            touchType: event.touchType,
                            velocity: _Velocity(valuePerSecond: .zero)
                        )
                        if minimumDistance == 0 {
                            state.phase = .active(())
                        }
                    }
                }
            case .ended:
                if state.eventInfo[id] != nil {
                    timestamp = max(timestamp, event.timestamp)
                    state.eventInfo.removeValue(forKey: id)
                }
                hasEnded = true
            case .failed:
                state.phase = .failed
            @unknown default:
                _openSwiftUIUnreachableCode()
            }
        }
        if count != 0 {
            state.globalTranslation += globalTranslation / Double(count)
            if case .possible = state.phase {
                guard !allowedDirections.isEmpty else {
                    state.phase = .failed
                    return
                }
                if Double(minimumDistance) <= state.globalTranslation.magnitude {
                    state.phase = state.globalTranslation.withinRange(
                        axes: allowedDirections,
                        rangeCosine: 0.5
                    ) ? .active(()) : .failed
                }
            }
            let delta = translation / Double(count)
            let duration = timestamp - state.phaseValue.timestamp
            if duration > 0 {
                state.phaseValue.timestamp = timestamp
                state.phaseValue.velocity = _Velocity(valuePerSecond: delta / duration)
            }
            state.phaseValue.translation += delta
        }
        if hasEnded, state.eventInfo.isEmpty {
            if timestamp - state.phaseValue.timestamp > 0.2 {
                state.phaseValue.timestamp = timestamp
                state.phaseValue.velocity = _Velocity(valuePerSecond: .zero)
            }
            if case .active = state.phase {
                state.phase = .ended(())
            } else {
                state.phase = .failed
            }
        }
    }
}
