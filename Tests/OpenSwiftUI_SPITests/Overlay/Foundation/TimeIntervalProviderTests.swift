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
        #expect(provider.updateType == 0)
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
        #expect(string.contains("10:13"))
        #expect(string.contains("11:45"))
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
        #expect(string.contains("Nov 14"))
        #expect(string.contains("Nov 15"))
    }
}
#endif
