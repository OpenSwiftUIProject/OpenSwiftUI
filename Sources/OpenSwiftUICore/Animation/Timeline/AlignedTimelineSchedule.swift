//
//  AlignedTimelineSchedule.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F93DC68D34AFECBDFB2B93E14EE1F6CA (SwiftUICore)

import Foundation

// MARK: - AlignedTimelineSchedule

struct AlignedTimelineSchedule: TimelineSchedule {
    let alignment: NSCalendar.Unit

    func entries(
        from startDate: Date,
        mode: TimelineScheduleMode
    ) -> Entries {
        Entries(startDate: startDate, alignment: alignment)
    }

    struct Entries: Sequence, IteratorProtocol {
        var nextDate: Date?
        let alignment: NSCalendar.Unit
        var zeroedSmallerComponents: DateComponents

        init(startDate: Date, alignment: NSCalendar.Unit) {
            nextDate = nil
            self.alignment = alignment
            zeroedSmallerComponents = DateComponents(
                zeroingUnits: alignment.smallerUnits
            )
            if Calendar.current.date(
                startDate,
                matchesComponents: zeroedSmallerComponents
            ) {
                nextDate = startDate
            } else {
                nextDate = Calendar.current.nextDate(
                    after: startDate,
                    matching: zeroedSmallerComponents,
                    matchingPolicy: .nextTime,
                    direction: .backward
                ) ?? startDate
            }
        }

        mutating func next() -> Date? {
            guard let date = nextDate else {
                return nil
            }
            nextDate = Calendar.current.nextDate(
                after: date,
                matching: zeroedSmallerComponents,
                matchingPolicy: .nextTime
            )
            return date
        }
    }
}

// MARK: - NSCalendar.Unit

extension NSCalendar.Unit {
    fileprivate static let order: [Self] = [
        .year,
        .month,
        .day,
        .hour,
        .minute,
        .second,
        .nanosecond,
    ]

    fileprivate var smallerUnits: [Self] {
        guard let index = Self.order.firstIndex(where: contains) else {
            return []
        }
        return Array(Self.order[(index + 1)...])
    }
}

// MARK: - DateComponents

extension DateComponents {
    init(zeroingUnits units: [NSCalendar.Unit]) {
        self.init()
        if units.contains(.year) {
            year = 0
        }
        if units.contains(.month) {
            month = 0
        }
        if units.contains(.day) {
            day = 0
        }
        if units.contains(.hour) {
            hour = 0
        }
        if units.contains(.minute) {
            minute = 0
        }
        if units.contains(.second) {
            second = 0
        }
        if units.contains(.nanosecond) {
            nanosecond = 0
        }
    }
}
