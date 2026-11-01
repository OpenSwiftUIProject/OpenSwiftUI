//
//  OnDelete.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenSwiftUICore

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct OnDeleteTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: ((IndexSet) -> Void)? { nil }

    @usableFromInline
    typealias Value = ((IndexSet) -> Void)?
}

@available(*, unavailable)
extension OnDeleteTraitKey: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension DynamicViewContent {
    /// Sets the deletion action for the dynamic view. You must delete the
    /// corresponding item within `action`, as it will be called after the
    /// row has already been removed from the ``List``.
    ///
    /// - Parameter action: The action that you want OpenSwiftUI to perform when
    ///   elements in the view are deleted. OpenSwiftUI passes a set of indices to the
    ///   closure that's relative to the dynamic view's underlying collection of
    ///   data.
    ///
    /// - Returns: A view that calls `action` when elements are deleted from the
    ///   original view.
    @inlinable
    nonisolated public func onDelete(perform action: ((IndexSet) -> Void)?) -> some DynamicViewContent {
        modifier(_TraitWritingModifier<OnDeleteTraitKey>(value: action))
    }
}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct IsDeleteDisabledTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }

    @usableFromInline
    typealias Value = Bool
}

@available(*, unavailable)
extension IsDeleteDisabledTraitKey: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds a condition for whether the view's view hierarchy is deletable.
    @inlinable
    nonisolated public func deleteDisabled(_ isDisabled: Bool) -> some View {
        _trait(IsDeleteDisabledTraitKey.self, isDisabled)
    }
}

struct OnDeleteDefaultTraitKey: _ViewTraitKey {
    static var defaultValue: ((IndexSet) -> Void)? { nil }
}

struct DeleteInteraction {
    var contentID: Int
    var indexSet: IndexSet
    var onDelete: ((IndexSet) -> Void)?

    func delete() {
        guard let onDelete else {
            preconditionFailure("Attempting to delete row (indices: \(indexSet) with no associated delete action.")
        }
        Update.enqueueAction(reason: nil) {
            onDelete(indexSet)
        }
    }
}

extension ViewTraitCollection {
    var deleteInteraction: DeleteInteraction? {
        guard let offset = self[DynamicViewContentOffsetTraitKey.self],
              let contentID = self[DynamicViewContentIDTraitKey.self],
              let onDelete = self[OnDeleteTraitKey.self] ?? self[OnDeleteDefaultTraitKey.self] else {
            return nil
        }
        return DeleteInteraction(
            contentID: contentID,
            indexSet: IndexSet(integer: offset),
            onDelete: self[IsDeleteDisabledTraitKey.self] ? nil : onDelete
        )
    }
}
