//
//  SliderUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct SliderUITests {
    @Test(arguments: [0.0, 50.0, 100.0])
    func continuousValues(speed: Double) {
        openSwiftUIAssertSnapshot(
            of: SliderExample(speed: speed),
            size: .init(width: 320, height: 160),
            named: "\(Int(speed))"
        )
    }

    @Test
    func stepAndValueLabels() {
        openSwiftUIAssertSnapshot(
            of: SteppedSliderExample(),
            size: .init(width: 320, height: 160)
        )
    }

    @Test(arguments: [false, true])
    func tintedAndDisabled(isDisabled: Bool) {
        openSwiftUIAssertSnapshot(
            of: SteppedSliderExample()
                .tint(.purple)
                .disabled(isDisabled),
            size: .init(width: 320, height: 160),
            named: isDisabled ? "disabled" : "enabled"
        )
    }
}
