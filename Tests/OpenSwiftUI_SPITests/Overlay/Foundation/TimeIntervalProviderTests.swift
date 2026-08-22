//
//  TimeIntervalProviderTests.swift
//  OpenSwiftUI_SPITests

#if canImport(Darwin)
import Foundation
import OpenSwiftUI_SPI
import Testing

struct TimeIntervalProviderTests {
    private let calendar: Calendar
    private let locale = Locale(identifier: "en_US_POSIX")
    private let timeZone = TimeZone(secondsFromGMT: 0)!
    private let startDate: Date

    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
        startDate = calendar.date(
            from: DateComponents(
                year: 2023,
                month: 11,
                day: 14,
                hour: 22,
                minute: 13
            )
        )!
    }

    @Test
    func configuration() {
        let endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!
        let provider: BaseDateProvider = TimeIntervalProvider(
            start: startDate,
            end: endDate,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.calendar == calendar)
        #expect(provider.locale == locale)
        #expect(provider.timeZone == timeZone)
        #expect(provider.updateType == .interval)
        #expect(provider.updateWallClockAlignment.isEmpty)
        #expect(provider.updateInterval() == nil)
        #expect(provider.timerInterval == nil)
        #expect(provider.timerEndDate == nil)
    }

    @Test
    func datesAreMutable() {
        let endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!
        let provider = TimeIntervalProvider(start: startDate, end: endDate)

        let replacementStartDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let replacementEndDate = calendar.date(byAdding: .hour, value: 2, to: replacementStartDate)!
        provider.startDate = replacementStartDate
        provider.endDate = replacementEndDate

        #expect(provider.startDate == replacementStartDate)
        #expect(provider.endDate == replacementEndDate)
    }

    @Test
    func sameDayIntervalUsesTimeFallback() throws {
        let endDate = calendar.date(
            from: DateComponents(
                year: 2023,
                month: 11,
                day: 14,
                hour: 23,
                minute: 45
            )
        )!
        let provider: BaseDateProvider = TimeIntervalProvider(
            start: startDate,
            end: endDate,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        let string = try #require(provider.formattedString())
        #expect(string == "10:13–11:45\u{202F}PM")

        let context = DateFormattingContext(
            referenceDate: startDate,
            isLuminanceReduced: true
        )
        #expect(provider.formattedString(in: context) == string)
    }

    @Test
    func sameDayIntervalRetainsDistinctDesignators() {
        let morning = calendar.date(
            from: DateComponents(
                year: 2023,
                month: 11,
                day: 14,
                hour: 10,
                minute: 13
            )
        )!
        let evening = calendar.date(
            from: DateComponents(
                year: 2023,
                month: 11,
                day: 14,
                hour: 23,
                minute: 45
            )
        )!
        let provider: BaseDateProvider = TimeIntervalProvider(
            start: morning,
            end: evening,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.formattedString() == "10:13\u{202F}AM–11:45\u{202F}PM")
    }

    @Test
    func sameDayIntervalWithoutDesignators() {
        let endDate = calendar.date(
            from: DateComponents(
                year: 2023,
                month: 11,
                day: 14,
                hour: 23,
                minute: 45
            )
        )!
        let provider: BaseDateProvider = TimeIntervalProvider(
            start: startDate,
            end: endDate,
            calendar: calendar,
            locale: Locale(identifier: "en_GB"),
            timeZone: timeZone
        )

        #expect(provider.formattedString() == "22:13–23:45")
    }

    @Test
    func crossDayIntervalUsesDateFallback() throws {
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let provider: BaseDateProvider = TimeIntervalProvider(
            start: startDate,
            end: endDate,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        let string = try #require(provider.formattedString())
        #expect(string == "Nov 14 – Nov 15")
    }
}
#endif
