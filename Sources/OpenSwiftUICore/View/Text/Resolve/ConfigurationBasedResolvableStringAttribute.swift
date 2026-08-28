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
                AnySequence(PeriodicTimelineSchedule(
                    from: startDate,
                    by: period
                ).entries(
                    from: startDate,
                    mode: mode
                ))
            case let .timer(end):
                TimerTimelineSchedule(
                    alignment: end
                ).entries(
                    from: startDate,
                    mode: mode
                )
            case let .timerInterval(interval, countdown):
                TimerIntervalTimelineSchedule(
                    interval: interval,
                    countdown: countdown
                ).entries(
                    from: startDate,
                    mode: mode
                )
            case let .wallClock(unit):
                AnySequence(AlignedTimelineSchedule(
                    alignment: unit
                ).entries(
                    from: startDate,
                    mode: mode
                ))
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

extension ReducedTimelineSchedule: InvalidationConfigurtaionProvider where T1: InvalidationConfigurtaionProvider, T2: InvalidationConfigurtaionProvider {
    var invalidationConfiguration: ResolvableAttributeConfiguration {
        var configuration = t1.invalidationConfiguration
        configuration.reduce(t2.invalidationConfiguration)
        return configuration
    }
}

extension ResolvableAttributeConfiguration.Schedule: InvalidationConfigurtaionProvider {}

extension TimeDataFormatting.Resolvable: InvalidationConfigurtaionProvider {}

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
