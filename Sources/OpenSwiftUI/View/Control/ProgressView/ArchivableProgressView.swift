//
//  ArchivableProgressView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
import OpenSwiftUICore

// MARK: - ArchivableCircularPlaybackProgressView

struct ArchivableCircularPlaybackProgressView: View {
    var configuration: ProgressViewStyleConfiguration
    var tint: Color

    var body: some View {
        ResolvedCircularPlaybackProgressView(
            configuration: configuration,
            tint: tint
        )
    }
}

// MARK: - ArchivableCircularProgressView

struct ArchivableCircularProgressView: View {
    var size: CGFloat
    var centerFont: CGFloat
    var configuration: ProgressViewStyleConfiguration
    var tint: Color?
    struct Metrics {}
    let metrics: Metrics

    @ViewBuilder
    var gaugeRing: some View {
        switch configuration.value {
        case let .absolute(fractionCompleted, _):
            CircularPercentageGaugeRing(
                fractionCompleted: fractionCompleted ?? 0,
                tint: tint
            )
        case let .dateRelative(interval, countdown):
            TimelineProgressView<CircularPercentageGaugeRing>(
                interval: interval,
                updateStyle: .default,
                countdown: countdown,
                tint: tint,
                isCircular: true,
                extendedState: .init()
            )
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                gaugeRing
                VStack {
                    if configuration.currentValueLabel != nil {
                        HStack {
                            configuration.currentValueLabel
                        }
                    } else {
                        HStack {
                            configuration.label
                        }
                    }
                }
                .font(
                    .system(
                        size: centerFont * proxy.size.height / size,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .frame(height: min(proxy.size.width, proxy.size.height) * 0.5)
                .labelStyle(.iconOnly)
                .foregroundLayer()
                .multilineTextAlignment(.center)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .minimumScaleFactor(0.01)
    }
}

// MARK: - ArchivableLinearProgressView

struct ArchivableLinearProgressView: View {
    var configuration: ProgressViewStyleConfiguration
    var tint: Color?

    @ViewBuilder
    var body: some View {
        switch configuration.value {
        case let .absolute(fractionCompleted, _):
            Base(
                fractionCompleted: fractionCompleted ?? 0,
                tint: tint
            )
        case let .dateRelative(interval, countdown):
            TimelineProgressView<Base>(
                interval: interval,
                updateStyle: .default,
                countdown: countdown,
                tint: tint,
                isCircular: false,
                extendedState: .init()
            )
        }
    }

    struct Base: TimelineProgressViewBase {
        var fractionCompleted: Double
        var tint: Color?

        var body: some View {
            LinearCapsuleGauge(value: fractionCompleted)
            // TODO
        }
    }
}

// MARK: - ResolvedCircularPlaybackProgressView

struct ResolvedCircularPlaybackProgressView: View {
    var configuration: ProgressViewStyleConfiguration
    var tint: Color

    var body: some View {
        switch configuration.value {
        case let .absolute(fractionCompleted, _):
            Base(
                fractionCompleted: fractionCompleted ?? 0,
                tint: tint
            )
        case let .dateRelative(interval, _):
            TimelineProgressView<Base>(
                interval: interval,
                updateStyle: .default,
                countdown: false,
                tint: tint,
                isCircular: true,
                extendedState: .init()
            )
        }
    }

    struct Base: TimelineProgressViewBase {
        var fractionCompleted: Double
        var tint: Color

        init(fractionCompleted: Double, tint: Color?) {
            self.fractionCompleted = fractionCompleted
            self.tint = tint ?? .accentColor
        }

        var body: some View {
            Circle()
                .inset(by: 2.0)
                .trim(from: 0, to: fractionCompleted)
                .stroke(tint, lineWidth: 4.0)
                .rotationEffect(.degrees(-90.0))
        }
    }
}

// MARK: - CircularPercentageGaugeRing [TODO]

struct CircularPercentageGaugeRing: TimelineProgressViewBase {
    var fractionCompleted: Double
    var tint: AnyShapeStyle

    init(fractionCompleted: Double, tint: Color?) {
        self.fractionCompleted = fractionCompleted
        self.tint = AnyShapeStyle(tint ?? .primary)
    }

    var body: some View {
        EmptyView()
    }
}

// MARK: - LinearCapsuleGauge [TODO]

struct LinearCapsuleGauge: View {
    var value: Double
    // @ScaledMetric var height: CGFloat
    // @Environment(\.) var gaugeTintOverride: (Color, Color)?
    // @Environment(\.) var controlTint: AnyShapeStyle?
    // @Environment(\.) var direction: LayoutDirection?

    var body: some View {
        EmptyView()
    }
}

extension View {
    func labelStyle(_ style: LabelStyle) -> some View {
        self
    }
}

protocol LabelStyle {}

struct IconOnlyLabelStyle: LabelStyle {}

extension LabelStyle where Self == IconOnlyLabelStyle {
    static var iconOnly: IconOnlyLabelStyle { .init() }
}
