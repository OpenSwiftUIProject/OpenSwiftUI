//
//  TitleOnlyLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - LabelStyle + TitleOnlyLabelStyle

@available(OpenSwiftUI_v2_0, *)
extension LabelStyle where Self == TitleOnlyLabelStyle {
    /// A label style that only displays the title of the label.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var titleOnly: TitleOnlyLabelStyle {
        .init()
    }
}

// MARK: - TitleOnlyLabelStyle

/// A label style that only displays the title of the label.
///
/// You can also use ``LabelStyle/titleOnly`` to construct this style.
@available(OpenSwiftUI_v2_0, *)
public struct TitleOnlyLabelStyle: LabelStyle {
    /// Creates a title-only label style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.title
            // A title-only label uses the icon role for its single item.
            .containerValue(\.labelItemRole, .icon)
    }
}

@available(*, unavailable)
extension TitleOnlyLabelStyle: Sendable {}
