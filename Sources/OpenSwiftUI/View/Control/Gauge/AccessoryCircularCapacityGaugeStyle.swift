//
//  AccessoryCircularCapacityGaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 53299BC8DAC0E961D0C984B61B42156B (SwiftUI)

@_spi(Private) public import OpenSwiftUICore
import Foundation
import OpenCoreGraphicsShims

// MARK: - AccessoryCircularCapacityGaugeStyle

/// A gauge style that displays a closed ring that's partially filled in to
/// indicate the gauge's current value.
///
/// Use ``GaugeStyle/accessoryCircularCapacity`` to construct this style.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@MainActor
@preconcurrency
public struct AccessoryCircularCapacityGaugeStyle: GaugeStyle {
    var halfOpen: Bool

    /// Creates an accessory circular capacity gauge style.
    public init() {
        halfOpen = false
    }

    @_spi(Private)
    public init(halfOpen: Bool) {
        self.halfOpen = halfOpen
    }

    public func makeBody(configuration: Configuration) -> some View {
        if halfOpen {
            HalfOpenCircularGauge(configuration: configuration, indicatorStyle: .fill, gradient: nil)
        } else {
            CircularPercentageGauge(configuration: configuration)
        }
    }
}

@available(*, unavailable)
extension AccessoryCircularCapacityGaugeStyle: Sendable {}

// MARK: - GaugeStyle + AccessoryCircularCapacityGaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension GaugeStyle where Self == AccessoryCircularCapacityGaugeStyle {
    /// A gauge style that displays a closed ring that's partially filled in to
    /// indicate the gauge's current value.
    ///
    /// Apply this style to a ``Gauge`` or to a view hierarchy that contains
    /// gauges using the ``View/gaugeStyle(_:)`` modifier:
    ///
    ///     Gauge(value: batteryLevel, in: 0...100) {
    ///         Text("Battery Level")
    ///     }
    ///     .gaugeStyle(.accessoryCircularCapacity)
    ///
    /// This style displays the gauge's `currentValueLabel` value at the center
    /// of the gauge.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var accessoryCircularCapacity: AccessoryCircularCapacityGaugeStyle {
        .init()
    }

    @_spi(Private)
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func accessoryCircularCapacity(halfOpen: Bool) -> AccessoryCircularCapacityGaugeStyle {
        .init(halfOpen: halfOpen)
    }
}

// MARK: - CircularPercentageGaugeStyle

@_spi(Private)
@available(iOS, deprecated, renamed: "AccessoryCircularCapacityGaugeStyle")
@available(macOS, deprecated, renamed: "AccessoryCircularCapacityGaugeStyle")
@available(tvOS, unavailable)
@available(watchOS, deprecated, renamed: "AccessoryCircularCapacityGaugeStyle")
@MainActor
@preconcurrency
public struct CircularPercentageGaugeStyle: GaugeStyle {
    var halfOpen: Bool

    public init(halfOpen: Bool = false) {
        self.halfOpen = halfOpen
    }

    public func makeBody(configuration: Configuration) -> some View {
        if halfOpen {
            HalfOpenCircularGauge(configuration: configuration, indicatorStyle: .fill, gradient: nil)
        } else {
            CircularPercentageGauge(configuration: configuration)
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension CircularPercentageGaugeStyle: Sendable {}

// MARK: - GaugeStyle + CircularPercentageGaugeStyle

@_spi(Private)
@available(iOS, deprecated)
@available(macOS, deprecated)
@available(tvOS, unavailable)
@available(watchOS, deprecated)
extension GaugeStyle where Self == CircularPercentageGaugeStyle {
    @available(iOS, deprecated, renamed: "accessoryCircularCapacity")
    @available(macOS, deprecated, renamed: "accessoryCircularCapacity")
    @available(tvOS, unavailable)
    @available(watchOS, deprecated, renamed: "accessoryCircularCapacity")
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var circularPercentage: CircularPercentageGaugeStyle {
        .init()
    }

    @available(iOS, deprecated, renamed: "accessoryCircularCapacity(halfOpen:)")
    @available(macOS, deprecated, renamed: "accessoryCircularCapacity(halfOpen:)")
    @available(tvOS, unavailable)
    @available(watchOS, deprecated, renamed: "accessoryCircularCapacity(halfOpen:)")
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static func circularPercentage(halfOpen: Bool = false) -> CircularPercentageGaugeStyle {
        .init(halfOpen: halfOpen)
    }
}

// MARK: - CircularProgressGaugeStyle

@_spi(Private)
@available(iOS, deprecated, renamed: "AccessoryCircularCapacityGaugeStyle")
@available(macOS, deprecated, renamed: "AccessoryCircularCapacityGaugeStyle")
@available(tvOS, unavailable)
@available(watchOS, deprecated, renamed: "AccessoryCircularCapacityGaugeStyle")
@MainActor
@preconcurrency
public struct CircularProgressGaugeStyle: GaugeStyle {
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        CircularPercentageGauge(configuration: configuration)
    }
}

@_spi(Private)
@available(*, unavailable)
extension CircularProgressGaugeStyle: Sendable {}

// MARK: - GaugeStyle + CircularProgressGaugeStyle

@_spi(Private)
@available(iOS, deprecated)
@available(macOS, deprecated)
@available(tvOS, unavailable)
@available(watchOS, deprecated)
extension GaugeStyle where Self == CircularProgressGaugeStyle {
    @available(*, deprecated, renamed: "accessoryCircularCapacity")
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var circularProgress: CircularProgressGaugeStyle {
        .init()
    }
}

// MARK: - CircularPercentageGauge

struct CircularPercentageGauge: View {
    let configuration: GaugeStyleConfiguration

    var body: some View {
        StaticIf(idiom: .complication) {
            SizedCircularPercentageGauge(configuration: configuration, isComplication: true)
        } else: {
            SizedCircularPercentageGauge(configuration: configuration, isComplication: false)
        }
    }
}

// MARK: - SizedCircularPercentageGauge

struct SizedCircularPercentageGauge: View {
    var size: CGFloat = 58
    var centerFont: CGFloat = 30
    @Environment(\.tint) private var controlTint
    var configuration: GaugeStyleConfiguration
    @Environment(\.allowsGaugeResizing) private var allowsResizing
    let isComplication: Bool
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.sensitiveContent) private var sensitive
    let metrics = Metrics()

    struct Metrics {}

    init(configuration: GaugeStyleConfiguration, isComplication: Bool) {
        self.configuration = configuration
        self.isComplication = isComplication
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CircularPercentageGaugeRing(
                    fractionCompleted: redactionReasons.contains(.privacy) && sensitive ? 0 : configuration.value,
                    tint: controlTint ?? AnyShapeStyle(Color.primary)
                )
                .foregroundLayer()
                VStack {
                    if configuration.currentValueLabel != nil {
                        HStack { configuration.currentValueLabel }
                    } else {
                        HStack { configuration.label }
                    }
                }
                .frame(maxWidth: proxy.size.width * 0.7)
                .font(.system(size: proxy.size.height / size * centerFont, weight: .medium))
                .frame(height: min(proxy.size.width, proxy.size.height) * 0.5)
                .labelStyle(.iconOnly)
            }
        }
        .frame(
            width: allowsResizing || isComplication ? nil : size,
            height: allowsResizing || isComplication ? nil : size
        )
        .aspectRatio(1, contentMode: .fit)
        .minimumScaleFactor(0.01)
    }
}

// MARK: - CircularPercentageGaugeRing

struct CircularPercentageGaugeRing: TimelineProgressViewBase {
    var fractionCompleted: Double
    var tint: AnyShapeStyle
    @Environment(\.gaugeTintOverride) private var gaugeTintOverride
    @Environment(\.layoutDirection) private var direction

    init(fractionCompleted: Double, tint: Color?) {
        self.init(fractionCompleted: fractionCompleted, tint: AnyShapeStyle(tint ?? .primary))
    }

    init(fractionCompleted: Double, tint: AnyShapeStyle) {
        self.fractionCompleted = fractionCompleted
        self.tint = tint
    }

    private var resolvedTint: AnyShapeStyle {
        if let gradient = tint.as(type: Gradient.self) {
            AnyShapeStyle(
                AngularGradient(
                    gradient: direction == .leftToRight ? gradient : gradient.reversed,
                    center: .center,
                    startAngle: .radians(3 * .pi / 2),
                    endAngle: .radians(-.pi / 2)
                )
            )
        } else if let gradient = tint.as(type: AnyGradient.self) {
            AnyShapeStyle(
                .angularGradient(
                    gradient,
                    center: .center,
                    startAngle: .radians(3 * .pi / 2),
                    endAngle: .radians(-.pi / 2)
                )
            )
        } else {
            tint
        }
    }

    private var resolvedStartCapColor: AnyShapeStyle {
        if let gaugeTintOverride {
            AnyShapeStyle(gaugeTintOverride.0)
        } else if let gradient = tint.as(type: Gradient.self) {
            AnyShapeStyle(gradient.color(at: 1))
        } else if let gradient = tint.as(type: AnyGradient.self) {
            AnyShapeStyle(gradient.color(at: 1))
        } else {
            tint
        }
    }

    private var resolvedEndCapColor: AnyShapeStyle {
        if let gaugeTintOverride {
            AnyShapeStyle(gaugeTintOverride.0)
        } else if let gradient = tint.as(type: Gradient.self) {
            AnyShapeStyle(gradient.color(at: 1 - fractionCompleted))
        } else if let gradient = tint.as(type: AnyGradient.self) {
            AnyShapeStyle(gradient.color(at: 1 - fractionCompleted))
        } else {
            tint
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let lineWidth = min(proxy.size.width, proxy.size.height) / 10.5
            let foreground = gaugeTintOverride.map { AnyShapeStyle($0.0) } ?? resolvedTint
            let background = gaugeTintOverride.map { AnyShapeStyle($0.1) }
                ?? AnyShapeStyle(resolvedTint.opacity(0.35))
            ZStack {
                Circle().strokeBorder(background, lineWidth: lineWidth)
                if fractionCompleted > 0 {
                    RingArc(fractionCompleted: fractionCompleted, lineWidth: lineWidth, firstHalf: true)
                        .fill(foreground)
                    StartCap(tint: resolvedStartCapColor, lineWidth: lineWidth)
                    if fractionCompleted > 0.5 {
                        RingArc(fractionCompleted: fractionCompleted, lineWidth: lineWidth, firstHalf: false)
                            .fill(foreground)
                    }
                    EndCap(lineWidth: lineWidth, fractionCompleted: fractionCompleted, tint: resolvedEndCapColor)
                }
            }
        }
    }

    struct RingArc: Shape {
        var fractionCompleted: Double
        var lineWidth: CGFloat
        var firstHalf: Bool

        nonisolated func path(in rect: CGRect) -> Path {
            let endAngle = max(fractionCompleted, 0.0001) * .pi * 2 - .pi / 2
            var path = Path()
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: (min(rect.width, rect.height) - lineWidth) * 0.5,
                startAngle: .radians(firstHalf ? -.pi / 2 : .pi / 2),
                endAngle: .radians(firstHalf ? min(endAngle, .pi / 2) : max(endAngle, .pi / 2)),
                clockwise: false
            )
            return path.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }

        var animatableData: AnimatablePair<Double, CGFloat> {
            get { .init(fractionCompleted, lineWidth) }
            set {
                fractionCompleted = newValue.first
                lineWidth = newValue.second
            }
        }
    }

    struct StartCap: View {
        var tint: AnyShapeStyle
        var lineWidth: CGFloat

        var body: some View {
            GeometryReader(content: content)
        }

        func content(proxy: GeometryProxy) -> some View {
            let center = CGPoint(x: proxy.size.width * 0.5, y: proxy.size.height * 0.5)
            let radius = min(center.x, center.y)
            return CapShape(lineWidth: lineWidth, isStart: true)
                .fill(tint)
                .offset(x: center.x - lineWidth * 0.5, y: center.y - radius)
                .layoutDirectionBehavior(.mirrors)
        }
    }

    struct EndCap: View {
        var lineWidth: CGFloat
        var fractionCompleted: Double
        var tint: AnyShapeStyle

        var body: some View {
            GeometryReader(content: content)
        }

        func content(proxy: GeometryProxy) -> some View {
            let center = CGPoint(x: proxy.size.width * 0.5, y: proxy.size.height * 0.5)
            let radius = min(center.x, center.y)
            return CapShape(lineWidth: lineWidth, isStart: false)
                .fill(tint)
                .shadow(color: .black, radius: radius * 0.03)
                .offset(x: center.x - lineWidth * 0.5, y: center.y - radius)
                .clipShape(
                    CapClip(rect: CGRect(
                        x: center.x - 1,
                        y: center.y - radius,
                        width: lineWidth,
                        height: lineWidth
                    )),
                    style: FillStyle(antialiased: false)
                )
                .rotationEffect(.radians(fractionCompleted * .pi * 2))
                .layoutDirectionBehavior(.mirrors)
        }
    }

    private struct CapClip: Shape {
        var rect: CGRect

        nonisolated func path(in bounds: CGRect) -> Path {
            Path(rect.offsetBy(dx: bounds.origin.x, dy: bounds.origin.y))
        }

        nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior { .fixed }

        var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
            get {
                .init(.init(rect.origin.x, rect.origin.y), .init(rect.size.width, rect.size.height))
            }
            set {
                rect = CGRect(
                    x: newValue.first.first,
                    y: newValue.first.second,
                    width: newValue.second.first,
                    height: newValue.second.second
                )
            }
        }
    }

    private struct CapShape: Shape {
        var lineWidth: CGFloat
        var isStart: Bool

        nonisolated func path(in rect: CGRect) -> Path {
            let capRect = CGRect(
                origin: rect.origin,
                size: CGSize(width: lineWidth, height: lineWidth)
            )
            let circle = Circle().path(in: capRect)
            guard isStart else { return circle }
            return circle.trimmedPath(from: 0, to: 0.6).applying(
                CGAffineTransform(translationX: capRect.midX, y: capRect.midY)
                    .rotated(by: .pi / 2)
                    .translatedBy(x: -capRect.midX, y: -capRect.midY)
            )
        }

        nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior { .fixed }

        var animatableData: CGFloat {
            get { lineWidth }
            set { lineWidth = newValue }
        }
    }
}
