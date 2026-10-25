//
//  SliderTests.swift
//  OpenSwiftUITests

@_spi(Private) @testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

struct SliderTests {
    @Test(arguments: [
        (200.0 ... 300.0, 28.0, 1.0 / 3.0, 4),
        (0.0 ... 1.0, 0.3, 1.0 / 3.0, 4),
        (0.0 ... 10.0, 0.7, 1.0 / 14.0, 15),
    ] as [(ClosedRange<Double>, Double, Double, Int)])
    func discreteValueCount(
        bounds: ClosedRange<Double>,
        step: Double,
        expectedSkipDistance: Double,
        expectedCount: Int
    ) {
        let slider = Slider(value: .constant(bounds.lowerBound), in: bounds, step: step)
        #expect(abs(slider.skipDistance - expectedSkipDistance) <= 0.001)
        #expect(slider.discreteValueCount == expectedCount)
    }

    @Test
    func continuousSlider() {
        let slider = Slider(value: .constant(0.5))
        #expect(slider.skipDistance == 0.1)
        #expect(slider.discreteValueCount == 0)
        #expect(slider.marks == nil)
    }

    @Test(containsRuntimeIssue("Multiple marks specified for value %f"))
    func marksAreNormalizedSortedAndUnique() {
        let slider = Slider<EmptyView, EmptyView>(
            value: .constant(1.0),
            in: 0.0 ... 2.0,
            step: nil,
            onEditingChanged: { _ in },
            minimumValueLabel: EmptyView(),
            maximumValueLabel: EmptyView(),
            customMinMaxValueLabels: false,
            label: EmptyView(),
            marks: [
                SliderMark(1.5),
                SliderMark(0.5),
                SliderMark(0.5),
                SliderMark(1.0),
            ]
        )
        #expect(slider.marks?.map(\.value) == [0.25, 0.5, 0.75])
    }
}
