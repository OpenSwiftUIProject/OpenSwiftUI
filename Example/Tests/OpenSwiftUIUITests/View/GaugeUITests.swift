//
//  GaugeUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct GaugeUITests {
    @Test
    func defaultStyle() {
        openSwiftUIAssertSnapshot(
            of: GaugeSample(value: 75).padding(20),
            size: .init(width: 320, height: 120)
        )
    }

    @Test(arguments: GaugeStyleCase.allCases)
    func boundedValues(style: GaugeStyleCase) {
        openSwiftUIAssertSnapshot(
            of: GaugeValues(style: style).tint(.blue),
            size: .init(width: 320, height: 500),
            named: style.rawValue
        )
    }

    @Test(arguments: GaugeStyleCase.allCases)
    func labelVariants(style: GaugeStyleCase) {
        openSwiftUIAssertSnapshot(
            of: VStack(spacing: 20) {
                Gauge(value: 75, in: 0...100) {
                    Text("Level")
                }
                Gauge(value: 75, in: 0...100) {
                    Text("Level")
                } currentValueLabel: {
                    Text("75")
                }
                GaugeSample(value: 75)
            }
            .gaugeStyleCase(style)
            .padding(20),
            size: .init(width: 320, height: 320),
            named: style.rawValue
        )
    }

    @Test(
        arguments: GaugeStyleCase.allCases,
        [LayoutDirection.leftToRight, .rightToLeft]
    )
    func gradientTints(style: GaugeStyleCase, direction: LayoutDirection) {
        openSwiftUIAssertSnapshot(
            of: GaugeValues(style: style)
                .tint(Gradient(stops: [
                    .init(color: .red, location: 0),
                    .init(color: .yellow, location: 0.25),
                    .init(color: .blue, location: 1),
                ]))
                .environment(\.layoutDirection, direction),
            size: .init(width: 320, height: 500),
            named: "\(style.rawValue)-\(direction == .leftToRight ? "ltr" : "rtl")"
        )
    }

    @Test(arguments: [LayoutDirection.leftToRight, .rightToLeft])
    func erasedCircularGradient(direction: LayoutDirection) {
        openSwiftUIAssertSnapshot(
            of: GaugeValues(style: .accessoryCircularCapacity)
                .tint(AnyGradient(Gradient(colors: [.red, .yellow, .blue])))
                .environment(\.layoutDirection, direction),
            size: .init(width: 320, height: 500),
            named: direction == .leftToRight ? "ltr" : "rtl"
        )
    }

    @Test(arguments: GaugeStyleCase.allCases)
    func privacyRedaction(style: GaugeStyleCase) {
        openSwiftUIAssertSnapshot(
            of: VStack(spacing: 20) {
                GaugeSample(value: 75)
                    .privacySensitive(false)
                GaugeSample(value: 75)
                    .privacySensitive()
            }
            .gaugeStyleCase(style)
            .redacted(reason: .privacy)
            .tint(.purple)
            .padding(20),
            size: .init(width: 320, height: 220),
            named: style.rawValue
        )
    }

    @Test(arguments: [.mini, .small, .regular, .large, .extraLarge] as [ControlSize])
    func linearCapacityControlSizes(size: ControlSize) {
        openSwiftUIAssertSnapshot(
            of: GaugeSample(value: 75)
                .gaugeStyle(.linearCapacity)
                .controlSize(size)
                .tint(.green)
                .padding(20),
            size: .init(width: 320, height: 120),
            named: "\(size)"
        )
    }

    @Test
    func customStyleConfiguration() {
        openSwiftUIAssertSnapshot(
            of: VStack(spacing: 16) {
                GaugeSample(value: 5, bounds: 10...30)
                GaugeSample(value: 20, bounds: 10...30)
                GaugeSample(value: 35, bounds: 10...30)
            }
            .gaugeStyle(ConfigurationGaugeStyle())
            .padding(20),
            size: .init(width: 320, height: 360)
        )
    }
}

// MARK: - Content

private struct GaugeValues: View {
    var style: GaugeStyleCase

    var body: some View {
        VStack(spacing: 20) {
            ForEach([0.0, 25.0, 50.0, 75.0, 100.0], id: \.self) { value in
                GaugeSample(value: value)
            }
        }
        .gaugeStyleCase(style)
        .padding(20)
    }
}

private struct GaugeSample: View {
    var value: Double
    var bounds: ClosedRange<Double> = 0...100

    var body: some View {
        Gauge(value: value, in: bounds) {
            Text("Level")
        } currentValueLabel: {
            Text(verbatim: "\(Int(value))")
        } minimumValueLabel: {
            Text(verbatim: "\(Int(bounds.lowerBound))")
        } maximumValueLabel: {
            Text(verbatim: "\(Int(bounds.upperBound))")
        }
    }
}

private struct ConfigurationGaugeStyle: GaugeStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
            HStack {
                configuration.minimumValueLabel
                Spacer()
                configuration.currentValueLabel
                Spacer()
                configuration.maximumValueLabel
            }
            Text(verbatim: "Normalized: \(Int(configuration.value * 100))%")
        }
        .padding(8)
    }
}

// MARK: - Styles

enum GaugeStyleCase: String, CaseIterable {
    case automatic
    case linearCapacity
    case accessoryLinear
    case accessoryLinearCapacity
    case accessoryCircular
    case accessoryCircularCapacity
}

extension View {
    @ViewBuilder
    fileprivate func gaugeStyleCase(_ style: GaugeStyleCase) -> some View {
        switch style {
        case .automatic: gaugeStyle(.automatic)
        case .linearCapacity: gaugeStyle(.linearCapacity)
        case .accessoryLinear: gaugeStyle(.accessoryLinear)
        case .accessoryLinearCapacity: gaugeStyle(.accessoryLinearCapacity)
        case .accessoryCircular: gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity: gaugeStyle(.accessoryCircularCapacity)
        }
    }
}
