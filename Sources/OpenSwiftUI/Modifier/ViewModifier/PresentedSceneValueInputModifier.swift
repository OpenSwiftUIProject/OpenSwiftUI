//
//  PresentedSceneValueInputModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: TODO
//  ID: 16926B370582AC5E886A9B0FCFCEA0ED (SwiftUI?)

import OpenAttributeGraphShims
import OpenSwiftUICore

extension WindowGroup {
    // TODO
}

// TODO
public struct PresentedWindowContent {}

// MARK: - PresentedSceneValueInput

private struct PresentedSceneValueInput: ViewInput {
    static var defaultValue: OptionalAttribute<AnyHashable?> { .init() }
}

// MARK: - PresentedSceneValueInputModifier

extension View {
    func presentedSceneValue(
        _ value: AnyHashable?
    ) -> some View {
        modifier(PresentedSceneValueInputModifier(presentedValue: value))
    }
}

private struct PresentedSceneValueInputModifier: ViewInputsModifier {
    var presentedValue: AnyHashable?

    static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs[PresentedSceneValueInput.self] = .init(modifier.value.presentedValue)
    }
}
