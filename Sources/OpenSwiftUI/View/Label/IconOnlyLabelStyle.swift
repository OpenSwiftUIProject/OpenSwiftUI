//
//  IconOnlyLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - LabelStyle + IconOnlyLabelStyle

@available(OpenSwiftUI_v2_0, *)
extension LabelStyle where Self == IconOnlyLabelStyle {
    /// A label style that only displays the icon of the label.
    ///
    /// The title of the label is still used for non-visual descriptions, such as
    /// VoiceOver.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var iconOnly: IconOnlyLabelStyle {
        .init()
    }
}

// MARK: - IconOnlyLabelStyle

/// A label style that only displays the icon of the label.
///
/// You can also use ``LabelStyle/iconOnly`` to construct this style.
@available(OpenSwiftUI_v2_0, *)
public struct IconOnlyLabelStyle: LabelStyle {
    /// Creates an icon-only label style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .containerValue(\.labelItemRole, .icon)
            .accessibilityCombinedElement(options: [], ignoredTraits: [])
            .accessibilityLabel(.assign) {
                configuration.title
            }
            .input(AccessibilityShowsLabelIcon.self)
            .modifier(LabelIconPlatformItemModifier())
    }
}

@available(*, unavailable)
extension IconOnlyLabelStyle: Sendable {}

// MARK: - LabelIconPlatformItemModifier

struct LabelIconPlatformItemModifier: PrimitiveViewModifier, UnaryPlatformItemsModifier {
    static var features: PlatformItem.Features { .iconText }

    static func updateItem(modifier: LabelIconPlatformItemModifier, item: inout PlatformItem) {
        if let text = item.content?.text, item.content?.iconText == nil {
            item.content?.iconText = text
            item.content?.text = nil
        }
    }
}
