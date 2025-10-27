//
//  AutomaticLabeledContentStyle.swift
//  OpenSwiftUI
//
//  Audited fror 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

@available(OpenSwiftUI_v4_0, *)
extension LabeledContentStyle where Self == AutomaticLabeledContentStyle {

    /// A labeled content style that resolves its appearance automatically based
    /// on the current context.
    @MainActor
    @preconcurrency
    public static var automatic: AutomaticLabeledContentStyle {
        .init()
    }
}

/// The default labeled content style.
///
/// Use ``LabeledContentStyle/automatic`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
public struct AutomaticLabeledContentStyle: LabeledContentStyle {

    @Environment(\.labelsVisibility)
    private var labelsVisibility: Visibility

    /// Creates an automatic labeled content style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: AutomaticLabeledContentStyle.Configuration) -> some View {
        #if os(iOS) || os(visionOS)
        LabeledContent {
            configuration.content
                .labeledContentStyle(self)
        } label: {
            configuration.label
                .staticIf(LabelVisibilityConfigured.self) { label in
                    labelsVisibility == .hidden ? nil : configuration.label
                }
        }
        .modifier(
            _LabeledContentStyleModifier(style: LeadingTrailingLabeledContentStyle_Phone())
                .requiring(AnyListStyleContext.self)
                .requiring(LabeledContentUsesLegacyLayout.Inverted.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: LeadingTrailingLabeledContentStyle(spacing: nil))
                .requiring(AnyListStyleContext.self)
                .requiring(LabeledContentUsesLegacyLayout.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: LeadingTrailingLabeledContentStyle(spacing: nil))
                .requiring(GroupedFormStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: ColumnarLabeledContentStyle())
                .requiring(ColumnsFormStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: AccessibilityLabeledContentStyle())
                .requiring(AccessibilityRepresentableStyleContext.self)
        )
        .labeledContentStyle(LeadingTrailingLabeledContentStyle(spacing: nil))
        #elseif os(macOS)
        LabeledContent {
            configuration.content
                .labeledContentStyle(self)
        } label: {
            configuration.label
                .staticIf(LabelVisibilityConfigured.self) { label in
                    labelsVisibility == .hidden ? nil : configuration.label
                }
        }
        .modifier(
            _LabeledContentStyleModifier(style: LeadingTrailingLabeledContentStyle(spacing: nil)) //TODO
                .requiring(AnyListStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: FormBoxLabeledContentStyle())
                .requiring(FormBoxStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: FormBoxLabeledContentStyle())
                .requiring(GroupedFormValueStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: GroupedFormLabeledContentStyle())
                .requiring(GroupedFormStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: ColumnarLabeledContentStyle())
                .requiring(ColumnsFormStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: GroupedFormTextFieldLabeledContentStyle())
                .requiring(GroupedFormTextFieldStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: ColumnarLabeledContentStyle())
                .requiring(RadioGroupStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: ToolbarLabeledContentStyle())
                .requiring(ToolbarStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: AccessibilityLabeledContentStyle())
                .requiring(AccessibilityRepresentableStyleContext.self)
        )
        .modifier(
            _LabeledContentStyleModifier(style: HStackLabeledContentStyle())
                .requiring(InterfaceIdiomPredicate<MacInterfaceIdiom>.self)
        )
        .labeledContentStyle(LeadingTrailingLabeledContentStyle(spacing: 2.0))
        #else
        LabeledContent {
            configuration.content
                .labeledContentStyle(self)
        } label: {
            configuration.label
                .staticIf(LabelVisibilityConfigured.self) { label in
                    labelsVisibility == .hidden ? nil : configuration.label
                }
        }
        .labeledContentStyle(LeadingTrailingLabeledContentStyle(spacing: nil))
        #endif
    }
}

@available(*, unavailable)
extension AutomaticLabeledContentStyle: Sendable {}

#if os(macOS)
// TODO
struct HStackLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .staticIf(_SemanticFeature_v4.self) { label in
                    VStack(alignment: .leading){
                        LabelGroup { label }
                    }
                }
            Spacer()
            HStack {
                configuration.content
            }.layoutPriority(-1)
        }
        .spacing(Spacing())
    }
}
#endif
