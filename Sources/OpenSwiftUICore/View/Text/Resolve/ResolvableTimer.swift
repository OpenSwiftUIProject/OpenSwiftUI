//
//  ResolvableTimer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 5596C2D3913FECC4138CDA24E2471B2B (SwiftUICore)

package import Foundation

extension SystemFormatStyle {
    // FIXME
    package struct Timer: DiscreteFormatStyle {
        package func discreteInput(before input: Date) -> Date? {
            nil
        }
        
        package func discreteInput(after input: Date) -> Date? {
            nil
        }
        
        package func format(_ value: Date) -> String {
            ""
        }
        
        package typealias FormatInput = Date

        package typealias FormatOutput = String
    }
}

// MARK: - ResolvableTimer

package struct ResolvableTimer {
    package static let defaultUnits: NSCalendar.Unit = [
        .hour,
        .minute,
        .second,
    ]

    package var interval: DateInterval
    package var pause: TimeInterval?
    package var countdown: Bool
    @CodableRawRepresentable package var units: NSCalendar.Unit
    package let calendar: Calendar
    package let locale: Locale
    package let timeZone: TimeZone

    package init(
        interval: DateInterval,
        pause: TimeInterval? = nil,
        countdown: Bool,
        units: NSCalendar.Unit? = nil,
        in environment: EnvironmentValues
    ) {
        self.interval = interval
        self.pause = pause
        self.countdown = countdown
        self._units = .init(units ?? Self.defaultUnits)
        self.calendar = environment.calendar
        self.locale = environment.locale
        self.timeZone = environment.timeZone
    }

    package var format: SystemFormatStyle.Timer {
        _openSwiftUIUnimplementedFailure()
    }

    package var source: TimeDataSource<Date>.DateStorage {
        guard let pause else {
            return .identity
        }
        let pauseDate = if countdown {
            interval.end - pause
        } else {
            interval.start + pause
        }
        return .identityWithPause(pauseDate: pauseDate)
    }
}

extension ResolvableTimer: ConfigurationBasedResolvableStringAttributeRepresentation {
    package static let attribute = NSAttributedString.Key("OpenSwiftUI.ResolvableTimer")

    package static func decode(
        from decoder: any Decoder
    ) throws -> (any ResolvableStringAttribute)? {
        let timer = try ResolvableTimer(from: decoder)
        return TimeDataFormatting.Resolvable(
            source: timer.source,
            format: timer.format,
            secondsUpdateFrequencyBudget: 60.0
        )
    }

    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        .timerInterval(interval: interval, countdown: countdown)
    }

    private enum CodingKeys: CodingKey {
        case interval
        case pause
        case countdown
        case units
        case calendar
        case locale
        case timeZone
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interval = try container.decode(DateInterval.self, forKey: .interval)
        self.pause = try container.decodeIfPresent(TimeInterval.self, forKey: .pause)
        self.countdown = try container.decode(Bool.self, forKey: .countdown)
        self._units = try container.decode(
            CodableRawRepresentable<NSCalendar.Unit>.self,
            forKey: .units
        )
        self.calendar = try container.decode(Calendar.self, forKey: .calendar)
        self.locale = try container.decode(Locale.self, forKey: .locale)
        self.timeZone = try container.decode(TimeZone.self, forKey: .timeZone)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(interval, forKey: .interval)
        try container.encodeIfPresent(pause, forKey: .pause)
        try container.encode(countdown, forKey: .countdown)
        try container.encode(_units, forKey: .units)
        try container.encode(calendar, forKey: .calendar)
        try container.encode(locale, forKey: .locale)
        try container.encode(timeZone, forKey: .timeZone)
    }
}

extension ResolvableTimer: Hashable {
    package static func == (lhs: ResolvableTimer, rhs: ResolvableTimer) -> Bool {
        lhs.interval == rhs.interval &&
            lhs.pause == rhs.pause &&
            lhs.countdown == rhs.countdown &&
            lhs.units == rhs.units &&
            lhs.calendar == rhs.calendar &&
            lhs.locale == rhs.locale &&
            lhs.timeZone == rhs.timeZone
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(interval)
        hasher.combine(pause)
        hasher.combine(countdown)
        hasher.combine(units.rawValue)
        hasher.combine(calendar)
        hasher.combine(locale)
        hasher.combine(timeZone)
    }
}

extension ResolvableTimer: CustomDebugStringConvertible {
    package var debugDescription: String {
        "    ResolvableTimer(interval: \(interval),    pause: \(pause?.debugDescription ?? "–"),     countdown: \(countdown),     units: \(units))\""
    }
}
