//
//  ConfigurationBasedResolvableStringAttributeTests.swift
//  OpenSwiftUICoreTests
//

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
#if canImport(Darwin)
import OpenSwiftUI_SPI
#endif
import Testing

@Suite
struct ConfigurationBasedResolvableStringAttributeTests {
    @Test
    func dynamicConfigurations() {
        let date = Date(timeIntervalSinceReferenceDate: 10)
        let interval = DateInterval(start: date, duration: 60)

        #expect(!ResolvableAttributeConfiguration.none.isDynamic)
        #expect(!ResolvableAttributeConfiguration.interval().isDynamic)
        #expect(ResolvableAttributeConfiguration.interval(delay: 1).isDynamic)
        #expect(ResolvableAttributeConfiguration.timer(end: date).isDynamic)
        #expect(ResolvableAttributeConfiguration.timerInterval(
            interval: interval,
            countdown: true
        ).isDynamic)
        #expect(ResolvableAttributeConfiguration.wallClock(alignment: .minute).isDynamic)
    }

    @Test
    func reductionUsesConfigurationPriority() {
        let firstDate = Date(timeIntervalSinceReferenceDate: 10)
        let secondDate = Date(timeIntervalSinceReferenceDate: 20)
        let firstInterval = DateInterval(start: firstDate, duration: 30)
        let secondInterval = DateInterval(start: secondDate, duration: 30)

        var configuration = ResolvableAttributeConfiguration.none
        configuration.reduce(.timer(end: firstDate))
        #expect(configuration == .timer(end: firstDate))

        configuration.reduce(.timer(end: secondDate))
        #expect(configuration == .timer(end: firstDate))

        configuration.reduce(.timerInterval(interval: firstInterval, countdown: true))
        #expect(configuration == .timerInterval(interval: firstInterval, countdown: true))

        configuration.reduce(.timerInterval(interval: secondInterval, countdown: false))
        #expect(configuration == .timerInterval(interval: firstInterval, countdown: true))

        configuration.reduce(.wallClock(alignment: .minute))
        #expect(configuration == .wallClock(alignment: .minute))

        configuration.reduce(.wallClock(alignment: .second))
        #expect(configuration == .wallClock(alignment: .second))

        configuration.reduce(.interval(delay: 4))
        configuration.reduce(.interval(delay: 2))
        #expect(configuration == .interval(delay: 2))

        configuration.reduce(.interval())
        #expect(configuration == .interval(delay: 2))

        configuration = .interval()
        configuration.reduce(.interval(delay: 4))
        #expect(configuration == .interval(delay: 4))

        configuration = .interval()
        configuration.reduce(.interval())
        #expect(configuration == .interval())

        configuration = .wallClock(alignment: [.year, .minute])
        configuration.reduce(.wallClock(alignment: [.nanosecond, .second]))
        #expect(configuration == .wallClock(alignment: .nanosecond))
    }

    @Test
    func scheduleConstructionAndEquality() throws {
        #expect(ResolvableAttributeConfiguration.Schedule(config: .none) == nil)
        #expect(ResolvableAttributeConfiguration.Schedule(config: .interval()) == nil)

        let timer = ResolvableAttributeConfiguration.timer(
            end: Date(timeIntervalSinceReferenceDate: 10)
        )
        let first = try #require(ResolvableAttributeConfiguration.Schedule(config: timer))
        let second = try #require(ResolvableAttributeConfiguration.Schedule(config: timer))
        #expect(first == second)
        #expect(first.invalidationConfiguration == timer)

        for configuration in [
            ResolvableAttributeConfiguration.interval(delay: 2),
            .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 10),
                    duration: 60
                ),
                countdown: false
            ),
            .wallClock(alignment: .minute),
        ] {
            let schedule = try #require(
                ResolvableAttributeConfiguration.Schedule(config: configuration)
            )
            #expect(schedule.invalidationConfiguration == configuration)
        }
    }

    #if canImport(Darwin)
    @Test
    func providerUpdateConfiguration() {
        let date = Date(timeIntervalSinceReferenceDate: 10)
        let intervalProvider: BaseDateProvider = DateProvider(
            date: date,
            units: .day
        )
        #expect(intervalProvider.updateConfiguration == .interval())

        let wallClockProvider: BaseDateProvider = DateProvider(
            dateFormat: "HH:mm",
            calendar: Calendar(identifier: .gregorian),
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(secondsFromGMT: 0)
        )
        #expect(wallClockProvider.updateConfiguration == .wallClock(alignment: .minute))

        let invalidProvider: BaseDateProvider = DateProvider(
            dateFormat: "",
            calendar: Calendar(identifier: .gregorian),
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(secondsFromGMT: 0)
        )
        #expect(invalidProvider.updateConfiguration == .none)
    }
    #endif

    @Test
    func normalScheduleEntries() throws {
        let periodic = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .interval(delay: 2)
        ))
        #expect(Array(periodic.entries(
            from: Date(timeIntervalSinceReferenceDate: 10.5),
            mode: .normal
        ).prefix(3)) == dates(10.5, 12.5, 14.5))

        let timer = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timer(end: Date(timeIntervalSinceReferenceDate: 100))
        ))
        #expect(Array(timer.entries(
            from: Date(timeIntervalSinceReferenceDate: 10),
            mode: .normal
        ).prefix(3)) == dates(10, 11, 12))

        let timerInterval = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 0),
                    end: Date(timeIntervalSinceReferenceDate: 12.5)
                ),
                countdown: true
            )
        ))
        #expect(Array(timerInterval.entries(
            from: Date(timeIntervalSinceReferenceDate: 10),
            mode: .normal
        ).prefix(5)) == dates(10, 11, 12, 13))

        let wallClock = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .wallClock(alignment: .minute)
        ))
        #expect(Array(wallClock.entries(
            from: Date(timeIntervalSinceReferenceDate: 90),
            mode: .normal
        ).prefix(3)) == dates(60, 120, 180))
    }

    @Test
    func lowFrequencyTimerIntervalEntries() throws {
        let timer = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timer(end: Date(timeIntervalSinceReferenceDate: 35))
        ))
        #expect(Array(timer.entries(
            from: Date(timeIntervalSinceReferenceDate: 10),
            mode: .lowFrequency
        ).prefix(3)) == dates(35, 95, 155))
        #expect(Array(timer.entries(
            from: Date(timeIntervalSinceReferenceDate: 35),
            mode: .lowFrequency
        ).prefix(2)) == dates(95, 155))

        let countdown = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 10),
                    end: Date(timeIntervalSinceReferenceDate: 130)
                ),
                countdown: true
            )
        ))
        #expect(Array(countdown.entries(
            from: Date(timeIntervalSinceReferenceDate: 10),
            mode: .lowFrequency
        ).prefix(4)) == dates(10, 70, 71, 72))

        let countup = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 10),
                    end: Date(timeIntervalSinceReferenceDate: 200)
                ),
                countdown: false
            )
        ))
        #expect(Array(countup.entries(
            from: Date(timeIntervalSinceReferenceDate: 10),
            mode: .lowFrequency
        ).prefix(3)) == dates(11, 12, 13))
        #expect(Array(countup.entries(
            from: Date(timeIntervalSinceReferenceDate: 70),
            mode: .lowFrequency
        ).prefix(3)) == dates(130, 190))
    }

    @Test
    func lowFrequencyTimerIntervalEndBoundaries() throws {
        let countdown = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 10),
                    end: Date(timeIntervalSinceReferenceDate: 130.5)
                ),
                countdown: true
            )
        ))
        #expect(Array(countdown.entries(
            from: Date(timeIntervalSinceReferenceDate: 130),
            mode: .lowFrequency
        ).prefix(3)) == dates(130, 131))

        let countup = try #require(ResolvableAttributeConfiguration.Schedule(
            config: .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 10),
                    end: Date(timeIntervalSinceReferenceDate: 10.5)
                ),
                countdown: false
            )
        ))
        #expect(Array(countup.entries(
            from: Date(timeIntervalSinceReferenceDate: 10),
            mode: .lowFrequency
        ).prefix(2)) == dates(11, 12))
    }

    @Test
    func codableWireFormat() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let decoder = JSONDecoder()

        #expect(try json(.interval(), encoder: encoder) == #"{"delay":null,"interval":true}"#)
        #expect(try json(.interval(delay: 2), encoder: encoder) == #"{"delay":2,"interval":true}"#)
        #expect(try json(.wallClock(alignment: .minute), encoder: encoder) ==
            #"{"alignment":64,"wallClock":true}"#)

        #expect(throws: Error.self) {
            try encoder.encode(ResolvableAttributeConfiguration.none)
        }

        let roundTripValues: [ResolvableAttributeConfiguration] = [
            .interval(),
            .interval(delay: 2),
            .timer(end: Date(timeIntervalSinceReferenceDate: 10)),
            .timerInterval(
                interval: DateInterval(
                    start: Date(timeIntervalSinceReferenceDate: 10),
                    duration: 60
                ),
                countdown: true
            ),
            .wallClock(alignment: .minute),
        ]
        for value in roundTripValues {
            #expect(try decoder.decode(
                ResolvableAttributeConfiguration.self,
                from: encoder.encode(value)
            ) == value)
        }

        #expect(try decoder.decode(
            ResolvableAttributeConfiguration.self,
            from: Data(#"{}"#.utf8)
        ) == .none)
        #expect(try decoder.decode(
            ResolvableAttributeConfiguration.self,
            from: Data(#"{"interval":true,"delay":2,"wallClock":true,"alignment":64}"#.utf8)
        ) == .interval(delay: 2))
        #expect(try decoder.decode(
            ResolvableAttributeConfiguration.self,
            from: Data(#"{"interval":false,"wallClock":true,"alignment":64}"#.utf8)
        ) == .wallClock(alignment: .minute))

        #expect(throws: ResolvableAttributeConfiguration.Errors.missingValue) {
            try decoder.decode(
                ResolvableAttributeConfiguration.self,
                from: Data(#"{"wallClock":true}"#.utf8)
            )
        }
        #expect(throws: ResolvableAttributeConfiguration.Errors.missingValue) {
            try decoder.decode(
                ResolvableAttributeConfiguration.self,
                from: Data(#"{"countdowns":true}"#.utf8)
            )
        }
    }

    private func dates(_ values: Double...) -> [Date] {
        values.map(Date.init(timeIntervalSinceReferenceDate:))
    }

    private func json(
        _ configuration: ResolvableAttributeConfiguration,
        encoder: JSONEncoder
    ) throws -> String {
        String(decoding: try encoder.encode(configuration), as: UTF8.self)
    }
}
