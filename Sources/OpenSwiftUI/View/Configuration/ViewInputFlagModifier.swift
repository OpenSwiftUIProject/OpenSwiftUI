//
//  ViewInputFlagModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 481852E6B9C17510DAAE09E84ECE4A2D (SwiftUI?)

struct ViewInputFlagModifier<Flag>: _GraphInputsModifier, PrimitiveViewModifier where Flag: ViewInputFlag {
    var flag: Flag

    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        Flag._makeInputs(
            modifier: modifier[offset: { .of(&$0.flag) }],
            inputs: &inputs
        )
    }
}

extension View {
    nonisolated func input<Flag>(_ flag: Flag.Type) -> some View where Flag: ViewInputFlag {
        modifier(ViewInputFlagModifier(flag: flag.init()))
    }
}

private struct FalseViewInputBoolFlagModifier<Flag>: _GraphInputsModifier, MultiViewModifier, PrimitiveViewModifier where Flag: ViewInputBoolFlag {
    var flag: Flag

    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs[Flag.self] = false
    }
}

extension View {
    nonisolated func input<Flag>(_ flag: Flag.Type) -> some View where Flag: ViewInputBoolFlag {
        modifier(ViewInputFlagModifier(flag: flag.init()))
    }
}
