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

    #if canImport(Darwin)
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
