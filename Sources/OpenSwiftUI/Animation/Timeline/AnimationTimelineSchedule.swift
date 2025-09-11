//
//  AnimationTimelineSchedule.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

@available(OpenSwiftUI_v3_0, *)
extension TimelineSchedule where Self == AnimationTimelineSchedule {

    /// A pausable schedule of dates updating at a frequency no more quickly
    /// than the provided interval.
    @_alwaysEmitIntoClient
    public static var animation: AnimationTimelineSchedule {
        .init()
    }

    /// A pausable schedule of dates updating at a frequency no more quickly
    /// than the provided interval.
    ///
    /// - Parameters:
    ///     - minimumInterval: The minimum interval to update the schedule at.
    ///     Pass nil to let the system pick an appropriate update interval.
    ///     - paused: If the schedule should stop generating updates.
    @_alwaysEmitIntoClient
    public static func animation(
        minimumInterval: Double? = nil,
        paused: Bool = false
    ) -> AnimationTimelineSchedule {
        .init(minimumInterval: minimumInterval, paused: paused)
    }
}

/// A pausable schedule of dates updating at a frequency no more quickly than
/// the provided interval.
///
/// You can also use ``TimelineSchedule/animation(minimumInterval:paused:)`` to
/// construct this schedule.
@available(OpenSwiftUI_v3_0, *)
public struct AnimationTimelineSchedule: TimelineSchedule, Sendable {

    private var minimumInterval: Double

    private var paused: Bool

    /// Create a pausable schedule of dates updating at a frequency no more
    /// quickly than the provided interval.
    ///
    /// - Parameters:
    ///     - minimumInterval: The minimum interval to update the schedule at.
    ///     Pass nil to let the system pick an appropriate update interval.
    ///     - paused: If the schedule should stop generating updates.
    public init(minimumInterval: Double? = nil, paused: Bool = false) {
        self.minimumInterval = minimumInterval ?? (1.0 / 120.0)
        self.paused = paused
    }

    /// Returns entries at the frequency of the animation schedule.
    ///
    /// When in `.lowFrequency` mode, return no entries, effectively pausing the animation.
    public func entries(from start: Date, mode: TimelineScheduleMode) -> AnimationTimelineSchedule.Entries {
        Entries(date: start, interval: (paused || mode == .lowFrequency) ? nil : minimumInterval)
    }

    public struct Entries: Sequence, IteratorProtocol, Sendable {
        private var date: Date

        private var interval: Double?

        init(date: Date, interval: Double? = nil) {
            self.date = date
            self.interval = interval
        }

        public mutating func next() -> Date? {
            guard let interval else {
                return nil
            }
            defer { date += interval }
            return date
        }
    }
}
