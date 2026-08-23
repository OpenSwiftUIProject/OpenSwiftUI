//
//  SystemFormatStyleTimerTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import Testing

@Suite
struct SystemFormatStyleTimerTests {
    private let start = Date(timeIntervalSinceReferenceDate: 1_000)
    private let locale = Locale(identifier: "en_US_POSIX")

    private func plainText(_ value: AttributedString) -> String {
        String(value.characters)
    }

    @Test
    func publicFactoriesConfigureStyles() {
        let end = start.addingTimeInterval(100)

        let countdown: SystemFormatStyle.Timer = .timer(
            countingDownIn: start..<end,
            showsHours: false,
            maxFieldCount: 2,
            maxPrecision: .seconds(1)
        )
        #expect(countdown.countingMode == .timer(countsdown: true))
        #expect(countdown.maxFieldCount == 2)
        #expect(
            plainText(countdown.locale(locale).format(start.addingTimeInterval(65))) ==
                "0:35"
        )

        let countup: SystemFormatStyle.Timer = .timer(
            countingUpIn: start..<end,
            showsHours: false,
            maxFieldCount: 2,
            maxPrecision: .seconds(1)
        )
        #expect(countup.countingMode == .timer(countsdown: false))
        #expect(countup.maxFieldCount == 2)
        #expect(
            plainText(countup.locale(locale).format(start.addingTimeInterval(65))) ==
                "1:05"
        )

        let stopwatch: SystemFormatStyle.Stopwatch = .stopwatch(
            startingAt: start,
            showsHours: false,
            maxFieldCount: 3,
            maxPrecision: .seconds(1)
        )
        #expect(stopwatch.base.countingMode == .stopwatch)
        #expect(stopwatch.base.maxFieldCount == 3)
        #expect(
            plainText(stopwatch.locale(locale).format(start.addingTimeInterval(65))) ==
                "01:05"
        )
    }

    @Test
    func timerFormattingClampsAtIntervalBounds() {
        let end = start.addingTimeInterval(100)
        let countup = SystemFormatStyle.Timer(
            countingUpIn: start..<end,
            maxPrecision: .seconds(1)
        )
        .locale(locale)
        let countdown = SystemFormatStyle.Timer(
            countingDownIn: start..<end,
            maxPrecision: .seconds(1)
        )
        .locale(locale)

        #expect(plainText(countup.format(start.addingTimeInterval(-1))) == "0:00")
        #expect(plainText(countup.format(start.addingTimeInterval(65))) == "1:05")
        #expect(plainText(countup.format(end.addingTimeInterval(1))) == "1:40")
        #expect(plainText(countdown.format(start.addingTimeInterval(-1))) == "1:40")
        #expect(plainText(countdown.format(start.addingTimeInterval(65))) == "0:35")
        #expect(plainText(countdown.format(end.addingTimeInterval(1))) == "0:00")
    }

    @Test
    func stopwatchFormattingClampsBeforeStart() {
        let stopwatch = SystemFormatStyle.Stopwatch(
            startingAt: start,
            maxPrecision: .milliseconds(10)
        )
        .locale(locale)

        #expect(plainText(stopwatch.format(start.addingTimeInterval(-1))) == "00:0000")
        #expect(plainText(stopwatch.format(start.addingTimeInterval(1.25))) == "00:0125")
    }

    @Test
    func discreteInputsRespectTimerRange() throws {
        let end = start.addingTimeInterval(100)
        let style = SystemFormatStyle.Timer(
            countingUpIn: start..<end,
            maxPrecision: .seconds(1)
        )

        #expect(style.discreteInput(before: start) == nil)
        #expect(style.discreteInput(after: end) == nil)

        let next = try #require(style.discreteInput(after: start))
        let previous = try #require(style.discreteInput(before: end))
        #expect(next.timeIntervalSinceReferenceDate == 1_001)
        #expect(previous.timeIntervalSinceReferenceDate == 1_100.0.nextDown)
    }

    @Test
    func precisionTransitionMatchesTimerBoundaries() {
        let expectations: [(
            duration: TimeInterval,
            lower: TimeInterval,
            upper: TimeInterval,
            handoff: TimeInterval
        )] = [
            (10, 1_000, 1_010, 1_000),
            (59, 1_000, 1_059, 1_000),
            (60, 1_001, 1_060, 1_000),
            (61, 1_002, 1_061, 1_001),
            (100, 1_041, 1_100, 1_040),
            (3_600, 4_541, 4_600, 4_540),
        ]

        for expectation in expectations {
            let end = start.addingTimeInterval(expectation.duration)
            let styles = [
                SystemFormatStyle.Timer(countingUpIn: start..<end),
                SystemFormatStyle.Timer(countingDownIn: start..<end),
            ]
            for style in styles {
                let transition = style.precisionTransition
                #expect(transition.range.lowerBound.timeIntervalSinceReferenceDate == expectation.lower)
                #expect(transition.range.upperBound.timeIntervalSinceReferenceDate == expectation.upper)
                #expect(transition.handoff.timeIntervalSinceReferenceDate == expectation.handoff)
            }
        }
    }

    @Test
    func stopwatchPrecisionTransitionCoversFirstMinute() {
        let style = SystemFormatStyle.Stopwatch(startingAt: start)
        let transition = style.precisionTransition

        #expect(transition.range.lowerBound.timeIntervalSinceReferenceDate == 1_000)
        #expect(
            transition.range.upperBound.timeIntervalSinceReferenceDate ==
                1_060.0.nextDown
        )
        #expect(transition.handoff.timeIntervalSinceReferenceDate == 1_060)
    }

    @Test
    func timerCodableRoundTripPreservesStoredConfiguration() throws {
        let style = SystemFormatStyle.Timer(
            countingDownIn: start..<start.addingTimeInterval(100),
            showsHours: false,
            maxFieldCount: 2,
            maxPrecision: .milliseconds(10)
        )
        let data = try JSONEncoder().encode(style)
        let decoded = try JSONDecoder().decode(
            SystemFormatStyle.Timer.self,
            from: data
        )

        #expect(decoded.countingMode == .timer(countsdown: true))
        #expect(decoded.maxFieldCount == 2)
        #expect(
            plainText(decoded.locale(locale).format(start.addingTimeInterval(65))) ==
                "0:35"
        )
    }

    @Test
    func reducedFrequencyConfigurationCanBeConstructed() {
        let style = SystemFormatStyle.Timer(
            countingDownIn: start..<start.addingTimeInterval(100)
        )
        let resolvable = TimeDataFormatting.Resolvable(
            source: TimeDataSource<Date>.DateStorage.identity,
            format: style,
            secondsUpdateFrequencyBudget: 60
        )

        #expect(resolvable.configuration.lowFrequencyFormat != nil)
    }
}
