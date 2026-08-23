//
//  DefaultProgressViewStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - ProgressViewStyle + Automatic

@available(OpenSwiftUI_v2_0, *)
extension ProgressViewStyle where Self == DefaultProgressViewStyle {

    /// The default progress view style in the current context of the view being
    /// styled.
    ///
    /// The default style represents the recommended style based on the original
    /// initialization parameters of the progress view, and the progress view's
    /// context within the view hierarchy.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultProgressViewStyle {
        .init()
    }
}

// MARK: - DefaultProgressViewStyle

/// The default progress view style in the current context of the view being
/// styled.
///
/// Use ``ProgressViewStyle/automatic`` to construct this style.
@available(OpenSwiftUI_v2_0, *)
public struct DefaultProgressViewStyle: ProgressViewStyle {
    /// Creates a default progress view style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.alwaysIndeterminate {
                ProgressView(configuration)
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                switch configuration.value {
                case .dateRelative:
                    ProgressView(configuration)
                        .progressViewStyle(LinearProgressViewStyle())
                case .absolute:
                    if configuration.fractionCompleted != nil {
                        ProgressView(configuration)
                            .progressViewStyle(LinearProgressViewStyle())
                    } else {
                        ProgressView(configuration)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            }
        }
    }
}

@available(*, unavailable)
extension DefaultProgressViewStyle: Sendable {}
