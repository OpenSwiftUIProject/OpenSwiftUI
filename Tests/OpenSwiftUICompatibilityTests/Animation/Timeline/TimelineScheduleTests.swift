//
//  TimelineScheduleTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import Foundation

struct TimelineScheduleTests {
    @Test
    func periodicTimelineScheduleEntries() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 5.0
        
        let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
        let entries = schedule.entries(from: Date(timeIntervalSince1970: 12), mode: .normal)
        
        var iterator = entries.makeIterator()
        
        let e1 = iterator.next()
        try #expect(#require(e1).timeIntervalSince1970.isApproximatelyEqual(to: 10.0))
        
        let e2 = iterator.next()
        try #expect(#require(e2).timeIntervalSince1970.isApproximatelyEqual(to: 15.0))
        
        let e3 = iterator.next()
        try #expect(#require(e3).timeIntervalSince1970.isApproximatelyEqual(to: 20.0))
    }
    
    @Test
    func everyMinuteTimelineScheduleEntries() throws {
        let calendar = Calendar.current
        let startDate = Date()
        
        let schedule = EveryMinuteTimelineSchedule()
        let entries = schedule.entries(from: startDate, mode: .normal)
        
        var iterator = entries.makeIterator()
        
        let entry1 = iterator.next()
        let e1 = try #require(entry1)
        let components1 = calendar.dateComponents([.second, .nanosecond], from: e1)
        #expect(components1.second == 0)
        #expect(components1.nanosecond == 0)
        let timeDiff = e1.timeIntervalSince(startDate)
        #expect(timeDiff >= -60 && timeDiff < 60)
        
        let entry2 = iterator.next()
        let e2 = try #require(entry2)
        let diff2 = e2.timeIntervalSince(e1)
        #expect(diff2.isApproximatelyEqual(to: 60.0))
        let components2 = calendar.dateComponents([.second, .nanosecond], from: e2)
        #expect(components2.second == 0)
        #expect(components2.nanosecond == 0)
        
        let entry3 = iterator.next()
        let e3 = try #require(entry3)
        let diff3 = e3.timeIntervalSince(e2)
        #expect(diff3.isApproximatelyEqual(to: 60.0))
        let components3 = calendar.dateComponents([.second, .nanosecond], from: e3)
        #expect(components3.second == 0)
        #expect(components3.nanosecond == 0)
    }
    
    @Test
    func explicitTimelineScheduleEntries() throws {
        let dates = [
            Date(timeIntervalSince1970: 100),
            Date(timeIntervalSince1970: 200),
            Date(timeIntervalSince1970: 300)
        ]
        
        let schedule = ExplicitTimelineSchedule(dates)
        let entries = schedule.entries(from: Date(timeIntervalSince1970: 0), mode: .normal)
        
        var iterator = entries.makeIterator()
        
        let e1 = iterator.next()
        try #expect(#require(e1).timeIntervalSince1970.isApproximatelyEqual(to: 100))
        
        let e2 = iterator.next()
        try #expect(#require(e2).timeIntervalSince1970.isApproximatelyEqual(to: 200))
        
        let e3 = iterator.next()
        try #expect(#require(e3).timeIntervalSince1970.isApproximatelyEqual(to: 300))
        
        #expect(iterator.next() == nil)
    }
    
    @Test
    func periodicTimelineScheduleWithPastStartDate() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 10.0
        
        let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
        let queryDate = Date(timeIntervalSince1970: 25)
        let entries = schedule.entries(from: queryDate, mode: .normal)
        
        var iterator = entries.makeIterator()
        
        let e1 = iterator.next()
        try #expect(#require(e1).timeIntervalSince1970.isApproximatelyEqual(to: 20.0))
        
        let e2 = iterator.next()
        try #expect(#require(e2).timeIntervalSince1970.isApproximatelyEqual(to: 30.0))
    }
    
    @Test
    func periodicTimelineScheduleAlignedStart() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 5.0
        
        let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
        let queryDate = Date(timeIntervalSince1970: 15)
        let entries = schedule.entries(from: queryDate, mode: .normal)
        
        var iterator = entries.makeIterator()
        
        let e1 = iterator.next()
        try #expect(#require(e1).timeIntervalSince1970.isApproximatelyEqual(to: 15.0))
        
        let e2 = iterator.next()
        try #expect(#require(e2).timeIntervalSince1970.isApproximatelyEqual(to: 20.0))
    }
    
    @Test
    func animationTimelineScheduleNormalMode() throws {
        let startDate = Date(timeIntervalSince1970: 0.0)

        let schedule = AnimationTimelineSchedule(minimumInterval: 1.5)
        let entries = schedule.entries(from: startDate, mode: .normal)
        
        var iterator = entries.makeIterator()
        let e1 = iterator.next()
        try #expect(#require(e1).timeIntervalSince1970.isAlmostEqual(to: 0.0))
        let e2 = iterator.next()
        try #expect(#require(e2).timeIntervalSince1970.isAlmostEqual(to: 1.5))
        let e3 = iterator.next()
        try #expect(#require(e3).timeIntervalSince1970.isAlmostEqual(to: 3.0))
    }
    
    @Test
    func animationTimelineScheduleLowFrequencyMode() {
        let schedule = AnimationTimelineSchedule()
        let entries = schedule.entries(from: .init(), mode: .lowFrequency)
        var iterator = entries.makeIterator()
        #expect(iterator.next() == nil)
        #expect(iterator.next() == nil)
    }
    
    @Test
    func animationTimelineSchedulePaused() {
        let schedule = AnimationTimelineSchedule(paused: true)
        let entries = schedule.entries(from: .init(), mode: .normal)
        var iterator = entries.makeIterator()
        #expect(iterator.next() == nil)
        #expect(iterator.next() == nil)
    }
}
