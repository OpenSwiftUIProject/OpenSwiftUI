//
//  Text+Formatter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7267202B6A40C9B73733978AB256B462 (SwiftUICore)

public import Foundation

@available(OpenSwiftUI_v3_0, *)
extension Text {
    public init<F>(
        _ input: F.FormatInput,
        format: F
    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v6_0, *)
extension Text {
    public init<F>(
        _ input: F.FormatInput,
        format: F
    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == AttributedString {
        _openSwiftUIUnimplementedFailure()
    }
}
