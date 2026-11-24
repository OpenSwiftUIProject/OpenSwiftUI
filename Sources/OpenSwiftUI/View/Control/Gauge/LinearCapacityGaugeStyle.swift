//
//  LinearCapacityGaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore
import Foundation
import OpenCoreGraphicsShims

#if os(macOS)
import AppKit
#endif

// MARK: - LinearCapacityGaugeStyle

/// A gauge style that displays bar that fills from leading to trailing
/// edges as the gauge's current value increases.
///
/// Use ``GaugeStyle/linearCapacity`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@MainActor
@preconcurrency
public struct LinearCapacityGaugeStyle: GaugeStyle {
    /// Creates a linear capacity gauge style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        LinearCapacityGauge(configuration: configuration)
    }
}

@available(*, unavailable)
extension LinearCapacityGaugeStyle: Sendable {}

// MARK: - GaugeStyle + LinearCapacityGaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension GaugeStyle where Self == LinearCapacityGaugeStyle {
    /// A gauge style that displays a bar that fills from leading to trailing
    /// edges as the gauge's current value increases.
    ///
    /// Apply this style to a ``Gauge`` or to a view hierarchy that contains
    /// gauges using the ``View/gaugeStyle(_:)`` modifier:
    ///
    ///     Gauge(value: batteryLevel, in: 0...100) {
    ///         Text("Battery Level")
    ///     }
    ///     .gaugeStyle(.linearCapacity)
    ///
    /// If you provide `minimumValueLabel` and `maximumValueLabel`
    /// parameters when you create the gauge, they appear on leading and
    /// trailing edges of the bar, respectively. The `label` appears above
    /// the gauge, and the `currentValueLabel` appears below.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var linearCapacity: LinearCapacityGaugeStyle {
        .init()
    }
}

// MARK: - LinearCapacityGauge

struct LinearCapacityGauge: View {
    let configuration: GaugeStyleConfiguration
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.sensitiveContent) private var sensitive

    init(configuration: GaugeStyleConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        VStack {
            configuration.label
            HStack {
                configuration.minimumValueLabel
                #if os(macOS)
                AppKitLinearCapacityGauge(
                    value: redactionReasons.contains(.privacy) && sensitive ? 0 : configuration.value
                )
                #else
                LinearCapsuleGauge(
                    value: redactionReasons.contains(.privacy) && sensitive ? 0 : configuration.value
                )
                #endif
                configuration.maximumValueLabel
            }
            configuration.currentValueLabel
        }
        .accessibilityRepresentation {
            HStack {
                configuration.label
                configuration.currentValueLabel
            }
        }
    }
}

// MARK: - AppKitLinearCapacityGauge

#if os(macOS)
struct AppKitLinearCapacityGauge: NSViewRepresentable {
    var value: Double
    @Environment(\.tintColor) private var controlTint
    @Environment(\.controlSize) private var controlSize

    func makeNSView(context _: Context) -> NSLevelIndicator {
        let nsView = NSLevelIndicator()
        nsView.minValue = 0
        nsView.maxValue = 1
        nsView.levelIndicatorStyle = .continuousCapacity
        return nsView
    }

    func updateNSView(_ nsView: NSLevelIndicator, context _: Context) {
        if let controlTint {
            nsView.fillColor = NSColor(controlTint)
        }
        let controlSize = NSControl.ControlSize(controlSize)
        if nsView.controlSize != controlSize {
            nsView.controlSize = controlSize
        }
        nsView.doubleValue = value
    }
}
#endif

// MARK: - LinearCapsuleGauge

struct LinearCapsuleGauge: View {
    private var value: Double
    @ScaledMetric private var height: CGFloat
    @Environment(\.gaugeTintOverride) private var gaugeTintOverride
    @Environment(\.tint) private var controlTint
    @Environment(\.layoutDirection) private var direction

    init(value: Double, height: CGFloat = 16.0) {
        self.value = value
        self._height = ScaledMetric(wrappedValue: height)
    }

    var effectiveFillStyle: AnyShapeStyle {
        if let gaugeTintOverride {
            AnyShapeStyle(gaugeTintOverride.0)
        } else if let gradient = controlTint?.as(type: Gradient.self) {
            AnyShapeStyle(LinearGradient(
                gradient: direction == .leftToRight ? gradient : gradient.reversed,
                startPoint: .leading,
                endPoint: .trailing
            ))
        } else {
            AnyShapeStyle(TintShapeStyle())
        }
    }

    var body: some View {
        ZStack {
            #if os(macOS)
            Capsule().fill(gaugeTintOverride?.1 ?? .gray)
            #else
            Capsule().fill(gaugeTintOverride?.1 ?? .tertiarySystemFill)
            #endif
            GeometryReader { proxy in
                indicator(width: proxy.size.width)
            }
        }
        .frame(height: height)
    }

    func indicator(width: CGFloat) -> some View {
        let offset = (direction == .leftToRight ? -width : width) * (1 - value)
        return Capsule()
            .fill(effectiveFillStyle)
            .clipShape(IndicatorClip(offset: offset))
    }

    private struct IndicatorClip: Shape {
        var offset: CGFloat

        nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior {
            .fixed
        }

        nonisolated func path(in rect: CGRect) -> Path {
            Capsule().path(in: rect.offsetBy(dx: offset, dy: 0))
        }

        var animatableData: CGFloat {
            get { offset }
            set { offset = newValue }
        }
    }
}
