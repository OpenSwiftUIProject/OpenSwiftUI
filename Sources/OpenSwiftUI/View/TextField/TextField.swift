//
//  TextField.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Stub

public import Foundation
public import OpenSwiftUICore

// MARK: - TextField [TBA]

@available(OpenSwiftUI_v1_0, *)
public struct TextField<Label>: View where Label: View {
    public var body: some View {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension TextField: Sendable {}

// MARK: - TextField + Format [TBA]

extension TextField {
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public init<F>(
        value: Binding<F.FormatInput>,
        format: F,
        prompt: Text? = nil,
        @ViewBuilder label: () -> Label
    ) where F: ParseableFormatStyle, F.FormatOutput == String {
        _openSwiftUIUnimplementedFailure()
    }
}
