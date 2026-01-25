//
//  PreviewColorSchemeTrait.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v2_3, *)
@usableFromInline
package struct PreviewColorSchemeTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: ColorScheme? { nil }
}

@available(*, unavailable)
extension PreviewColorSchemeTraitKey: Sendable {}
