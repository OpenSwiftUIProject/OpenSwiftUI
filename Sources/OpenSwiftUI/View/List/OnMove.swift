//
//  OnMove.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenSwiftUICore

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct OnMoveTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: ((IndexSet, Int) -> Void)? { nil }

    @usableFromInline
    typealias Value = ((IndexSet, Int) -> Void)?
}

@available(*, unavailable)
extension OnMoveTraitKey: Sendable {}

@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@usableFromInline
struct OnMoveClipBackgroundTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }

    @usableFromInline
    typealias Value = Bool
}

@available(*, unavailable)
extension OnMoveClipBackgroundTraitKey: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension DynamicViewContent {
    /// Sets the move action for the dynamic view.
    ///
    /// - Parameters:
    ///   - action: A closure that OpenSwiftUI invokes when elements in the dynamic
    ///     view are moved. The closure takes two arguments that represent the
    ///     offset relative to the dynamic view's underlying collection of data.
    ///     Pass `nil` to disable the ability to move items.
    ///
    /// - Returns: A view that calls `action` when elements are moved within the
    ///   original view.
    @inlinable
    nonisolated public func onMove(perform action: ((IndexSet, Int) -> Void)?) -> some DynamicViewContent {
        modifier(_TraitWritingModifier<OnMoveTraitKey>(value: action))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension DynamicViewContent {
    /// Sets the move action and whether to clip its background.
    ///
    /// - Parameters:
    ///   - clipBackground: Whether to clip the background during a move.
    ///   - action: The action to perform when elements move, or `nil` to disable
    ///     moving.
    /// - Returns: A view with the move action and background clipping setting.
    @inlinable
    nonisolated public func onMove(
        clipBackground: Bool,
        perform action: ((IndexSet, Int) -> Void)?
    ) -> some DynamicViewContent {
        modifier(_TraitWritingModifier<OnMoveTraitKey>(value: action))
            .modifier(_TraitWritingModifier<OnMoveClipBackgroundTraitKey>(value: clipBackground))
    }
}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct IsMoveDisabledTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }

    @usableFromInline
    typealias Value = Bool
}

@available(*, unavailable)
extension IsMoveDisabledTraitKey: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds a condition for whether the view's view hierarchy is movable.
    @inlinable
    nonisolated public func moveDisabled(_ isDisabled: Bool) -> some View {
        _trait(IsMoveDisabledTraitKey.self, isDisabled)
    }
}

struct OnMoveDefaultTraitKey: _ViewTraitKey {
    static var defaultValue: ((IndexSet, Int) -> Void)? { nil }
}

struct MoveInteraction: CustomStringConvertible {
    var onMove: ((IndexSet, Int) -> Void)?
    var clipBackground: Bool
    var sourceOffsets: IndexSet
    var contentID: Int

    func move(to destination: Int) {
        guard let onMove else {
            preconditionFailure("Attempting to move (\(sourceOffsets) → \(destination)) with no associated move action.")
        }
        let destination = sourceOffsets.integerLessThan(destination) == nil ? destination : destination &+ 1
        Update.enqueueAction(reason: nil) {
            onMove(sourceOffsets, destination)
        }
    }

    var description: String {
        "MoveInteraction(source: \(sourceOffsets), contentID: \(contentID))"
    }
}

extension ViewTraitCollection {
    var onMove: ((IndexSet, Int) -> Void)? {
        guard !self[IsMoveDisabledTraitKey.self] else {
            return nil
        }
        return self[OnMoveTraitKey.self] ?? self[OnMoveDefaultTraitKey.self]
    }
}
