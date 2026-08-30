//
//  DefaultLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

public import OpenSwiftUICore

// MARK: - LabelStyle + DefaultLabelStyle

@available(OpenSwiftUI_v2_0, *)
extension LabelStyle where Self == DefaultLabelStyle {
    /// A label style that resolves its appearance automatically based on the
    /// current context.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultLabelStyle {
        .init()
    }
}

// MARK: - DefaultLabelStyle

/// The default label style in the current context.
///
/// You can also use ``LabelStyle/automatic`` to construct this style.
@available(OpenSwiftUI_v2_0, *)
public struct DefaultLabelStyle: LabelStyle {
    /// Creates an automatic label style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
                .multilineTextAlignment(.leading)
        }
    }
}

@available(*, unavailable)
extension DefaultLabelStyle: Sendable {}
