//
//  ListStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenSwiftUICore

struct AnyListStyleContext: StyleContext {}

// TODO: ListStyleContext conformance and matching rules.
struct PlainListStyleContext: StyleContext {}

extension StyleContext where Self == PlainListStyleContext {
    static var plainList: PlainListStyleContext {
        .init()
    }
}

struct SidebarListStyleContext: StyleContext {}

extension StyleContext where Self == SidebarListStyleContext {
    static var sidebarList: SidebarListStyleContext {
        .init()
    }
}

struct InsetListStyleContext: StyleContext {}

extension StyleContext where Self == InsetListStyleContext {
    static var insetList: InsetListStyleContext {
        .init()
    }
}

struct GroupedListStyleContext: StyleContext {}

extension StyleContext where Self == GroupedListStyleContext {
    static var groupedList: GroupedListStyleContext {
        .init()
    }
}

struct InsetGroupedListStyleContext: StyleContext {}

extension StyleContext where Self == InsetGroupedListStyleContext {
    static var insetGroupedList: InsetGroupedListStyleContext {
        .init()
    }
}

struct GroupedFormStyleContext: StyleContext {}

extension StyleContext where Self == GroupedFormStyleContext {
    static var groupedForm: GroupedFormStyleContext {
        .init()
    }
}

struct ColumnsFormStyleContext: StyleContext {}

struct FormBoxStyleContext: StyleContext {}

struct GroupedFormValueStyleContext: StyleContext {}

struct GroupedFormTextFieldStyleContext: StyleContext {}

struct RadioGroupStyleContext: StyleContext {}

struct ColumnarLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}

struct FormBoxLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}

struct GroupedFormLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}

struct GroupedFormTextFieldLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}

struct ToolbarLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}
