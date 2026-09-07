//
//  IconOnlyLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

public import OpenSwiftUICore

// MARK: - LabelIconPlatformItemModifier

struct LabelIconPlatformItemModifier: EmptyViewModifier {}

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
    }
}

@available(*, unavailable)
extension IconOnlyLabelStyle: Sendable {}
