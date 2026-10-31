//
//  LabeledView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenSwiftUICore

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(iOS, deprecated: 100000.0, renamed: "LabeledContent")
@available(macOS, deprecated: 100000.0, renamed: "LabeledContent")
@available(tvOS, deprecated: 100000.0, renamed: "LabeledContent")
@available(watchOS, deprecated: 100000.0, renamed: "LabeledContent")
public struct LabeledView<Label, Content>: View where Label: View, Content: View {
    var label: Label

    var content: Content

    nonisolated public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        LabeledContent {
            content
        } label: {
            label
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension LabeledView: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "LabeledContent")
extension LabeledView where Label == Text {
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.init(content: content) {
            Text(titleKey)
        }
    }

    @_disfavoredOverload
    nonisolated public init<S>(
        _ title: S,
        @ViewBuilder content: () -> Content
    ) where S: StringProtocol {
        self.init(content: content) {
            Text(title)
        }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "LabeledContent")
extension LabeledView where Label == Text, Content == Text {
    nonisolated public init<S>(
        _ titleKey: LocalizedStringKey,
        value: S
    ) where S: StringProtocol {
        self.init(titleKey) {
            Text(value)
        }
    }

    @_disfavoredOverload
    nonisolated public init<S1, S2>(
        _ title: S1,
        value: S2
    ) where S1: StringProtocol, S2: StringProtocol {
        self.init(title) {
            Text(value)
        }
    }

    nonisolated public init<F>(
        _ titleKey: LocalizedStringKey,
        value: F.FormatInput,
        format: F
    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(titleKey) {
            Text(value, format: format)
        }
    }

    nonisolated public init<S, F>(
        _ title: S,
        value: F.FormatInput,
        format: F
    ) where S: StringProtocol, F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(title) {
            Text(value, format: format)
        }
    }
}
