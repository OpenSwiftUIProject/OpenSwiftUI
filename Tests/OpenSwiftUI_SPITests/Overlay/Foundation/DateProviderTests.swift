//
//  DateProviderTests.swift
//  OpenSwiftUI_SPITests

#if canImport(Darwin)
import Foundation
import OpenSwiftUI_SPI
import Testing

struct DateProviderTests {
    private let calendar: Calendar
    private let locale = Locale(identifier: "en_US_POSIX")
    private let timeZone = TimeZone(secondsFromGMT: 0)!
    private let date: Date

    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
        date = calendar.date(
            from: DateComponents(
                year: 2023,
                month: 11,
                day: 14,
                hour: 22,
                minute: 13,
                second: 20
            )
        )!
    }

    @Test
    func configuration() {
        let provider: BaseDateProvider = DateProvider(
            date: date,
            units: [.year, .month, .day],
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.calendar == calendar)
        #expect(provider.locale == locale)
        #expect(provider.timeZone == timeZone)

        var replacementCalendar = Calendar(identifier: .iso8601)
        replacementCalendar.timeZone = timeZone
        let replacementLocale = Locale(identifier: "en_GB")
        let replacementTimeZone = TimeZone(secondsFromGMT: 3_600)!
        provider.calendar = replacementCalendar
        provider.locale = replacementLocale
        provider.timeZone = replacementTimeZone

        #expect(provider.calendar == replacementCalendar)
        #expect(provider.locale == replacementLocale)
        #expect(provider.timeZone == replacementTimeZone)
    }

    @Test
    func dateUpdateMetadata() {
        let provider: BaseDateProvider = DateProvider(
            date: date,
            units: [.year, .month, .day]
        )

        #expect(provider.updateType == 0)
        #expect(provider.updateWallClockAlignment.isEmpty)
        #expect(provider.updateInterval() == nil)
        #expect(provider.timerInterval == nil)
        #expect(provider.timerEndDate == nil)
    }

    @Test
    func dateFormatUpdateMetadata() {
        let provider: BaseDateProvider = DateProvider(
            dateFormat: "yyyy-MM-dd HH:mm:ss",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.updateType == 1)
        #expect(provider.updateWallClockAlignment == .second)
    }

    @Test
    func dateFormatTemplateUpdateMetadata() {
        let provider: BaseDateProvider = DateProvider(
            dateFormatTemplate: "jm",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.updateType == 1)
        #expect(provider.updateWallClockAlignment == .minute)
    }

    @Test
    func formattedString() {
        let provider: BaseDateProvider = DateProvider(
            date: date,
            units: [.year, .month, .day],
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.formattedString() == "November 14, 2023")
    }

    @Test
    func formattedStringInContext() {
        let provider: BaseDateProvider = DateProvider(
            dateFormat: "yyyy-MM-dd HH:mm:ss",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )
        let context = DateFormattingContext(
            referenceDate: date,
            isLuminanceReduced: true
        )

        #expect(provider.formattedString(in: context) == "2023-11-14 22:13:20")
    }
}
#endif
