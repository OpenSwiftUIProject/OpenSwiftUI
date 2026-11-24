//
//  AccessoryLinearCapacityGaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - AccessoryLinearCapacityGaugeStyle

/// A gauge style that displays bar that fills from leading to trailing
/// edges as the gauge's current value increases.
///
/// Use ``GaugeStyle/accessoryLinearCapacity`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@MainActor
@preconcurrency
public struct AccessoryLinearCapacityGaugeStyle: GaugeStyle {
    /// Creates an accessory linear capacity gauge style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        ProgressViewGauge(configuration: configuration)
    }
}

@available(*, unavailable)
extension AccessoryLinearCapacityGaugeStyle: Sendable {}

// MARK: - GaugeStyle + AccessoryLinearCapacityGaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension GaugeStyle where Self == AccessoryLinearCapacityGaugeStyle {
    /// A gauge style that displays bar that fills from leading to trailing
    /// edges as the gauge's current value increases.
    ///
    /// Apply this style to a ``Gauge`` or to a view hierarchy that contains
    /// gauges using the ``View/gaugeStyle(_:)`` modifier:
    ///
    ///     Gauge(value: batteryLevel, in: 0...100) {
    ///         Text("Battery Level")
    ///     }
    ///     .gaugeStyle(.accessoryLinearCapacity)
    ///
    /// If you provide `minimumValueLabel` and `maximumValueLabel`
    /// parameters when you create the gauge, they appear on leading and
    /// trailing edges of the bar, respectively. The `label` appears above
    /// the gauge, and the `currentValueLabel` appears below.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var accessoryLinearCapacity: AccessoryLinearCapacityGaugeStyle {
        .init()
    }
}

// MARK: - GaugeStyle + LinearPercentageGaugeStyle

@_spi(Private)
@available(iOS, deprecated)
@available(macOS, deprecated)
@available(tvOS, unavailable)
@available(watchOS, deprecated)
extension GaugeStyle where Self == LinearPercentageGaugeStyle {
    @available(iOS, deprecated, message: "In complication-like contexts, use `accessoryLinearCapacity`, otherwise, use `linearCapacity`.")
    @available(macOS, deprecated, message: "In complication-like contexts, use `accessoryLinearCapacity`, otherwise, use `linearCapacity`.")
    @available(watchOS, deprecated, renamed: "linearCapacity")
    @available(tvOS, unavailable)
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var linearPercentage: LinearPercentageGaugeStyle {
        .init()
    }
}

// MARK: - LinearPercentageGaugeStyle

@_spi(Private)
@available(iOS, deprecated, message: "In complication-like contexts, use `accessoryLinearCapacity`, otherwise, use `linearCapacity`.")
@available(macOS, deprecated, message: "In complication-like contexts, use `accessoryLinearCapacity`, otherwise, use `linearCapacity`.")
@available(watchOS, deprecated, renamed: "linearCapacity")
@available(tvOS, unavailable)
@MainActor
@preconcurrency
public struct LinearPercentageGaugeStyle: GaugeStyle {
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        ProgressViewGauge(configuration: configuration)
    }
}

@_spi(Private)
@available(*, unavailable)
extension LinearPercentageGaugeStyle: Sendable {}

// MARK: - ProgressViewGauge

struct ProgressViewGauge: View {
    let configuration: GaugeStyleConfiguration
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.sensitiveContent) private var sensitive

    init(configuration: GaugeStyleConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        VStack {
            HStack {
                configuration.minimumValueLabel
                ProgressView(value: redactionReasons.contains(.privacy) && sensitive ? 0 : configuration.value) {
                    configuration.label
                } currentValueLabel: {
                    configuration.currentValueLabel
                }
                configuration.maximumValueLabel
            }
        }
    }
}
