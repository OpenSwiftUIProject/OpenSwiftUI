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
    func dateFormattingContext() {
        let defaultContext = DateFormattingContext()
        #expect(defaultContext.referenceDate == nil)
        #expect(defaultContext.isLuminanceReduced == false)

        let context = DateFormattingContext(
            referenceDate: date,
            isLuminanceReduced: true
        )
        #expect(context.referenceDate == date)
        #expect(context.isLuminanceReduced == true)
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
    func dateProviderProperties() {
        let units: NSCalendar.Unit = [.year, .month, .day]
        let provider = DateProvider(
            date: date,
            units: units,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.date == date)
        #expect(provider.calendarUnits == units)
        #expect(provider.uppercase == false)
        #expect(provider.dateFormat == nil)
        #expect(provider.dateFormatTemplate == nil)

        let replacementDate = calendar.date(byAdding: .day, value: 1, to: date)!
        let replacementFormatter = DateFormatter()
        provider.date = replacementDate
        provider.calendarUnits = [.weekday]
        provider.uppercase = true
        provider.dateFormat = "yyyy-MM-dd"
        provider.dateFormatTemplate = "yMd"
        provider.dateFormatter = replacementFormatter
        provider.updateWallClockAlignment = .hour

        #expect(provider.date == replacementDate)
        #expect(provider.calendarUnits == .weekday)
        #expect(provider.uppercase == true)
        #expect(provider.dateFormat == "yyyy-MM-dd")
        #expect(provider.dateFormatTemplate == "yMd")
        #expect(provider.dateFormatter === replacementFormatter)
        #expect(provider.updateWallClockAlignment == .hour)
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
    func dateFormatUpdateMetadataEdgeCases() {
        let emptyFormat: BaseDateProvider = DateProvider(
            dateFormat: "",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )
        let designatorFormat: BaseDateProvider = DateProvider(
            dateFormat: "a",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )
        let dayFormat: BaseDateProvider = DateProvider(
            dateFormat: "yyyy-MM-dd",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(emptyFormat.updateWallClockAlignment.isEmpty)
        #expect(designatorFormat.updateWallClockAlignment == .hour)
        #expect(dayFormat.updateWallClockAlignment == .day)
    }

    @Test
    func calendarUnitSmallestUnit() {
        #expect(NSCalendarUnitSmallestUnit([]).isEmpty)
        #expect(NSCalendarUnitSmallestUnit([.year, .minute]) == .minute)
        #expect(NSCalendarUnitSmallestUnit([.nanosecond, .second]) == .nanosecond)
        #expect(NSCalendarUnitSmallestUnit(.init(rawValue: 1 << 16)).isEmpty)
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

    @Test
    func dateFormatTemplateFormattedStringInContext() {
        let provider: BaseDateProvider = DateProvider(
            dateFormatTemplate: "yMd",
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )
        let context = DateFormattingContext(
            referenceDate: date,
            isLuminanceReduced: false
        )

        #expect(provider.formattedString(in: context) == "11/14/2023")
    }

    @Test
    func emptyUnitsUseDayFallback() {
        let provider: BaseDateProvider = DateProvider(
            date: date,
            units: [],
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.formattedString() == "14")
    }

    @Test
    func englishWeekdayDayUsesExactTemplate() {
        let provider: BaseDateProvider = DateProvider(
            date: date,
            units: [.weekday, .day],
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )

        #expect(provider.formattedString() == "Tuesday 14")
    }

    @Test
    func cjkDayUsesExactTemplate() {
        let provider: BaseDateProvider = DateProvider(
            date: date,
            units: [.day],
            calendar: calendar,
            locale: Locale(identifier: "zh_CN"),
            timeZone: timeZone
        )

        #expect(provider.formattedString() == "14")
    }
}
#endif
