//
//  AccessoryLinearGaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 758AE9780E85F32CB11C0E6608B1EB67 (SwiftUI)

@_spi(Private) public import OpenSwiftUICore
import Foundation
import OpenCoreGraphicsShims

// MARK: - GaugeStyle + AccessoryLinearGaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension GaugeStyle where Self == AccessoryLinearGaugeStyle {
    /// A gauge style that displays bar with a marker that appears at a
    /// point along the bar to indicate the gauge's current value.
    ///
    /// Apply this style to a ``Gauge`` or to a view hierarchy that contains
    /// gauges using the ``View/gaugeStyle(_:)`` modifier:
    ///
    ///     Gauge(value: batteryLevel, in: 0...100) {
    ///         Text("Battery Level")
    ///     }
    ///     .gaugeStyle(.accessoryLinear)
    ///
    /// If you provide `minimumValueLabel` and `maximumValueLabel`
    /// parameters when you create the gauge, they appear on leading and
    /// trailing edges of the bar, respectively. Otherwise, the gauge displays
    /// the `currentValueLabel` value on the leading edge.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var accessoryLinear: AccessoryLinearGaugeStyle {
        .init()
    }
}

// MARK: - AccessoryLinearGaugeStyle

/// A gauge style that displays bar with a marker that appears at a
/// point along the bar to indicate the gauge's current value.
///
/// Use ``GaugeStyle/accessoryLinear`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@MainActor
@preconcurrency
public struct AccessoryLinearGaugeStyle: GaugeStyle {
    /// Creates an accessory linear gauge style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        AccessoryLinearGauge(configuration: configuration, gradient: nil)
    }
}

@available(*, unavailable)
extension AccessoryLinearGaugeStyle: Sendable {}

// MARK: - LinearDashboardGaugeStyle

@_spi(Private)
@available(iOS, deprecated, renamed: "AccessoryLinearGaugeStyle")
@available(macOS, deprecated, renamed: "AccessoryLinearGaugeStyle")
@available(tvOS, unavailable)
@available(watchOS, deprecated, renamed: "AccessoryLinearGaugeStyle")
@MainActor
@preconcurrency
public struct LinearDashboardGaugeStyle: GaugeStyle {
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        AccessoryLinearGauge(configuration: configuration, gradient: nil)
    }
}

@_spi(Private)
@available(*, unavailable)
extension LinearDashboardGaugeStyle: Sendable {}

// MARK: - GaugeStyle + LinearDashboardGaugeStyle

@_spi(Private)
@available(iOS, deprecated)
@available(macOS, deprecated)
@available(tvOS, unavailable)
@available(watchOS, deprecated)
extension GaugeStyle where Self == LinearDashboardGaugeStyle {
    @available(iOS, deprecated, renamed: "accessoryLinear")
    @available(macOS, deprecated, renamed: "accessoryLinear")
    @available(tvOS, unavailable)
    @available(watchOS, deprecated, renamed: "accessoryLinear")
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var linearDashboard: LinearDashboardGaugeStyle {
        .init()
    }
}

// MARK: - AccessoryLinearGauge

struct AccessoryLinearGauge: View {
    @ScaledMetric(relativeTo: .title) private var height: CGFloat = 8
    @ScaledMetric(relativeTo: .title) private var font: CGFloat = 17
    let configuration: GaugeStyleConfiguration
    let gradient: Gradient?
    @Environment(\.tint) private var controlTint
    @Environment(\.gaugeTintOverride) private var gaugeTintOverride
    @Environment(\.layoutDirection) private var direction
    @Environment(\.gaugeIndicatorDotTint) private var indicatorDotTint
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.sensitiveContent) private var sensitive

    let metrics = Metrics()

    struct Metrics {}

    init(configuration: GaugeStyleConfiguration, gradient: Gradient?) {
        self.configuration = configuration
        self.gradient = gradient
    }

    private var isRedacted: Bool {
        redactionReasons.contains(.privacy) && sensitive
    }

    private var effectiveTint: AnyShapeStyle {
        if let gradient = gradient ?? controlTint?.as(type: Gradient.self) {
            AnyShapeStyle(LinearGradient(
                gradient: direction == .leftToRight ? gradient : gradient.reversed,
                startPoint: .leading,
                endPoint: .trailing
            ))
        } else {
            controlTint ?? AnyShapeStyle(Color.primary)
        }
    }

    private var effectiveDotTint: AnyShapeStyle {
        if let indicatorDotTint {
            AnyShapeStyle(indicatorDotTint)
        } else if let gaugeTintOverride {
            AnyShapeStyle(gaugeTintOverride.0)
        } else if let gradient = gradient ?? controlTint?.as(type: Gradient.self) {
            AnyShapeStyle(gradient.color(at: CGFloat(configuration.value)))
        } else {
            effectiveTint
        }
    }

    var body: some View {
        HStack {
            if let minimumValueLabel = configuration.minimumValueLabel {
                minimumValueLabel.foregroundLayer()
            } else {
                configuration.currentValueLabel.foregroundLayer()
            }
            ZStack {
                Capsule()
                    .fill((gaugeTintOverride.map { AnyShapeStyle($0.1) } ?? effectiveTint)
                        .opacity(isRedacted ? 0.3 : 1))
                    .foregroundLayer()
                GeometryReader { proxy in
                    content(proxy)
                }
            }
            .compositingGroup()
            configuration.maximumValueLabel.foregroundLayer()
        }
        .frame(height: height)
        .font(.system(size: font, weight: .semibold, design: .rounded))
        .accessibilityRepresentation {
            HStack {
                configuration.label
                configuration.currentValueLabel
            }
        }
    }

    func content(_ proxy: GeometryProxy) -> some View {
        let offset = (isRedacted ? 0 : configuration.value) * (proxy.size.width - height)
        return ZStack {
            Circle()
                .inset(by: -4)
                .fill(Color.black.opacity(isRedacted ? 0 : 1))
                .frame(width: height, height: height)
                .offset(x: offset)
                .blendMode(.destinationOut)
            Circle()
                .fill(effectiveDotTint.opacity(isRedacted ? 0 : 1))
                .frame(width: height, height: height)
                .offset(x: offset)
        }
    }
}
