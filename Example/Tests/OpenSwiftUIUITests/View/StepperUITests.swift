//
//  StepperUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct StepperUITests {
    @Test(arguments: [0, 4, 10])
    func boundedValues(value: Int) {
        openSwiftUIAssertSnapshot(
            of: StepperExample(value: value),
            size: .init(width: 320, height: 120),
            named: "\(value)"
        )
    }

    @Test(arguments: [
        (true, true),
        (true, false),
        (false, true),
        (false, false),
    ] as [(Bool, Bool)])
    func optionalActions(canIncrement: Bool, canDecrement: Bool) {
        openSwiftUIAssertSnapshot(
            of: ActionStepperExample(
                canIncrement: canIncrement,
                canDecrement: canDecrement
            ),
            size: .init(width: 320, height: 100),
            named: "increment-\(canIncrement)-decrement-\(canDecrement)"
        )
    }

    @Test
    func fractionalSteps() {
        openSwiftUIAssertSnapshot(
            of: FractionalStepperExample(),
            size: .init(width: 320, height: 100)
        )
    }

    @Test
    func labelsHidden() {
        openSwiftUIAssertSnapshot(
            of: StepperExample().labelsHidden(),
            size: .init(width: 320, height: 120)
        )
    }

    @Test
    func disabled() {
        openSwiftUIAssertSnapshot(
            of: StepperExample().disabled(true),
            size: .init(width: 320, height: 120)
        )
    }

    @Test(arguments: [.mini, .small, .regular, .large, .extraLarge] as [ControlSize])
    func controlSizes(size: ControlSize) {
        openSwiftUIAssertSnapshot(
            of: StepperExample().controlSize(size),
            size: .init(width: 320, height: 120),
            named: "\(size)"
        )
    }
}
