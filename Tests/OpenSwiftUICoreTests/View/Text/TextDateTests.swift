//
//  TextDateTests.swift
//  OpenSwiftUICoreTests
//

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct TextDateStyleTests {
    private let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    @Test
    func dateStyleCodableRoundTripsAllStorageKinds() throws {
        let configuredRelative = Text.DateStyle.relative(
            unitConfiguration: .init(
                units: [.day, .hour],
                style: .brief
            )
        )
        let styles: [Text.DateStyle] = [
            .time,
            .date,
            .relative,
            .offset,
            .timer,
            configuredRelative,
        ]

        for style in styles {
            let data = try JSONEncoder().encode(style)
            let decoded = try JSONDecoder().decode(Text.DateStyle.self, from: data)
            #expect(decoded == style)
        }
    }

    @Test
    func dateStyleCodableUsesStableStorageValues() throws {
        let styles: [Text.DateStyle] = [.time, .date, .relative, .offset, .timer]

        for (rawValue, style) in styles.enumerated() {
            let data = try JSONEncoder().encode(style)
            let object = try #require(
                JSONSerialization.jsonObject(with: data) as? [String: Any]
            )
            #expect(object["storage"] as? Int == rawValue)
            #expect(object["unitConfiguration"] == nil)
        }
    }

    @Test
    func dateStyleCodableRejectsUnknownStorage() {
        let data = Data(#"{"storage":5}"#.utf8)

        #expect(throws: Text.DateStyle.Errors.self) {
            try JSONDecoder().decode(Text.DateStyle.self, from: data)
        }
    }

    @Test(arguments: [
        #"{"storage":2,"unitConfiguration":{"units":16,"style":999}}"#,
        #"{"storage":2,"unitConfiguration":{"style":1}}"#,
        #"{"storage":2,"unitConfiguration":"invalid"}"#,
    ])
    func dateStyleCodableIgnoresInvalidOptionalConfiguration(json: String) throws {
        let decoded = try JSONDecoder().decode(
            Text.DateStyle.self,
            from: Data(json.utf8)
        )

        #expect(decoded == .relative)
    }

    @Test
    func dateRangeAndDateIntervalUseEquivalentStorage() {
        let end = start.addingTimeInterval(3_600)
        let interval = DateInterval(start: start, end: end)

        #expect(Text(start ... end) == Text(interval))
        #expect(Text(interval) != Text(DateInterval(
            start: start,
            end: end.addingTimeInterval(1)
        )))
    }

    @Test
    func dateStyleInitializersParticipateInTextEquality() {
        #expect(Text(start, style: .date) == Text(start, style: .date))
        #expect(Text(start, style: .time) == Text(start, style: .time))
        #expect(Text(start, style: .date) != Text(start, style: .time))
    }

    @Test
    func dateStyleUsesPlainDateFormat() {
        let format = Date.FormatStyle()
            .year(.defaultDigits)
            .month(.wide)
            .day(.defaultDigits)

        #expect(Text(start, style: .date) == Text(start, format: format))
        #expect(Text(start, style: .date) != Text(start, format: format.attributedStyle))
    }

    @Test
    func timeStyleUsesMinuteAndPeriodBoundaries() {
        let format = WhitespaceRemovingFormatStyle<
            Date.FormatStyle.Attributed,
            AttributeScopes.FoundationAttributes.DateFieldAttribute
        >(
            base: Date.FormatStyle()
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.defaultDigits)
                .attributedStyle,
            prefixValue: .minute,
            suffixValue: .amPM
        )

        #expect(Text(start, style: .time) == Text(start, format: format))
    }

    @Test
    func dateInterpolationsPreserveTextStorage() {
        let end = start.addingTimeInterval(3_600)
        let range = start...end
        let interval = DateInterval(start: start, end: end)
        let actual: LocalizedStringKey = "Date: \(start, style: .date); range: \(range); interval: \(interval)"
        let expected: LocalizedStringKey = "Date: \(Text(start, style: .date)); range: \(Text(range)); interval: \(Text(interval))"

        #expect(actual == expected)
        #expect(actual.key == "Date: %@; range: %@; interval: %@")
    }

    @Test
    func progressTextDefaultsToCountingUp() {
        let end = start.addingTimeInterval(600)
        let range = start...end
        let text = Text(progressInterval: range)

        #expect(text == Text(progressInterval: range, countsDown: false))
        #expect(text != Text(progressInterval: range, countsDown: true))
        #expect(text != Text(progressInterval: start...end.addingTimeInterval(1)))
        #expect(text != Text(range))
    }

    #if canImport(Darwin)
    @Test(arguments: [false, true])
    func deprecatedTimerIntervalsPreservePauseAndCountdown(countdown: Bool) {
        let end = start.addingTimeInterval(7_200)
        let range = start...end
        let interval = DateInterval(start: start, end: end)
        let text = Text(
            interval: range,
            pauseAt: 120,
            countdown: countdown,
            units: [.minute, .second]
        )

        #expect(text == Text(
            interval: interval,
            pauseAt: 120,
            countdown: countdown,
            units: [.minute, .second]
        ))
        #expect(text == Text(
            timerInterval: range,
            pauseTime: start.addingTimeInterval(120),
            countsDown: countdown,
            showsHours: false
        ))
        #expect(text != Text(
            interval: range,
            pauseAt: 121,
            countdown: countdown,
            units: [.minute, .second]
        ))
    }

    @Test
    func deprecatedTimerDefaultsPreserveCountdownAndUnits() {
        let end = start.addingTimeInterval(7_200)
        let range = start...end
        let interval = DateInterval(start: start, end: end)
        let text = Text(interval: range)

        #expect(text == Text(interval: interval))
        #expect(text == Text(interval: range, pauseAt: nil, countdown: true, units: nil))
        #expect(text == Text(interval: range, units: [.hour, .minute, .second]))
        #expect(text == Text(timerInterval: range))
        #expect(text != Text(interval: range, countdown: false))
        #expect(text != Text(interval: range, units: []))
        #expect(text != Text(interval: range, units: [.hour]))
        #expect(Text(interval: range, units: [.minute, .second]) == Text(
            timerInterval: range,
            showsHours: false
        ))
        #expect(Text(interval: range, units: [.minute, .second, .nanosecond]) != Text(
            interval: range,
            units: [.minute, .second]
        ))
    }

    @Test
    func timerInterpolationPreservesDefaultsAndPause() {
        let range = start...start.addingTimeInterval(7_200)
        let pause = start.addingTimeInterval(120)
        let actual: LocalizedStringKey = "Default: \(timerInterval: range); paused: \(timerInterval: range, pauseTime: pause, countsDown: false, showsHours: false)"
        let expected: LocalizedStringKey = "Default: \(Text(timerInterval: range)); paused: \(Text(timerInterval: range, pauseTime: pause, countsDown: false, showsHours: false))"

        #expect(actual == expected)
        #expect(actual.key == "Default: %@; paused: %@")
    }

    @Test
    func deprecatedTimerInterpolationsDefaultToCountingUp() {
        let end = start.addingTimeInterval(7_200)
        let range = start...end
        let interval = DateInterval(start: start, end: end)
        let actual: LocalizedStringKey = "Range: \(interval: range, pauseAt: nil); interval: \(interval: interval, pauseAt: nil)"
        let expected: LocalizedStringKey = "Range: \(Text(interval: range, countdown: false)); interval: \(Text(interval: interval, countdown: false))"
        let countdown: LocalizedStringKey = "Range: \(Text(interval: range)); interval: \(Text(interval: interval))"

        #expect(actual == expected)
        #expect(actual != countdown)
        #expect(actual.key == "Range: %@; interval: %@")
    }

    @Test(arguments: [false, true])
    func deprecatedTimerInterpolationsPreserveParameters(countdown: Bool) {
        let end = start.addingTimeInterval(7_200)
        let range = start...end
        let interval = DateInterval(start: start, end: end)
        let units: NSCalendar.Unit = [.minute, .second, .nanosecond]
        let actual: LocalizedStringKey = "Range: \(interval: range, pauseAt: 120, countdown: countdown, units: units); interval: \(interval: interval, pauseAt: 120, countdown: countdown, units: units)"
        let expected: LocalizedStringKey = "Range: \(Text(interval: range, pauseAt: 120, countdown: countdown, units: units)); interval: \(Text(interval: interval, pauseAt: 120, countdown: countdown, units: units))"

        #expect(actual == expected)
    }

    @Test
    func dateOffsetFormatsUseExpectedConfiguration() throws {
        let relative = try #require(Text.DateStyle.relative.format(for: start))
        #expect(relative.allowedFields == [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
        ])
        #expect(relative.maxFieldCount == 2)
        #expect(relative.sizeVariant == .compact)
        #expect(try encodedForceUnitsAoDStyle(relative) == false)

        let offset = try #require(Text.DateStyle.offset.format(for: start))
        #expect(offset.maxFieldCount == 1)
        #expect(offset.sizeVariant == .regular)
        #expect(try encodedForceUnitsAoDStyle(offset) == false)

        let timer = try #require(Text.DateStyle.timer.format(for: start))
        #expect(timer.allowedFields == [.hour, .minute, .second])
        #expect(timer.maxFieldCount == 3)
        #expect(timer.sizeVariant == .regular)
        #expect(try encodedForceUnitsAoDStyle(timer) == true)
    }

    @Test(arguments: [NSCalendar.Unit(), .nanosecond])
    func configuredEmptyDateUnitsRemainEmpty(units: NSCalendar.Unit) throws {
        for storage in [Text.DateStyle.Storage.relative, .offset] {
            let style = Text.DateStyle(
                storage: storage,
                unitConfiguration: .init(units: units, style: .full)
            )
            let format = try #require(style.format(for: start))

            #expect(format.allowedFields.isEmpty)
        }
    }

    @Test(arguments: [
        Text.DateStyle.UnitsConfiguration.Style.short,
        .brief,
        .full,
    ])
    func configuredTimerKeepsRegularVariant(
        style: Text.DateStyle.UnitsConfiguration.Style
    ) throws {
        let dateStyle = Text.DateStyle(
            storage: .timer,
            unitConfiguration: .init(units: [.day, .minute, .second], style: style)
        )
        let format = try #require(dateStyle.format(for: start))

        #expect(format.allowedFields == [.minute, .second])
        #expect(format.maxFieldCount == 2)
        #expect(format.sizeVariant == .regular)
        #expect(try encodedForceUnitsAoDStyle(format) == true)
    }

    @Test(arguments: [Text.DateStyle.relative, .offset, .timer])
    func dynamicDateStylesUseCurrentDateSource(style: Text.DateStyle) throws {
        let format = try #require(style.format(for: start))

        #expect(Text(start, style: style) == Text(.currentDate, format: format))
        #expect(Text(start, style: style) != Text(start, format: format))
    }

    @Test(arguments: [
        (AnyInterfaceIdiom(.phone), "1 hr, 5 min"),
        (AnyInterfaceIdiom(.watch), "1 hr 5 min"),
        (AnyInterfaceIdiom(.complication), "1 hr 5 min"),
    ])
    func compactDateUnitsUseInterfaceIdiom(
        idiom: AnyInterfaceIdiom,
        expected: String
    ) {
        let format = SystemFormatStyle.DateOffset(
            to: start,
            allowedFields: [.hour, .minute],
            maxFieldCount: 2,
            sign: .never
        )
        .sizeVariant(.compact)
        .interfaceIdiom(idiom)
        .locale(Locale(identifier: "en_US_POSIX"))

        #expect(String(format.format(start.addingTimeInterval(3_900)).characters) == expected)
    }

    private func encodedForceUnitsAoDStyle(
        _ format: SystemFormatStyle.DateOffset
    ) throws -> Bool {
        let data = try JSONEncoder().encode(format)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        return try #require(object["forceUnitsAoDStyle"] as? Bool)
    }
    #endif
}
