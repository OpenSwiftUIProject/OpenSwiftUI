//
//  LeadingTrailingLabeledContentStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 883FC595DC5A078A9D167DD7587DD054 (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - LeadingTrailingLabeledContentStyle

struct LeadingTrailingLabeledContentStyle: LabeledContentStyle {
    let spacing: CGFloat?

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .staticIf(_SemanticFeature_v4.self) { label in
                    VStack(alignment: .leading, spacing: spacing){
                        LabelGroup { label }
                    }
                }
            Spacer().layoutPriority(-1)
            HStack {
                configuration.content
            }
            .defaultForegroundColor(.secondary)
        }
        .spacing(Spacing())
    }
}

// MARK: - LabeledContentUsesLegacyLayout

struct LabeledContentUsesLegacyLayout: ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        !isLinkedOnOrAfter(.v6)
    }
}

#if os(iOS) || os(visionOS)
// MARK: - LeadingTrailingLabeledContentStyle_Phone [TODO]

struct LeadingTrailingLabeledContentStyle_Phone: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedWarning()
        return VStack {
            configuration.label
            configuration.content
        }
    }
}
#endif

// MARK: - ListLabeledContentPrefersHorizontalLayout

struct ListLabeledContentPrefersHorizontalLayout: ViewInputBoolFlag {}

extension View {
    func listLabeledContentPrefersHorizontalLayout() -> some View {
        input(ListLabeledContentPrefersHorizontalLayout.self)
    }
}

// TODO: AdaptiveLeadingTrailingLabeledContentStyle
