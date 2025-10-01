//
//  ShapeStyleResolver.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP

package import OpenAttributeGraphShims

package struct ShapeStyleResolver<Style>: StatefulRule, AsyncAttribute, ObservedAttribute where Style: ShapeStyle {
    @OptionalAttribute var style: Style?
    @OptionalAttribute var mode: _ShapeStyle_ResolverMode?
    @Attribute var environment: EnvironmentValues
    var role: ShapeRole
    var animationsDisabled: Bool
    // var helper: AnimatableAttributeHelper<_ShapeStyle_Pack>
    let tracker: PropertyList.Tracker
    
    package typealias Value = _ShapeStyle_Pack
    
    package init(
        style: OptionalAttribute<Style> = .init(),
        mode: OptionalAttribute<_ShapeStyle_ResolverMode> = .init(),
        environment: Attribute<EnvironmentValues>,
        role: ShapeRole,
        animationsDisabled: Bool
    // helper: AnimatableAttributeHelper<_ShapeStyle_Pack>
    ) {
        _openSwiftUIUnimplementedFailure()
    }
    
    package mutating func updateValue() {
        _openSwiftUIBaseClassAbstractMethod()
    }
    
    package func destroy() {
        // Blocked by _ShapeStyle_Pack
        _openSwiftUIUnimplementedFailure()
    }
}
