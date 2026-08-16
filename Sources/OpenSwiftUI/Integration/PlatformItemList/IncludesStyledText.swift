//
//  IncludesStyledText.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - IncludesStyledTextModifier

struct IncludesStyledTextModifier: PrimitiveViewModifier, _GraphInputsModifier {
    static func _makeInputs(
        modifier _: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        inputs.includesStyledText = true
    }
}

// MARK: - IncludesStyledText

struct IncludesStyledText: ViewInputBoolFlag {
    init() {
        _openSwiftUIEmptyStub()
    }
}

extension _GraphInputs {
    @inline(__always)
    var includesStyledText: Bool {
        get { self[IncludesStyledText.self] }
        set { self[IncludesStyledText.self] = newValue }
    }
}

extension _ViewInputs {
    @inline(__always)
    var includesStyledText: Bool {
        get { base.includesStyledText }
        set { base.includesStyledText = newValue }
    }
}
