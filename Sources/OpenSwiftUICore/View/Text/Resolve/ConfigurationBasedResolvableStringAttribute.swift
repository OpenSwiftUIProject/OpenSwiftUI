//
//  ConfigurationBasedResolvableStringAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A318841E6831BFF835E45F725C9F7477 (SwiftUICore)

package import Foundation
import OpenSwiftUI_SPI

// MARK: - ConfigurationBasedResolvableStringAttribute

package protocol ConfigurationBasedResolvableStringAttribute: ConfigurationBasedResolvableStringAttributeRepresentation, ResolvableStringAttribute {}

// MARK: - ConfigurationBasedResolvableStringAttributeRepresentation

package protocol ConfigurationBasedResolvableStringAttributeRepresentation: Decodable, Encodable, ResolvableStringAttributeFamily, ResolvableStringAttributeRepresentation {
    var invalidationConfiguration: ResolvableAttributeConfiguration { get }
}

extension ConfigurationBasedResolvableStringAttributeRepresentation {
    package var schedule: ResolvableAttributeConfiguration.Schedule? {
        ResolvableAttributeConfiguration.Schedule(config: invalidationConfiguration)
    }
}

// MARK: - ResolvableAttributeConfiguration

package enum ResolvableAttributeConfiguration: Equatable {
    case none
    case interval(delay: Double? = nil)
    case timer(end: Date)
    case timerInterval(interval: DateInterval, countdown: Bool)
    case wallClock(alignment: NSCalendar.Unit)

    package var isDynamic: Bool {
        switch self {
        case .none: false
        case .interval(let delay): delay != nil
        case .timer: true
        case .timerInterval: true
        case .wallClock: true
        }
    }

    mutating package func reduce(_ other: ResolvableAttributeConfiguration) {
        switch (self, other) {
        case let (.interval(lhsDelay), .interval(rhsDelay)):
            let delay: Double? = if let lhsDelay {
                rhsDelay.map { min(lhsDelay, $0) } ?? lhsDelay
            } else {
                rhsDelay
            }
            self = .interval(delay: delay)
        case (.interval, _):
            break
        case (_, .interval):
            self = other
        case let (.wallClock(alignment: lhsAlignment), .wallClock(alignment: rhsAlignment)):
            let combinedAlignment = lhsAlignment.union(rhsAlignment)
            self = .wallClock(alignment: NSCalendarUnitSmallestUnit(combinedAlignment))
        case (.wallClock, _):
            break
        case (_, .wallClock):
            self = other
        case (.timerInterval, _):
            break
        case (_, .timerInterval):
            self = other
        case (.timer, _):
            break
        case (_, .timer):
            self = other
        case (.none, .none):
            break
        }
    }
}

extension ResolvableAttributeConfiguration {
    package struct Schedule: TimelineSchedule, Equatable {
        enum Alignment: Equatable {
            case interval(period: Double)
            case timer(end: Date)
            case timerInterval(interval: DateInterval, countdown: Bool)
            case wallClock(unit: NSCalendar.Unit)
        }

        var alignment: Alignment

        package init?(config: ResolvableAttributeConfiguration) {
            switch config {
            case .none: return nil
            case .interval(let delay):
                guard let delay else {
                    return nil
                }
                alignment = .interval(period: delay)
            case .timer(let end):
                alignment = .timer(end: end)
            case .timerInterval(let interval, let countdown):
                alignment = .timerInterval(interval: interval, countdown: countdown)
            case .wallClock(let unit):
                alignment = .wallClock(unit: unit)
            }
        }

        package func entries(
            from startDate: Date,
            mode: TimelineScheduleMode
        ) -> AnySequence<Date> {
            switch alignment {
            case let .interval(period):
                let schedule = PeriodicTimelineSchedule(
                    from: startDate,
                    by: period
                )
                return AnySequence(schedule.entries(from: startDate, mode: mode))
            case let .timer(end):
                return Self.timerEntries(from: startDate, end: end, mode: mode)
            case let .timerInterval(interval, countdown):
                return Self.timerIntervalEntries(
                    from: startDate,
                    interval: interval,
                    countdown: countdown,
                    mode: mode
                )
            case let .wallClock(unit):
                return Self.wallClockEntries(from: startDate, unit: unit)
            }
        }

        var invalidationConfiguration: ResolvableAttributeConfiguration {
            switch alignment {
            case let .interval(period):
                .interval(delay: period)
            case let .timer(end):
                .timer(end: end)
            case let .timerInterval(interval, countdown):
                .timerInterval(interval: interval, countdown: countdown)
            case let .wallClock(unit):
                .wallClock(alignment: unit)
            }
        }
    }
}

private protocol InvalidationConfigurtaionProvider {
    var invalidationConfiguration: ResolvableAttributeConfiguration { get }
}

extension ResolvableAttributeConfiguration.Schedule: InvalidationConfigurtaionProvider {}

extension TimeDataFormatting.Resolvable: InvalidationConfigurtaionProvider {}

private extension ResolvableAttributeConfiguration.Schedule {
    static func timerEntries(
        from startDate: Date,
        end: Date,
        mode: TimelineScheduleMode
    ) -> AnySequence<Date> {
        switch mode {
        case .normal:
            return secondEntries(from: startDate)
        case .lowFrequency:
            return minuteEntries(from: startDate, alignedTo: end)
        }
    }

    static func timerIntervalEntries(
        from startDate: Date,
        interval: DateInterval,
        countdown: Bool,
        mode: TimelineScheduleMode
    ) -> AnySequence<Date> {
        switch mode {
        case .normal:
            return secondEntries(from: startDate, through: interval.end)
        case .lowFrequency where countdown:
            return countdownEntries(from: startDate, interval: interval)
        case .lowFrequency:
            return countupEntries(from: startDate, interval: interval)
        }
    }

    static func secondEntries(
        from startDate: Date,
        through endDate: Date? = nil
    ) -> AnySequence<Date> {
        AnySequence {
            var nextDate: Date? = startDate
            return AnyIterator<Date> {
                guard let date = nextDate else { return nil }
                if let endDate, date >= endDate {
                    nextDate = nil
                } else {
                    nextDate = date.addingTimeInterval(1)
                }
                return date
            }
        }
    }

    static func minuteEntries(
        from startDate: Date,
        alignedTo alignment: Date
    ) -> AnySequence<Date> {
        AnySequence {
            var nextDate: Date? = nextMinute(
                after: startDate,
                alignedTo: alignment
            )
            return AnyIterator<Date> {
                guard let date = nextDate else { return nil }
                nextDate = nextMinute(after: date, alignedTo: alignment)
                return date
            }
        }
    }

    static func countdownEntries(
        from startDate: Date,
        interval: DateInterval
    ) -> AnySequence<Date> {
        let calendar = Calendar.current
        let oneMinuteBeforeEnd = calendar.date(
            byAdding: .minute,
            value: -1,
            to: interval.end
        ) ?? interval.end.addingTimeInterval(-60)
        return AnySequence {
            let calendar = Calendar.current
            let alignment = calendar.dateComponents(
                [.second, .nanosecond],
                from: interval.end
            )
            var nextDate: Date? = if startDate >= oneMinuteBeforeEnd ||
                calendar.date(startDate, matchesComponents: alignment) {
                startDate
            } else {
                nextMinute(after: startDate, alignedTo: interval.end)
            }
            return AnyIterator<Date> {
                guard let date = nextDate else { return nil }
                if date >= interval.end {
                    nextDate = nil
                } else if date >= oneMinuteBeforeEnd {
                    nextDate = min(date.addingTimeInterval(1), interval.end)
                } else {
                    nextDate = nextMinute(after: date, alignedTo: interval.end)
                }
                return date
            }
        }
    }

    static func countupEntries(
        from startDate: Date,
        interval: DateInterval
    ) -> AnySequence<Date> {
        let calendar = Calendar.current
        let firstMinute = calendar.date(
            byAdding: .minute,
            value: 1,
            to: interval.start
        ) ?? interval.start.addingTimeInterval(60)
        return AnySequence {
            func nextCountupDate(after date: Date) -> Date? {
                let nextDate: Date?
                if date < firstMinute {
                    nextDate = date.addingTimeInterval(1)
                } else {
                    nextDate = nextMinute(
                        after: date,
                        alignedTo: interval.start
                    )
                }
                guard let nextDate, nextDate <= interval.end else {
                    return nil
                }
                return nextDate
            }
            var nextDate = nextCountupDate(after: startDate)
            return AnyIterator<Date> {
                guard let date = nextDate else { return nil }
                nextDate = nextCountupDate(after: date)
                return date
            }
        }
    }

    static func nextMinute(after date: Date, alignedTo alignment: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.second, .nanosecond],
            from: alignment
        )
        return calendar.nextDate(
            after: date,
            matching: components,
            matchingPolicy: .nextTime
        )
    }

    static func wallClockEntries(
        from startDate: Date,
        unit: NSCalendar.Unit
    ) -> AnySequence<Date> {
        AnySequence {
            let calendar = Calendar.current
            let components = zeroedSmallerComponents(than: unit)
            var nextDate: Date?
            if calendar.date(startDate, matchesComponents: components) {
                nextDate = startDate
            } else {
                nextDate = calendar.nextDate(
                    after: startDate,
                    matching: components,
                    matchingPolicy: .nextTime,
                    direction: .backward
                ) ?? startDate
            }
            return AnyIterator<Date> {
                guard let date = nextDate else { return nil }
                nextDate = Calendar.current.nextDate(
                    after: date,
                    matching: components,
                    matchingPolicy: .nextTime
                )
                return date
            }
        }
    }

    static func zeroedSmallerComponents(
        than alignment: NSCalendar.Unit
    ) -> DateComponents {
        let orderedUnits: [NSCalendar.Unit] = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
            .nanosecond,
        ]
        guard let alignmentIndex = orderedUnits.firstIndex(where: alignment.contains) else {
            return DateComponents()
        }
        var components = DateComponents()
        for unit in orderedUnits.suffix(from: alignmentIndex + 1) {
            switch unit {
            case .year: components.year = 0
            case .month: components.month = 0
            case .day: components.day = 0
            case .hour: components.hour = 0
            case .minute: components.minute = 0
            case .second: components.second = 0
            case .nanosecond: components.nanosecond = 0
            default: break
            }
        }
        return components
    }
}

// MARK: - ResolvableAttributeConfiguration + Codable

extension ResolvableAttributeConfiguration: Codable {
    enum Errors: Error, Hashable {
        case missingValue
    }

    private enum CodingKeys: CodingKey {
        case interval
        case delay
        case wallClock
        case alignment
        case timer
        case countdowns
        case timerInterval
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case .none:
            break
        case let .interval(delay):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(true, forKey: .interval)
            try container.encode(delay, forKey: .delay)
        case let .timer(end):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(end, forKey: .timer)
        case let .timerInterval(interval, countdown):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(countdown, forKey: .countdowns)
            try container.encode(interval, forKey: .timerInterval)
        case let .wallClock(alignment):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(true, forKey: .wallClock)
            try container.encode(alignment.rawValue, forKey: .alignment)
        }
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decodeIfPresent(Bool.self, forKey: .interval) == true {
            self = .interval(
                delay: try container.decodeIfPresent(Double.self, forKey: .delay)
            )
        } else if try container.decodeIfPresent(Bool.self, forKey: .wallClock) == true {
            guard let rawValue = try container.decodeIfPresent(
                UInt.self,
                forKey: .alignment
            ) else {
                throw Errors.missingValue
            }
            self = .wallClock(alignment: NSCalendar.Unit(rawValue: rawValue))
        } else if let end = try container.decodeIfPresent(Date.self, forKey: .timer) {
            self = .timer(end: end)
        } else if let countdown = try container.decodeIfPresent(Bool.self, forKey: .countdowns) {
            guard let interval = try container.decodeIfPresent(
                DateInterval.self,
                forKey: .timerInterval
            ) else {
                throw Errors.missingValue
            }
            self = .timerInterval(interval: interval, countdown: countdown)
        } else {
            self = .none
        }
    }
}

#if !canImport(Darwin)
private func NSCalendarUnitSmallestUnit(
    _ units: NSCalendar.Unit
) -> NSCalendar.Unit {
    let orderedUnits: [NSCalendar.Unit] = [
        .nanosecond,
        .second,
        .minute,
        .hour,
        .day,
        .weekday,
        .weekdayOrdinal,
        .weekOfMonth,
        .weekOfYear,
        .month,
        .quarter,
        .year,
        .yearForWeekOfYear,
        .era,
    ]
    return orderedUnits.first(where: units.contains) ?? []
}
#endif
