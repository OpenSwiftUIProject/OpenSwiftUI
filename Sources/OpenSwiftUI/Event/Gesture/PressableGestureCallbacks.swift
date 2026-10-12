//
//  PressableGestureCallbacks.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C70334A42970E36EF599A57E69899EA7 (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - PressableEventValue

protocol PressableEventValue: Equatable {
    var pressLocation: CGPoint? { get }

    static func isPressing(_ phase: GesturePhase<Self>) -> Bool
}

extension PressableEventValue {
    var pressLocation: CGPoint? { nil }
}

// MARK: - Gesture + PressableEventValue

extension Gesture where Value: PressableEventValue {
    func callbacks(
        pressing: ((Bool) -> Void)?,
        pressed: (() -> Void)?
    ) -> some Gesture<Value> {
        callbacks(PressableGestureCallbacks<Value>(
            pressing: pressing,
            pressed: { _ in pressed?() }
        ))
        .cancellable()
    }
}

// MARK: - PressableGestureCallbacks

private struct PressableGestureCallbacks<Value>: GestureCallbacks where Value: PressableEventValue {
    var pressing: ((Bool) -> Void)?

    var pressed: ((CGPoint?) -> Void)?

    static var initialState: Bool { false }

    func dispatch(phase: GesturePhase<Value>, state: inout Bool) -> (() -> Void)? {
        switch phase {
        case let .ended(value):
            let wasPressing = state
            state = false
            if wasPressing, let pressing {
                if let pressed {
                    return {
                        pressing(false)
                        pressed(value.pressLocation)
                    }
                } else {
                    return { pressing(false) }
                }
            } else {
                return bind(pressed, value.pressLocation)
            }
        case .failed:
            let wasPressing = state
            state = false
            return wasPressing ? bind(pressing, false) : nil
        default:
            let isPressing = Value.isPressing(phase)
            guard isPressing != state else {
                return nil
            }
            state = isPressing
            return bind(pressing, isPressing)
        }
    }

    func cancel(state: Bool) -> (() -> Void)? {
        state ? bind(pressing, false) : nil
    }
}
