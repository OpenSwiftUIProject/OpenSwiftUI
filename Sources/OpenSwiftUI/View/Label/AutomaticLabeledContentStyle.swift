//
//  AutomaticLabeledContentStyle.swift
//  OpenSwiftUI
//
//  Audited fror 6.5.4
//  Status: WIP

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

    // FIXME
    public func makeBody(configuration: AutomaticLabeledContentStyle.Configuration) -> some View {
        LabeledContent {
            configuration.content
                .modifier(_LabeledContentStyleModifier(style: self))
        } label: {
            configuration.label
                .staticIf(LabelVisibilityConfigured.self) { label in
                    labelsVisibility == .hidden ? nil : configuration.label
                }
        }
    }
}

@available(*, unavailable)
extension AutomaticLabeledContentStyle: Sendable {}
