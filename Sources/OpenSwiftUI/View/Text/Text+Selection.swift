//
//  Text+Selection.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - View + textSelection

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    /// Controls whether people can select text within this view.
    nonisolated public func textSelection<S>(_ selectability: S) -> some View where S: TextSelectability {
        modifier(TextSelectabilityModifier<S>())
    }
}

// MARK: - TextSelectabilityModifier [TBA]

struct TextSelectabilityModifier<S>: PrimitiveViewModifier, _GraphInputsModifier where S: TextSelectability {
    nonisolated init() {
        _openSwiftUIEmptyStub()
    }

    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs[TextAllowsSelection.self] = S.allowsSelection
        #if os(iOS) || os(visionOS)
        inputs.textSelectionRepresentation = UIKitTextSelectionRepresentation.self
        #elseif os(macOS)
        inputs.textSelectionRepresentation = AppKitTextSelectionRepresentation.self
        #endif
    }
}
