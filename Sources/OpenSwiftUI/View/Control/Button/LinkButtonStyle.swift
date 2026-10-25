//
//  LinkButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle + LinkButtonStyle

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension PrimitiveButtonStyle where Self == LinkButtonStyle {
    /// A button style that displays a link.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var link: LinkButtonStyle {
        .init()
    }
}

// MARK: - LinkButtonStyle

/// A button style that displays a link.
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@MainActor
@preconcurrency
public struct LinkButtonStyle: PrimitiveButtonStyle {
    /// Creates a link button style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        #if os(macOS)
        Button(configuration)
            .accessibilityAddTraits(.isLink)
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                    .requiring(MenuStyleContext.self)
            )
            .buttonStyle(AppKitButtonStyle(appearance: .link))
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

@available(*, unavailable)
extension LinkButtonStyle: Sendable {}
