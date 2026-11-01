//
//  MoveCommand.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - MoveCommandDirection

/// Specifies the direction of an arrow key movement.
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum MoveCommandDirection: Sendable, Hashable {
    case up
    case down
    case left
    case right
}

// MARK: - View + onMoveCommand

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension View {
    /// Adds an action to perform in response to a move command, like when the
    /// user presses an arrow key on a Mac keyboard, or taps the edge of the
    /// Siri Remote when controlling an Apple TV.
    nonisolated public func onMoveCommand(perform action: ((MoveCommandDirection) -> Void)?) -> some View {
        #if os(macOS)
        self
            .onCommand(#selector(NSResponder.moveUp(_:)), perform: action.map { action in { action(.up) } })
            .onCommand(#selector(NSResponder.moveDown(_:)), perform: action.map { action in { action(.down) } })
            .onCommand(#selector(NSResponder.moveLeft(_:)), perform: action.map { action in { action(.left) } })
            .onCommand(#selector(NSResponder.moveRight(_:)), perform: action.map { action in { action(.right) } })
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}
