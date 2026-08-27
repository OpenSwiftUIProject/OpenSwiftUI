//
//  ReducedTimelineScheduleTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing

struct ReducedTimelineScheduleTests {
    @Test
    func entriesAreMergedInOrderWithoutDuplicates() {
        let firstDate = Date(timeIntervalSinceReferenceDate: 10)
        let secondDate = Date(timeIntervalSinceReferenceDate: 20)
        let sharedDate = Date(timeIntervalSinceReferenceDate: 30)
        let fourthDate = Date(timeIntervalSinceReferenceDate: 40)
        let fifthDate = Date(timeIntervalSinceReferenceDate: 50)
        let schedule = ReducedTimelineSchedule(
            t1: TestTimelineSchedule(dates: [firstDate, sharedDate, fifthDate]),
            t2: TestTimelineSchedule(dates: [secondDate, sharedDate, fourthDate])
        )

        #expect(Array(schedule.entries(from: firstDate, mode: .normal)) == [
            firstDate,
            secondDate,
            sharedDate,
            fourthDate,
            fifthDate,
        ])
    }

    @Test
    func equalityComparesBothSchedules() {
        let firstDate = Date(timeIntervalSinceReferenceDate: 10)
        let secondDate = Date(timeIntervalSinceReferenceDate: 20)
        let first = TestTimelineSchedule(dates: [firstDate])
        let second = TestTimelineSchedule(dates: [secondDate])
        let schedule = ReducedTimelineSchedule(t1: first, t2: second)

        #expect(schedule == ReducedTimelineSchedule(t1: first, t2: second))
        #expect(schedule != ReducedTimelineSchedule(t1: second, t2: second))
        #expect(schedule != ReducedTimelineSchedule(t1: first, t2: first))
    }
}

private struct TestTimelineSchedule: TimelineSchedule, Equatable {
    let dates: [Date]

    func entries(
        from _: Date,
        mode _: TimelineScheduleMode
    ) -> [Date] {
        dates
    }
}
