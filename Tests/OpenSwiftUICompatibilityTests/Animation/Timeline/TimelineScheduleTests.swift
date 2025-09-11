//
//  TimelineScheduleTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import Foundation

struct TimelineScheduleTests {
    @Test
    func periodicTimelineScheduleEntries() {
        let startDate = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 5.0
        
        let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
        let entries = schedule.entries(from: Date(timeIntervalSince1970: 12), mode: TimelineScheduleMode.normal)
        
        var iterator = entries.makeIterator()
        
        // First entry should be aligned to a boundary
        let firstEntry = iterator.next()
        #expect(firstEntry != nil)
        if let first = firstEntry {
            #expect(first.timeIntervalSince1970.isApproximatelyEqual(to: 10.0))
        }
        
        // Second entry should be 5 seconds later
        let secondEntry = iterator.next()
        #expect(secondEntry != nil)
        if let second = secondEntry {
            #expect(second.timeIntervalSince1970.isApproximatelyEqual(to: 15.0))
        }
        
        // Third entry should be 5 seconds later
        let thirdEntry = iterator.next()
        #expect(thirdEntry != nil)
        if let third = thirdEntry {
            #expect(third.timeIntervalSince1970.isApproximatelyEqual(to: 20.0))
        }
    }
    
    @Test
    func everyMinuteTimelineScheduleEntries() {
        let calendar = Calendar.current
        let startDate = Date()
        
        let schedule = EveryMinuteTimelineSchedule()
        let entries = schedule.entries(from: startDate, mode: TimelineScheduleMode.normal)
        
        var iterator = entries.makeIterator()
        
        // First entry should be at the current or next minute boundary
        let firstEntry = iterator.next()
        #expect(firstEntry != nil)
        
        if let first = firstEntry {
            let components = calendar.dateComponents([.second, .nanosecond], from: first)
            #expect(components.second == 0)
            #expect(components.nanosecond == 0)
            
            // Should be within the current minute or the next minute
            let timeDiff = first.timeIntervalSince(startDate)
            #expect(timeDiff >= -60 && timeDiff < 60)
        }
        
        // Second entry should be exactly one minute later
        let secondEntry = iterator.next()
        #expect(secondEntry != nil)
        
        if let first = firstEntry, let second = secondEntry {
            let diff = second.timeIntervalSince(first)
            #expect(diff.isApproximatelyEqual(to: 60.0))
            
            let components = calendar.dateComponents([.second, .nanosecond], from: second)
            #expect(components.second == 0)
            #expect(components.nanosecond == 0)
        }
        
        // Third entry should be exactly one minute after the second
        let thirdEntry = iterator.next()
        #expect(thirdEntry != nil)
        
        if let second = secondEntry, let third = thirdEntry {
            let diff = third.timeIntervalSince(second)
            #expect(diff.isApproximatelyEqual(to: 60.0))
            
            let components = calendar.dateComponents([.second, .nanosecond], from: third)
            #expect(components.second == 0)
            #expect(components.nanosecond == 0)
        }
    }
    
    @Test
    func explicitTimelineScheduleEntries() {
        let dates = [
            Date(timeIntervalSince1970: 100),
            Date(timeIntervalSince1970: 200),
            Date(timeIntervalSince1970: 300)
        ]
        
        let schedule = ExplicitTimelineSchedule(dates)
        let entries = schedule.entries(from: Date(timeIntervalSince1970: 0), mode: TimelineScheduleMode.normal)
        
        var iterator = entries.makeIterator()
        
        let first = iterator.next()
        #expect(first?.timeIntervalSince1970.isApproximatelyEqual(to: 100) ?? false)
        
        let second = iterator.next()
        #expect(second?.timeIntervalSince1970.isApproximatelyEqual(to: 200) ?? false)
        
        let third = iterator.next()
        #expect(third?.timeIntervalSince1970.isApproximatelyEqual(to: 300) ?? false)
        
        let fourth = iterator.next()
        #expect(fourth == nil)
    }
    
    @Test
    func periodicTimelineScheduleWithPastStartDate() {
        let startDate = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 10.0
        
        let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
        let queryDate = Date(timeIntervalSince1970: 25)
        let entries = schedule.entries(from: queryDate, mode: TimelineScheduleMode.normal)
        
        var iterator = entries.makeIterator()
        
        // Should align to the most recent 10-second boundary (20)
        let firstEntry = iterator.next()
        #expect(firstEntry != nil)
        if let first = firstEntry {
            #expect(first.timeIntervalSince1970.isApproximatelyEqual(to: 20.0))
        }
        
        // Next should be at 30
        let secondEntry = iterator.next()
        #expect(secondEntry != nil)
        if let second = secondEntry {
            #expect(second.timeIntervalSince1970.isApproximatelyEqual(to: 30.0))
        }
    }
    
    @Test
    func periodicTimelineScheduleAlignedStart() {
        let startDate = Date(timeIntervalSince1970: 0)
        let interval: TimeInterval = 5.0
        
        let schedule = PeriodicTimelineSchedule(from: startDate, by: interval)
        // Query date is exactly on a boundary
        let queryDate = Date(timeIntervalSince1970: 15)
        let entries = schedule.entries(from: queryDate, mode: TimelineScheduleMode.normal)
        
        var iterator = entries.makeIterator()
        
        // First entry should be at the query date itself
        let firstEntry = iterator.next()
        #expect(firstEntry != nil)
        if let first = firstEntry {
            #expect(first.timeIntervalSince1970.isApproximatelyEqual(to: 15.0))
        }
        
        // Next should be at 20
        let secondEntry = iterator.next()
        #expect(secondEntry != nil)
        if let second = secondEntry {
            #expect(second.timeIntervalSince1970.isApproximatelyEqual(to: 20.0))
        }
    }
}
