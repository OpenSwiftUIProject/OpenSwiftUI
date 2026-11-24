//
//  DefaultGaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - GaugeStyle + DefaultGaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension GaugeStyle where Self == DefaultGaugeStyle {
    /// The default gauge view style in the current context of the view being
    /// styled.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultGaugeStyle {
        .init()
    }
}

// MARK: - DefaultGaugeStyle

/// The default gauge view style in the current context of the view being
/// styled.
///
/// You can also use ``GaugeStyle/automatic`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
public struct DefaultGaugeStyle: GaugeStyle {
    /// Creates a default gauge style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        LinearCapacityGauge(configuration: configuration)
    }
}

@available(*, unavailable)
extension DefaultGaugeStyle: Sendable {}
