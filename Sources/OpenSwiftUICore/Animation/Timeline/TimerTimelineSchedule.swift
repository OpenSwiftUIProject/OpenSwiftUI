//
//  TimerTimelineSchedule.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0BDDE1A5AFD32A04BD23EDBBF3673375 (SwiftUICore)

import Foundation

// MARK: - TimerTimelineSchedule

struct TimerTimelineSchedule: TimelineSchedule {
    let alignment: Date

    func entries(
        from startDate: Date,
        mode: TimelineScheduleMode
    ) -> AnySequence<Date> {
        switch mode {
        case .normal:
            AnySequence(EverySecondEntries(
                nextDate: startDate,
                endDate: nil
            ))
        case .lowFrequency:
            AnySequence(ReducedFrequencyEntries(
                start: startDate,
                alignment: alignment
            ))
        }
    }

    struct ReducedFrequencyEntries: Sequence, IteratorProtocol {
        var nextDate: Date?
        var alignment: DateComponents

        init(start: Date, alignment: Date) {
            let calendar = Calendar.current
            self.alignment = calendar.dateComponents(
                [.second, .nanosecond],
                from: alignment
            )
            self.nextDate = calendar.nextDate(
                after: start,
                matching: self.alignment,
                matchingPolicy: .nextTime
            )
        }

        mutating func next() -> Date? {
            guard let date = nextDate else {
                return nil
            }
            nextDate = Calendar.current.nextDate(
                after: date,
                matching: alignment,
                matchingPolicy: .nextTime
            )
            return date
        }
    }
}

// MARK: - TimerIntervalTimelineSchedule

struct TimerIntervalTimelineSchedule: TimelineSchedule {
    var interval: DateInterval
    var countdown: Bool

    func entries(
        from startDate: Date,
        mode: TimelineScheduleMode
    ) -> AnySequence<Date> {
        switch mode {
        case .normal:
            AnySequence(EverySecondEntries(
                nextDate: startDate,
                endDate: interval.end
            ))
        case .lowFrequency where countdown:
            AnySequence(CountdownReducedFrequencyEntries(
                start: startDate,
                end: interval.end
            ))
        case .lowFrequency:
            AnySequence(CountupReducedFrequencyEntries(
                start: startDate,
                interval: interval
            ))
        }
    }

    struct CountdownReducedFrequencyEntries: Sequence, IteratorProtocol {
        var nextDate: Date?
        let endDate: Date
        var secondComponent: DateComponents
        let oneMinuteBeforeTheEnd: Date

        init(start: Date, end: Date) {
            let calendar = Calendar.current
            let secondComponent = calendar.dateComponents(
                [.second, .nanosecond],
                from: end
            )
            let oneMinuteBeforeTheEnd = calendar.date(
                byAdding: .minute,
                value: -1,
                to: end
            ) ?? end

            self.endDate = end
            self.secondComponent = secondComponent
            self.oneMinuteBeforeTheEnd = oneMinuteBeforeTheEnd
            if start >= oneMinuteBeforeTheEnd ||
                calendar.date(start, matchesComponents: secondComponent) {
                nextDate = start
            } else {
                nextDate = calendar.nextDate(
                    after: start,
                    matching: secondComponent,
                    matchingPolicy: .nextTime
                )
            }
        }

        mutating func next() -> Date? {
            guard let date = nextDate else {
                return nil
            }
            if date >= oneMinuteBeforeTheEnd {
                if date >= endDate {
                    nextDate = nil
                } else {
                    nextDate = date.addingTimeInterval(1)
                }
            } else {
                let candidate = Calendar.current.nextDate(
                    after: date,
                    matching: secondComponent,
                    matchingPolicy: .nextTime
                )
                if let candidate, candidate > oneMinuteBeforeTheEnd {
                    nextDate = oneMinuteBeforeTheEnd
                } else {
                    nextDate = candidate
                }
            }
            return date
        }
    }

    struct CountupReducedFrequencyEntries: Sequence, IteratorProtocol {
        let interval: DateInterval
        let start: Date
        var nextDate: Date?
        let firstMinute: Date

        init(start: Date, interval: DateInterval) {
            self.interval = interval
            self.start = start
            nextDate = nil
            let calendar = Calendar.current
            firstMinute = calendar.date(
                byAdding: .minute,
                value: 1,
                to: interval.start
            ) ?? interval.start
            makeNext(current: start)
        }

        mutating func makeNext(current: Date) {
            if current < firstMinute {
                nextDate = current.addingTimeInterval(1)
                return
            }
            let calendar = Calendar.current
            let secondComponent = calendar.dateComponents(
                [.second, .nanosecond],
                from: interval.start
            )
            guard let candidate = calendar.nextDate(
                after: current,
                matching: secondComponent,
                matchingPolicy: .nextTime
            ), candidate <= interval.end else {
                nextDate = nil
                return
            }
            nextDate = candidate
        }

        mutating func next() -> Date? {
            guard let date = nextDate else {
                return nil
            }
            makeNext(current: date)
            return date
        }
    }
}

// MARK: - EverySecondEntries

private struct EverySecondEntries: Sequence, IteratorProtocol {
    var nextDate: Date?
    let endDate: Date?

    mutating func next() -> Date? {
        guard let date = nextDate else {
            return nil
        }
        if let endDate, date >= endDate {
            nextDate = nil
        } else {
            nextDate = date.addingTimeInterval(1)
        }
        return date
    }
}
