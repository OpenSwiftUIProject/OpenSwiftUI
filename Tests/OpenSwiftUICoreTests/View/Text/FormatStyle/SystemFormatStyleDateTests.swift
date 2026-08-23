//
//  SystemFormatStyleDateTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin)

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import Testing

@Suite
struct SystemFormatStyleDateTests {
    private let anchor = Date(timeIntervalSinceReferenceDate: 1_000_000)
    private let locale = Locale(identifier: "en_US_POSIX")

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func plainText(_ value: AttributedString) -> String {
        String(value.characters)
    }

    @Test
    func dateOffsetFactoryConfiguresStyle() {
        let factory: SystemFormatStyle.DateOffset = .offset(
            to: anchor,
            allowedFields: [.minute, .second],
            maxFieldCount: 2,
            sign: .always(includingZero: false)
        )

        #expect(factory.anchor.timeIntervalSinceReferenceDate == 1_000_000)
        #expect(factory.allowedFields == [.minute, .second])
        #expect(factory.maxFieldCount == 2)
        #expect(
            plainText(
                factory
                    .calendar(calendar)
                    .locale(locale)
                    .format(Date(timeIntervalSinceReferenceDate: 1_000_090))
            ) == "+1:30"
        )
    }

    @Test
    func dateOffsetFormatsSignAndAdvancesBySmallestField() throws {
        let style = SystemFormatStyle.DateOffset(
            to: anchor,
            allowedFields: [.minute],
            maxFieldCount: 1,
            sign: .always(includingZero: false)
        )
        .calendar(calendar)
        .locale(locale)
        let input = anchor.addingTimeInterval(5 * 60)

        #expect(plainText(style.format(input)) == "+5 minutes")
        #expect(plainText(style.format(anchor)) == "0 minutes")
        #expect(style.discreteInput(after: input)?.timeIntervalSinceReferenceDate == 1_000_360)
        #expect(style.discreteInput(before: input)?.timeIntervalSinceReferenceDate == 1_000_240)
    }

    @Test
    func dateReferenceFactoryConfiguresStyle() {
        let fields: Set<Date.ComponentsFormatStyle.Field> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
        ]
        let factory: SystemFormatStyle.DateReference = .reference(
            to: anchor,
            allowedFields: fields,
            maxFieldCount: 2,
            thresholdField: .day
        )

        #expect(factory.date.timeIntervalSinceReferenceDate == 1_000_000)
        #expect(factory.allowedFields == [.year, .month, .day, .hour, .minute])
        #expect(factory.maxFieldCount == 2)
    }

    @Test
    func dateReferenceIncludesThresholdAndProducesAdjacentInputs() throws {
        let style: SystemFormatStyle.DateReference = .reference(
            to: anchor,
            allowedFields: [.year, .day],
            maxFieldCount: 2,
            thresholdField: .month
        )
        let configured = style.calendar(calendar)

        #expect(style.allowedFields == [.year, .month, .day])
        #expect(
            plainText(
                configured
                    .locale(locale)
                    .format(Date(timeIntervalSinceReferenceDate: 1_000_060))
            ) == "today"
        )

        let previous = try #require(configured.discreteInput(before: anchor))
        let next = try #require(configured.discreteInput(after: anchor))
        #expect(previous.timeIntervalSinceReferenceDate < 1_000_000)
        #expect(next.timeIntervalSinceReferenceDate > 1_000_000)
    }

    @Test
    func dateStylesAdaptToCompactSizeVariant() {
        let offset = SystemFormatStyle.DateOffset(to: anchor)
            .exactSizeVariant(.compact)
        let reference = SystemFormatStyle.DateReference(to: anchor)
            .exactSizeVariant(.compact)

        #expect(offset.style.sizeVariant == .compact)
        #expect(offset.exact)
        #expect(reference.style.sizeVariant == .compact)
        #expect(reference.exact)
    }
}

#endif
