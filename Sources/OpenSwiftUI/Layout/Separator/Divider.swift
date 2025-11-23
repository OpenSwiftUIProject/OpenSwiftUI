//
//  Divider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A41482AADD0929733C3343B5E142E952 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - Divider

/// A visual element that can be used to separate other content.
///
/// When contained in a stack, the divider extends across the minor axis of the
/// stack, or horizontally when not in a stack.
@available(OpenSwiftUI_v1_0, *)
public struct Divider: View, UnaryView, PrimitiveView {

    public init() {
        _openSwiftUIEmptyStub()
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        if inputs.preferences.requiresPlatformItemList {
            newInputs.preferences.requiresPlatformItemList = false
            newInputs.requestedTextRepresentation = nil
        }
        let orientation = inputs.stackOrientation
        let child = Attribute(
            Child(
                orientation: orientation,
                dynamicOrientation: orientation == nil ? inputs.dynamicStackOrientation : .init()
            )
        )
        var outputs = ResolvedDivider.makeDebuggableView(
            view: .init(child),
            inputs: newInputs
        )
        if let representation = inputs.requestedDividerRepresentation,
           representation.shouldMakeRepresentation(inputs: inputs) {
            representation.makeRepresentation(inputs: inputs, outputs: &outputs)
        }
        return outputs
    }

    private struct Child: Rule {
        var orientation: Axis?
        @OptionalAttribute var dynamicOrientation: Axis??

        var value: ResolvedDivider {
            let axis: Axis
            if let orientation {
                axis = orientation
            } else if let dynamicOrientation {
                axis = dynamicOrientation ?? .vertical
            } else {
                axis = .vertical
            }
            return ResolvedDivider(configuration: .init(orientation: axis.otherAxis))
        }
    }
}

@available(*, unavailable)
extension Divider: Sendable {}

// MARK: - PlatformDividerRepresentable

package protocol PlatformDividerRepresentable {
    static func shouldMakeRepresentation(
        inputs: _ViewInputs
    ) -> Bool

    static func makeRepresentation(
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    )
}

extension _ViewInputs {
    package var requestedDividerRepresentation: (any PlatformDividerRepresentable.Type)? {
        get { base.requestedDividerRepresentation }
        set { base.requestedDividerRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct DividerRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformDividerRepresentable.Type)? { nil }
    }

    package var requestedDividerRepresentation: (any PlatformDividerRepresentable.Type)? {
        get { self[DividerRepresentationKey.self] }
        set { self[DividerRepresentationKey.self] = newValue }
    }
}
