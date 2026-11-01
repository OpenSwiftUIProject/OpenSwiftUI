//
//  IsExpandedTraitKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v4_0, *)
@usableFromInline
package struct IsExpandedTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Binding<Bool>? { nil }
}

@available(*, unavailable)
extension IsExpandedTraitKey: Sendable {}
