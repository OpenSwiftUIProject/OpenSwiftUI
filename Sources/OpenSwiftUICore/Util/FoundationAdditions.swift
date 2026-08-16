//
//  FoundationAdditions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D384102E74FAC80F1E8F43DFDDE75487 (SwiftUICore)

package import Foundation
#if canImport(UniformTypeIdentifiers)
package import UniformTypeIdentifiers
#endif

#if canImport(UniformTypeIdentifiers)
extension URL {
    package var openSwiftUI_contentType: UTType? {
        try? resourceValues(forKeys: [.contentTypeKey]).contentType
    }
}
#endif

extension Set where Element == Duration.UnitsFormatStyle.Unit {
    package init(_ nsCalendarUnit: NSCalendar.Unit?) {
        self = []
        guard let nsCalendarUnit else {
            return
        }
        for unit in [
            NSCalendar.Unit.day,
            .hour,
            .minute,
            .second,
            .nanosecond,
        ] where nsCalendarUnit.contains(unit) {
            if unit == .day {
                insert(.days)
            } else if unit == .hour {
                insert(.hours)
            } else if unit == .minute {
                insert(.minutes)
            } else if unit == .second {
                insert(.seconds)
            } else if unit == .nanosecond {
                insert(.nanoseconds)
            }
        }
    }
}

extension Set where Element == Date.ComponentsFormatStyle.Field {
    package init(_ nsCalendarUnit: NSCalendar.Unit?) {
        self = []
        guard let nsCalendarUnit else {
            return
        }
        for unit in [
            NSCalendar.Unit.year,
            .month,
            .weekOfYear,
            .weekOfMonth,
            .day,
            .hour,
            .minute,
            .second,
        ] where nsCalendarUnit.contains(unit) {
            if unit == .year {
                insert(.year)
            } else if unit == .month {
                insert(.month)
            } else if unit == .weekOfYear || unit == .weekOfMonth {
                insert(.week)
            } else if unit == .day {
                insert(.day)
            } else if unit == .hour {
                insert(.hour)
            } else if unit == .minute {
                insert(.minute)
            } else if unit == .second {
                insert(.second)
            }
        }
    }
}

extension NSCalendar.Unit {
    package init(_ fields: Set<Date.ComponentsFormatStyle.Field>) {
        self = fields.compactMap { field -> NSCalendar.Unit? in
            if field == .year {
                .year
            } else if field == .month {
                .month
            } else if field == .week {
                fields.contains(.month) ? .weekOfMonth : .weekOfYear
            } else if field == .day {
                .day
            } else if field == .hour {
                .hour
            } else if field == .minute {
                .minute
            } else if field == .second {
                .second
            } else {
                nil
            }
        }.reduce([]) { $0.union($1) }
    }
}

extension NSCalendar.Unit {
    package init(_ units: Set<Duration.UnitsFormatStyle.Unit>) {
        self = units.compactMap { unit -> NSCalendar.Unit? in
            if unit == .weeks {
                .weekOfYear
            } else if unit == .days {
                .day
            } else if unit == .hours {
                .hour
            } else if unit == .minutes {
                .minute
            } else if unit == .seconds {
                .second
            } else if unit == .milliseconds || unit == .microseconds || unit == .nanoseconds {
                .nanosecond
            } else {
                nil
            }
        }.reduce([]) { $0.union($1) }
    }
}

extension Calendar.Component {
    package struct Magnitude: Comparable, Hashable, Codable {
        var interval: TimeInterval

        package init(_ duration: Duration) {
            let components = duration.components
            interval = Double(components.seconds)
                + Double(components.attoseconds) * 1e-18
        }

        package init(_ interval: TimeInterval) {
            self.interval = interval
        }

        package static func < (lhs: Magnitude, rhs: Magnitude) -> Bool {
            lhs.interval < rhs.interval
        }

        package mutating func incrementByOrderOfMagnitude() {
            interval *= 10.0
        }

        package mutating func decrementByOrderOfMagnitude() {
            interval /= 10.0
        }

        package func ratio(to other: Magnitude) -> Double {
            let fallback: Double = interval == 0.0 ? .nan : .infinity
            return other.interval != 0.0 ? interval / other.interval : fallback
        }

        package static let max = Magnitude(.infinity)

        package static let zero = Magnitude(Duration.zero)
    }
}

extension Date.ComponentsFormatStyle.Field {
    package var magnitude: Calendar.Component.Magnitude {
        let interval: TimeInterval
        if self == .year {
            interval = 31_536_000.0
        } else if self == .month {
            interval = 2_592_000.0
        } else if self == .week {
            interval = 604_800.0
        } else if self == .day {
            interval = 86_400.0
        } else if self == .hour {
            interval = 3_600.0
        } else if self == .minute {
            interval = 60.0
        } else if self == .second {
            interval = 1.0
        } else {
            return .max
        }
        return .init(interval)
    }
}

extension Duration.UnitsFormatStyle.Unit {
    package var magnitude: Calendar.Component.Magnitude {
        let duration: Duration
        if self == .weeks {
            duration = .seconds(604_800)
        } else if self == .days {
            duration = .seconds(86_400)
        } else if self == .hours {
            duration = .seconds(3_600)
        } else if self == .minutes {
            duration = .seconds(60)
        } else if self == .seconds {
            duration = .seconds(1)
        } else if self == .milliseconds {
            duration = .milliseconds(1)
        } else if self == .microseconds {
            duration = .microseconds(1)
        } else if self == .nanoseconds {
            duration = .nanoseconds(1)
        } else {
            return .max
        }
        return .init(duration)
    }
}

extension AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field {
    package var magnitude: Calendar.Component.Magnitude {
        let interval: TimeInterval
        if self == .weeks {
            interval = 604_800.0
        } else if self == .days {
            interval = 86_400.0
        } else if self == .hours {
            interval = 3_600.0
        } else if self == .minutes {
            interval = 60.0
        } else if self == .seconds {
            interval = 1.0
        } else if self == .microseconds {
            interval = 0.000_001
        } else if self == .milliseconds {
            interval = 0.001
        } else if self == .nanoseconds {
            interval = 0.000_000_001
        } else {
            return .max
        }
        return .init(interval)
    }
}

extension AttributeScopes.FoundationAttributes.DateFieldAttribute.Field {
    package var magnitude: Calendar.Component.Magnitude {
        let interval: TimeInterval
        if self == .era {
            interval = 63_072_000_000.0
        } else if self == .year || self == .relatedGregorianYear {
            interval = 31_536_000.0
        } else if self == .quarter {
            interval = 7_776_000.0
        } else if self == .month {
            interval = 2_592_000.0
        } else if self == .weekOfYear || self == .weekOfMonth || self == .weekdayOrdinal {
            interval = 604_800.0
        } else if self == .weekday || self == .day || self == .dayOfYear {
            interval = 86_400.0
        } else if self == .amPM {
            interval = 43_200.0
        } else if self == .hour {
            interval = 3_600.0
        } else if self == .minute {
            interval = 60.0
        } else if self == .second {
            interval = 1.0
        } else if self == .secondFraction {
            interval = 0.001
        } else {
            return .max
        }
        return .init(interval)
    }
}
