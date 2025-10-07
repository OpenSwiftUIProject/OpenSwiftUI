//
//  LabeledView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by Text

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "LabeledContent")
public struct LabeledView<Label, Content>: View where Label: View, Content: View {
    var label: Label

    var content: Content

    public init(
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

//@_spi(Private)
//@available(OpenSwiftUI_v4_0, *)
//@available(*, deprecated, renamed: "LabeledContent")
//extension LabeledView where Label == Text {
//    public init(
//        _ titleKey: LocalizedStringKey,
//        @ViewBuilder content: () -> Content
//    ) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    @_disfavoredOverload
//    public init<S>(
//        _ title: S,
//        @ViewBuilder content: () -> Content
//    ) where S: StringProtocol {
//        _openSwiftUIUnimplementedFailure()
//    }
//}
//
//@_spi(Private)
//@available(OpenSwiftUI_v4_0, *)
//@available(*, deprecated, renamed: "LabeledContent")
//extension LabeledView where Label == Text, Content == Text {
//    public init<S>(
//        _ titleKey: LocalizedStringKey,
//        value: S
//    ) where S: StringProtocol {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    @_disfavoredOverload
//    public init<S1, S2>(
//        _ title: S1,
//        value: S2
//    ) where S1: StringProtocol, S2: StringProtocol {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    public init<F>(
//        _ titleKey: LocalizedStringKey,
//        value: F.FormatInput,
//        format: F
//    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    public init<S, F>(
//        _ title: S,
//        value: F.FormatInput,
//        format: F
//    ) where S: StringProtocol, F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
//        _openSwiftUIUnimplementedFailure()
//    }
//}
