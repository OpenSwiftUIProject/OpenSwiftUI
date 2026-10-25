//
//  StepperTests.swift
//  OpenSwiftUITests

import Foundation
@_spi(UIFrameworks) @testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc))
struct StepperTests {
    @Test(arguments: [
        (0, 3, true, false, 3, 0),
        (4, 3, true, true, 7, 1),
        (9, 3, true, true, 10, 6),
        (1, 3, true, true, 4, 0),
        (10, 3, false, true, 10, 7),
        (5, 10, true, true, 10, 0),
        (5, 20, true, true, 10, 0),
        (5, 0, true, true, 5, 5),
        (5, -2, true, true, 3, 7),
        (-2, 3, true, true, 3, 0),
        (12, 3, true, true, 10, 7),
    ] as [(Int, Int, Bool, Bool, Int, Int)])
    func boundedActions(
        initial: Int,
        step: Int,
        canIncrement: Bool,
        canDecrement: Bool,
        incremented: Int,
        decremented: Int
    ) {
        var value = initial
        let binding = Binding(get: { value }, set: { value = $0 })
        let stepper = Stepper(value: binding, in: 0 ... 10, step: step) {
            EmptyView()
        }
        #expect((stepper.configuration.onIncrement != nil) == canIncrement)
        #expect((stepper.configuration.onDecrement != nil) == canDecrement)
        #expect(value == initial)
        stepper.configuration.onIncrement?()
        #expect(value == incremented)
        value = initial
        stepper.configuration.onDecrement?()
        #expect(value == decremented)
    }

    @Test
    func singleValueRangeDisablesBothActions() {
        let stepper = Stepper(value: .constant(4), in: 4 ... 4) { EmptyView() }
        #expect(stepper.configuration.onIncrement == nil)
        #expect(stepper.configuration.onDecrement == nil)
    }

    @Test
    func actionsReadTheCurrentBinding() {
        var value = 2
        let binding = Binding(get: { value }, set: { value = $0 })
        let stepper = Stepper(value: binding, step: 3) { EmptyView() }
        value = 10
        stepper.configuration.onIncrement?()
        #expect(value == 13)
        stepper.configuration.onDecrement?()
        #expect(value == 10)
    }

    @Test
    func boundedActionsClampTheCurrentBindingBeforeAdvancing() {
        var value = 4
        let binding = Binding(get: { value }, set: { value = $0 })
        let stepper = Stepper(value: binding, in: 0 ... 10, step: 3) { EmptyView() }
        value = -2
        stepper.configuration.onIncrement?()
        #expect(value == 3)
        value = 12
        stepper.configuration.onDecrement?()
        #expect(value == 7)
    }

    @Test
    func supportsNonNumericStrideableValues() {
        var value = Date(timeIntervalSinceReferenceDate: 10)
        let binding = Binding(get: { value }, set: { value = $0 })
        let stepper = Stepper(value: binding, step: 2.5) { EmptyView() }
        stepper.configuration.onIncrement?()
        #expect(value.timeIntervalSinceReferenceDate == 12.5)
        stepper.configuration.onDecrement?()
        #expect(value.timeIntervalSinceReferenceDate == 10)
    }

    @Test
    func customActionsPreserveEditingCallbacks() {
        var events: [String] = []
        let stepper = Stepper {
            EmptyView()
        } onIncrement: {
            events.append("increment")
        } onDecrement: {
            events.append("decrement")
        } onEditingChanged: {
            events.append($0 ? "begin" : "end")
        }
        stepper.configuration.onEditingChanged(true)
        stepper.configuration.onIncrement?()
        stepper.configuration.onDecrement?()
        stepper.configuration.onEditingChanged(false)
        #expect(events == ["begin", "increment", "decrement", "end"])
        #expect(stepper.accessibilityValue == nil)
    }

    @Test
    func accessibilityValueUsesTheClampedValueAndStep() throws {
        let stepper = Stepper(value: .constant(12), in: 0 ... 10, step: 3) {
            EmptyView()
        }
        let value = try #require(stepper.accessibilityValue)
        #expect(value.value.intValue == 10)
        #expect(value.minValue?.intValue == 0)
        #expect(value.maxValue?.intValue == 10)
        #expect(value.step?.intValue == 3)
    }

    @Test(arguments: [(5.0, 6), (3.0, 4), (2.0, 2), (1.0, 0), (-1.0, -2)])
    func accessibilitySetValueRoundsToWholeSteps(target: Double, expected: Int) {
        var value = 2
        let binding = Binding(get: { value }, set: { value = $0 })
        let stepper = Stepper(value: binding, step: 2) { EmptyView() }
        let modifier = AccessibilityStepperModifier<EmptyView>(
            stepper.configuration,
            value: stepper.accessibilityValue
        )
        #expect(!modifier.base.configuration.continuous)
        modifier.base.configuration.onSet(AccessibilityNumber(NSNumber(value: target)))
        #expect(value == expected)
    }

    @Test
    func accessibilitySetValueUsesTheEndpointAction() {
        var value = 9
        let binding = Binding(get: { value }, set: { value = $0 })
        let stepper = Stepper(value: binding, in: 0 ... 10, step: 3) { EmptyView() }
        let modifier = AccessibilityStepperModifier<EmptyView>(
            stepper.configuration,
            value: stepper.accessibilityValue
        )
        modifier.base.configuration.onSet(20)
        #expect(value == 10)
    }

    @Test
    func accessibilityWithoutANumericValueDoesNotSet() {
        var increments = 0
        let stepper = Stepper(label: { EmptyView() }, onIncrement: { increments += 1 }, onDecrement: nil)
        let modifier = AccessibilityStepperModifier<EmptyView>(stepper.configuration, value: nil)
        modifier.base.configuration.onSet(5)
        #expect(increments == 0)
        #expect(modifier.base.configuration.value == nil)
    }

    @Test
    func titleOverloadsUseTheBinding() {
        var value = 1
        let binding = Binding(get: { value }, set: { value = $0 })
        let localized = Stepper("Count", value: binding)
        localized.configuration.onIncrement?()
        #expect(value == 2)
        let title = String("Count")
        let verbatim = Stepper(title, value: binding, in: 0 ... 5, step: 2)
        verbatim.configuration.onDecrement?()
        #expect(value == 0)
    }
}
