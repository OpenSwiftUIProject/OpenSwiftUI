//
//  ResolvableDateInterval.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3637F345778836D6507813342C81E489 (SwiftUICore)

package import Foundation
#if canImport(Darwin)
import OpenSwiftUI_SPI
#endif

// MARK: - ResolvableDateInterval

package struct ResolvableDateInterval {
    package var interval: DateInterval
    package let calendar: Calendar
    package let locale: Locale
    package let timeZone: TimeZone

    package init(
        _ interval: DateInterval,
        in environment: EnvironmentValues
    ) {
        self.interval = interval
        self.calendar = environment.calendar
        self.locale = environment.locale
        self.timeZone = environment.timeZone
    }
}

extension ResolvableDateInterval: ResolvableStringAttribute, ResolvableStringAttributeFamily, Codable {
    package static let attribute = NSAttributedString.Key("OpenSwiftUI.ResolvableDateInterval")

    package func resolve(
        in context: ResolvableStringResolutionContext
    ) -> AttributedString? {
        #if canImport(Darwin)
        let provider = TimeIntervalProvider(
            start: interval.start,
            end: interval.end,
            calendar: calendar,
            locale: locale,
            timeZone: timeZone
        )
        guard let string = provider.formattedString() else {
            return nil
        }
        return AttributedString(string)
        #else
        nil
        #endif
    }

    package var schedule: ExplicitTimelineSchedule<[Date]>? {
        nil
    }

    private enum CodingKeys: CodingKey {
        case interval
        case calendar
        case locale
        case timeZone
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interval = try container.decode(DateInterval.self, forKey: .interval)
        self.calendar = try container.decode(Calendar.self, forKey: .calendar)
        self.locale = try container.decode(Locale.self, forKey: .locale)
        self.timeZone = try container.decode(TimeZone.self, forKey: .timeZone)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(interval, forKey: .interval)
        try container.encode(calendar, forKey: .calendar)
        try container.encode(locale, forKey: .locale)
        try container.encode(timeZone, forKey: .timeZone)
    }
}

extension ResolvableDateInterval: Hashable {}
