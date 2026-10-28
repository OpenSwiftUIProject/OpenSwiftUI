//
//  AccessoryCircularGaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - AccessoryCircularGaugeStyle

/// A gauge style that displays an open ring with a marker that appears at a
/// point along the ring to indicate the gauge's current value.
///
/// Use ``GaugeStyle/accessoryCircular`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@MainActor
@preconcurrency
public struct AccessoryCircularGaugeStyle: GaugeStyle {
    /// Creates an accessory circular gauge style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        HalfOpenCircularGauge(configuration: configuration, indicatorStyle: .dot, gradient: nil)
    }
}

@available(*, unavailable)
extension AccessoryCircularGaugeStyle: Sendable {}

// MARK: - GaugeStyle + AccessoryCircularGaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension GaugeStyle where Self == AccessoryCircularGaugeStyle {
    /// A gauge style that displays an open ring with a marker that appears at a
    /// point along the ring to indicate the gauge's current value.
    ///
    /// Apply this style to a ``Gauge`` or to a view hierarchy that contains
    /// gauges using the ``View/gaugeStyle(_:)`` modifier:
    ///
    ///     Gauge(value: batteryLevel, in: 0...100) {
    ///         Text("Battery Level")
    ///     }
    ///     .gaugeStyle(.accessoryCircular)
    ///
    /// This style displays the gauge's `currentValueLabel` value at the center
    /// of the gauge. If you provide `minimumValueLabel` and `maximumValueLabel`
    /// parameters when you create the gauge, they appear in the opening at the
    /// bottom of the ring. Otherwise, the gauge places its label in that
    /// location.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var accessoryCircular: AccessoryCircularGaugeStyle {
        .init()
    }
}

// MARK: - CircularDashboardGaugeStyle

@_spi(Private)
@available(iOS, deprecated, renamed: "AccessoryCircularGaugeStyle")
@available(macOS, deprecated, renamed: "AccessoryCircularGaugeStyle")
@available(tvOS, unavailable)
@available(watchOS, deprecated, renamed: "AccessoryCircularGaugeStyle")
@MainActor
@preconcurrency
public struct CircularDashboardGaugeStyle: GaugeStyle {
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        HalfOpenCircularGauge(configuration: configuration, indicatorStyle: .dot, gradient: nil)
    }
}

@_spi(Private)
@available(*, unavailable)
extension CircularDashboardGaugeStyle: Sendable {}

// MARK: - GaugeStyle + CircularDashboardGaugeStyle

@_spi(Private)
@available(iOS, deprecated)
@available(macOS, deprecated)
@available(tvOS, unavailable)
@available(watchOS, deprecated)
extension GaugeStyle where Self == CircularDashboardGaugeStyle {
    @available(iOS, deprecated, renamed: "accessoryCircular")
    @available(macOS, deprecated, renamed: "accessoryCircular")
    @available(tvOS, unavailable)
    @available(watchOS, deprecated, renamed: "accessoryCircular")
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var circularDashboard: CircularDashboardGaugeStyle {
        .init()
    }
}
