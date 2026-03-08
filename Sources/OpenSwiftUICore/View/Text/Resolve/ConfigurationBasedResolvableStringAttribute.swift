//
//  ConfigurationBasedResolvableStringAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Missing ResolvableAttributeConfiguration implementation
//  ID: A318841E6831BFF835E45F725C9F7477 (SwiftUICore)

package import Foundation

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

// MARK: - ResolvableAttributeConfiguration [WIP]

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
            if let lhsDelay, let rhsDelay {
                self = .interval(delay: min(lhsDelay, rhsDelay))
            } else {
                self = .interval(delay: lhsDelay ?? rhsDelay)
            }
        case let (.wallClock(alignment: lhsAlignment), .wallClock(alignment: rhsAlignment)):
            _openSwiftUIUnimplementedFailure()
        // WIP: handle other combinations
        default:
            break
        }
    }
}

extension ResolvableAttributeConfiguration {
    package struct Schedule: TimelineSchedule {
        enum Alignment {
            case interval(period: Double)
            case timer(end: Date)
            case timerInterval(interval: DateInterval, countdown: Bool)
            case wallClock(alignment: NSCalendar.Unit)
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
            case .wallClock(let alignment):
                self.alignment = .wallClock(alignment: alignment)
            }
        }

        package func entries(
            from startDate: Date,
            mode: TimelineScheduleMode
        ) -> AnySequence<Date> {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

extension ResolvableAttributeConfiguration: Codable {
    enum Errors: Error {
        case missingValue
    }

    private enum CodingKeys: CodingKey {
        case interval
        case delay
        case wallClock
        case alignment
        case timer
        case countdowns
        case timeInterval
    }

    package func encode(to encoder: any Encoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: any Decoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}
