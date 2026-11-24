//
//  GaugeTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@MainActor
struct GaugeTests {
    @Test(arguments: [
        (10.0, 0.0),
        (15.0, 0.25),
        (30.0, 1.0),
    ] as [(Double, Double)])
    func normalizedValue(value: Double, expected: Double) {
        let gauge = Gauge(value: value, in: 10...30) { EmptyView() }
        #expect(gauge.value == expected)
    }

    @Test(
        containsRuntimeIssue("Gauge initialized with an out-of-bounds progress amount. The amount will be clamped to the nearest bound."),
        arguments: [
            (5.0, 10.0...30.0, 0.0),
            (35.0, 10.0...30.0, 1.0),
            (Double.nan, 10.0...30.0, 0.0),
            (-Double.infinity, 10.0...30.0, 0.0),
            (Double.infinity, 10.0...30.0, 1.0),
            (4.0, 5.0...5.0, 1.0),
            (6.0, 5.0...5.0, 1.0),
            (Double.nan, 5.0...5.0, 1.0),
        ] as [(Double, ClosedRange<Double>, Double)]
    )
    func outOfBoundsValue(value: Double, bounds: ClosedRange<Double>, expected: Double) {
        let gauge = Gauge(value: value, in: bounds) { EmptyView() }
        #expect(gauge.value == expected)
    }

    @Test
    func zeroLengthRange() {
        let gauge = Gauge(value: 5.0, in: 5...5) { EmptyView() }
        #expect(gauge.value == 1.0)
    }

    @Test
    func normalizationPreservesInputPrecision() {
        let gauge = Gauge(value: Float(1), in: 0...3) { EmptyView() }
        #expect(gauge.value == 0.3333333432674408)
    }

    @Test
    func omittedLabels() {
        let gauge = Gauge(value: 0.5) { Text(verbatim: "Gauge") }
        #expect(gauge.label == Text(verbatim: "Gauge"))
        #expect(gauge.currentValueLabel == nil)
        #expect(gauge.minimumValueLabel == nil)
        #expect(gauge.maximumValueLabel == nil)
        #expect(gauge.markedValueLabels == nil)
    }

    @Test
    func currentValueLabel() {
        let gauge = Gauge(value: 0.5) {
            Text(verbatim: "Gauge")
        } currentValueLabel: {
            Text(verbatim: "Current")
        }
        #expect(gauge.currentValueLabel == Text(verbatim: "Current"))
        #expect(gauge.minimumValueLabel == nil)
        #expect(gauge.maximumValueLabel == nil)
        #expect(gauge.markedValueLabels == nil)
    }

    @Test
    func boundsLabels() {
        let gauge = Gauge(value: 0.5) {
            Text(verbatim: "Gauge")
        } currentValueLabel: {
            Text(verbatim: "Current")
        } minimumValueLabel: {
            Text(verbatim: "Minimum")
        } maximumValueLabel: {
            Text(verbatim: "Maximum")
        }
        #expect(gauge.minimumValueLabel == Text(verbatim: "Minimum"))
        #expect(gauge.maximumValueLabel == Text(verbatim: "Maximum"))
        #expect(gauge.markedValueLabels == nil)
    }

    @Test
    func markedValueLabels() {
        let gauge = Gauge(value: 0.5) {
            Text(verbatim: "Gauge")
        } currentValueLabel: {
            Text(verbatim: "Current")
        } markedValueLabels: {
            Text(verbatim: "Marked")
        }
        #expect(gauge.minimumValueLabel == nil)
        #expect(gauge.maximumValueLabel == nil)
        #expect(gauge.markedValueLabels == Text(verbatim: "Marked"))
    }

    @Test
    func labelBuildersRunOnceInOrder() {
        var calls: [String] = []
        func label(_ name: String) -> Text {
            calls.append(name)
            return Text(verbatim: name)
        }
        let gauge = Gauge(value: 0.5) {
            label("label")
        } currentValueLabel: {
            label("current")
        } minimumValueLabel: {
            label("minimum")
        } maximumValueLabel: {
            label("maximum")
        } markedValueLabels: {
            label("marked")
        }
        #expect(calls == ["label", "current", "minimum", "maximum", "marked"])
        #expect(gauge.label == Text(verbatim: "label"))
        #expect(gauge.currentValueLabel == Text(verbatim: "current"))
        #expect(gauge.minimumValueLabel == Text(verbatim: "minimum"))
        #expect(gauge.maximumValueLabel == Text(verbatim: "maximum"))
        #expect(gauge.markedValueLabels == Text(verbatim: "marked"))
    }
}
