//
//  HalfOpenCircularGauge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8F8C08602DC145DEB3F5E691AFD90652 (SwiftUI)

import Foundation
import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - HalfOpenCircularGauge

struct HalfOpenCircularGauge: View {
    let configuration: GaugeStyleConfiguration
    let indicatorStyle: IndicatorStyle
    let gradient: Gradient?

    enum IndicatorStyle: Hashable {
        case dot
        case fill
    }

    var body: some View {
        StaticIf(idiom: .complication) {
            SizedHalfOpenCircularGauge(
                configuration: configuration,
                isComplication: true,
                indicatorStyle: indicatorStyle,
                gradient: gradient
            )
        } else: {
            SizedHalfOpenCircularGauge(
                configuration: configuration,
                isComplication: false,
                indicatorStyle: indicatorStyle,
                gradient: gradient
            )
        }
    }
}

// MARK: - SizedHalfOpenCircularGauge

struct SizedHalfOpenCircularGauge: View {
    let configuration: GaugeStyleConfiguration
    let indicatorStyle: HalfOpenCircularGauge.IndicatorStyle
    let gradient: Gradient?

    @Environment(\.tint) private var controlTint
    @Environment(\.gaugeTintOverride) private var gaugeTintOverride
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.allowsGaugeResizing) private var allowsResizing
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.sensitiveContent) private var sensitive

    let isComplication: Bool
    var size: CGFloat = 58
    var centerFontSize: CGFloat = 24
    var bottomFontSize: CGFloat = 11
    let bottomContentWidthRatio: CGFloat = 0.62
    let metrics = Metrics()

    struct Metrics {}

    init(
        configuration: GaugeStyleConfiguration,
        isComplication: Bool,
        indicatorStyle: HalfOpenCircularGauge.IndicatorStyle,
        gradient: Gradient?
    ) {
        self.configuration = configuration
        self.isComplication = isComplication
        self.indicatorStyle = indicatorStyle
        self.gradient = gradient
    }

    private var effectiveTint: AnyShapeStyle {
        if let gradient {
            AnyShapeStyle(gradient)
        } else {
            controlTint ?? AnyShapeStyle(Color.primary)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                centerContent(proxy: proxy)
                    .baselineOffset(2 * proxy.size.height / size)
                    .frame(maxWidth: 0.7 * proxy.size.width)
                VStack {
                    Spacer()
                    bottomContent(proxy: proxy)
                        .frame(
                            maxWidth: bottomContentWidthRatio * proxy.size.width,
                            maxHeight: 0.3 * proxy.size.height
                        )
                        .baselineOffset(2.5 * proxy.size.height / size)
                        .allowsTightening(true)
                }
                RingOverlay(
                    gapAngle: configuration.minimumValueLabel == nil || configuration.maximumValueLabel == nil
                        ? .pi / 2 : 2 * .pi / 3,
                    progress: redactionReasons.contains(.privacy) && sensitive ? 0 : configuration.value,
                    primaryTint: gaugeTintOverride.map { AnyShapeStyle($0.0) } ?? effectiveTint,
                    secondaryTint: gaugeTintOverride.map { AnyShapeStyle($0.1) },
                    indicatorStyle: indicatorStyle
                )
            }
        }
        .frame(
            width: allowsResizing || isComplication ? nil : size,
            height: allowsResizing || isComplication ? nil : size
        )
        .aspectRatio(1, contentMode: .fit)
        .minimumScaleFactor(0.01)
        .accessibilityRepresentation {
            HStack {
                configuration.label
                configuration.currentValueLabel
            }
        }
    }

    @ViewBuilder
    func centerContent(proxy: GeometryProxy) -> some View {
        if let currentValueLabel = configuration.currentValueLabel {
            currentValueLabel
                .font(.system(size: proxy.size.height / size * centerFontSize, weight: .medium).leading(.tight))
                .foregroundLayer()
                .defaultForegroundColor(gaugeTintOverride?.0)
                .lineLimit(1)
                .labelStyle(.iconOnly)
        }
    }

    func bottomContent(proxy: GeometryProxy) -> some View {
        HStack {
            if configuration.minimumValueLabel != nil {
                configuration.minimumValueLabel
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 1.5 * proxy.size.height / size)
                configuration.maximumValueLabel
                    .multilineTextAlignment(.trailing)
            } else {
                configuration.label
            }
        }
        .font(.system(size: proxy.size.height / size * bottomFontSize, weight: .medium).leading(.tight))
        .minimumScaleFactor(1)
        .foregroundLayer()
        .defaultForegroundColor(gaugeTintOverride?.0)
        .lineLimit(1)
        .labelStyle(.iconOnly)
    }
}

// MARK: - RingOverlay

private struct RingOverlay: View {
    let gapAngle: Double
    let progress: Double
    let primaryTint: AnyShapeStyle
    let secondaryTint: AnyShapeStyle?
    let indicatorStyle: HalfOpenCircularGauge.IndicatorStyle

    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.sensitiveContent) private var sensitive
    @Environment(\.layoutDirection) private var direction
    @Environment(\.gaugeIndicatorDotTint) private var indicatorDotTint

    init(
        gapAngle: Double,
        progress: Double,
        primaryTint: AnyShapeStyle,
        secondaryTint: AnyShapeStyle?,
        indicatorStyle: HalfOpenCircularGauge.IndicatorStyle
    ) {
        self.gapAngle = gapAngle
        self.progress = progress
        self.primaryTint = primaryTint
        self.secondaryTint = secondaryTint
        self.indicatorStyle = indicatorStyle
    }

    private var isRedacted: Bool {
        redactionReasons.contains(.privacy) && sensitive
    }

    var body: some View {
        GeometryReader { proxy in
            content(proxy)
        }
    }

    func content(_ proxy: GeometryProxy) -> some View {
        let dimension = min(proxy.size.width, proxy.size.height)
        let lineWidth = dimension / 10.5
        let dotDiameter = lineWidth + 2 * (dimension / 25)
        let radius = (dimension - lineWidth) / 2
        let startAngle = gapAngle / 2 + .pi / 2
        let endAngle = startAngle + 2 * .pi - gapAngle
        let valueAngle = startAngle + progress * (endAngle - startAngle)
        let foregroundEndAngle = indicatorStyle == .fill ? valueAngle : endAngle
        let primary = resolveTint(primaryTint, startAngle: startAngle, endAngle: endAngle)
        let secondary = secondaryTint.map {
            resolveTint($0, startAngle: startAngle, endAngle: endAngle)
        } ?? (indicatorStyle == .fill ? AnyShapeStyle(primary.opacity(0.35)) : primary)
        let dotTint = indicatorDotTint ?? primary
        return ZStack {
            if indicatorStyle == .fill {
                OpenRing(
                    lineWidth: lineWidth,
                    radius: radius,
                    startAngle: .radians(startAngle),
                    endAngle: .radians(endAngle)
                )
                .fill(secondary)
            }
            OpenRing(
                lineWidth: lineWidth,
                radius: radius,
                startAngle: .radians(startAngle),
                endAngle: .radians(foregroundEndAngle)
            )
            .fill(primary.opacity(indicatorStyle == .fill ? (progress > 0 ? 1 : 0) : (isRedacted ? 0.3 : 1)))
            .overlay {
                if indicatorStyle == .dot {
                    Circle()
                        .fill(Color.black.opacity(isRedacted ? 0 : 1))
                        .frame(width: dotDiameter, height: dotDiameter)
                        .modifier(RotationOffsetEffect(
                            angle: .radians(valueAngle),
                            offset: CGPoint(x: radius, y: 0)
                        ))
                        .blendMode(.destinationOut)
                }
            }
            .compositingGroup()
            if indicatorStyle == .dot {
                OpenRing(
                    lineWidth: lineWidth,
                    radius: radius,
                    startAngle: .radians(valueAngle),
                    endAngle: .radians(valueAngle)
                )
                .fill(dotTint.opacity(isRedacted ? 0 : 1))
                .foregroundLayer()
            }
        }
        .compositingGroup()
    }

    private func resolveTint(_ tint: AnyShapeStyle, startAngle: Double, endAngle: Double) -> AnyShapeStyle {
        if let gradient = tint.as(type: Gradient.self) {
            AnyShapeStyle(
                AngularGradient(
                    gradient: direction == .leftToRight ? gradient : gradient.reversed,
                    center: .center,
                    startAngle: .radians(startAngle),
                    endAngle: .radians(endAngle)
                )
            )
        } else {
            tint
        }
    }
}

// MARK: - RotationOffsetEffect

private struct RotationOffsetEffect: GeometryEffect {
    var angle: Angle
    var offset: CGPoint

    var animatableData: AnimatablePair<Double, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(angle.animatableData, offset.animatableData) }
        set {
            angle.animatableData = newValue.first
            offset.animatableData = newValue.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let center = UnitPoint.center.in(size)
        let transform = CGAffineTransform(translationX: offset.x, y: offset.y)
            .concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
            .concatenating(CGAffineTransform(rotation: angle))
            .concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        return ProjectionTransform(transform)
    }
}

// MARK: - OpenRing

private struct OpenRing: Shape {
    var lineWidth: CGFloat
    var radius: CGFloat
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if startAngle == endAngle {
            path.addArc(
                center: CGPoint(
                    x: rect.midX + radius * cos(startAngle.radians),
                    y: rect.midY + radius * sin(startAngle.radians)
                ),
                radius: lineWidth / 2,
                startAngle: .zero,
                endAngle: .radians(2 * .pi),
                clockwise: false
            )
            return path
        } else {
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            return path.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }
}
