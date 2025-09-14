//
//  TimelineSchedule.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 060A68BF8978E18F3139FB308E31B823

public import Foundation

// MARK: - TimelineSchedule

/// A type that provides a sequence of dates for use as a schedule.
///
/// Types that conform to this protocol implement a particular kind of schedule
/// by defining an ``TimelineSchedule/entries(from:mode:)`` method that returns
/// a sequence of dates. Use a timeline schedule type when you initialize
/// a ``TimelineView``. For example, you can create a timeline view that
/// updates every second, starting from some `startDate`, using a
/// periodic schedule returned by ``TimelineSchedule/periodic(from:by:)``:
///
///     TimelineView(.periodic(from: startDate, by: 1.0)) { context in
///         // View content goes here.
///     }
///
/// You can also create custom timeline schedules.
/// The timeline view updates its content according to the
/// sequence of dates produced by the schedule.
@available(OpenSwiftUI_v3_0, *)
public protocol TimelineSchedule {

    /// An alias for the timeline schedule update mode.
    typealias Mode = TimelineScheduleMode

    /// The sequence of dates within a schedule.
    ///
    /// The ``TimelineSchedule/entries(from:mode:)`` method returns a value
    /// of this type, which is a
    /// [Sequence](https://developer.apple.com/documentation/swift/sequence)
    /// of dates in ascending order. A ``TimelineView`` that you create with a
    /// schedule updates its content at the moments in time corresponding to
    /// the dates included in the sequence.
    associatedtype Entries: Sequence where Self.Entries.Element == Date

    /// Provides a sequence of dates starting around a given date.
    ///
    /// A ``TimelineView`` that you create calls this method to figure out
    /// when to update its content. The method returns a sequence of dates in
    /// increasing order that represent points in time when the timeline view
    /// should update. Types that conform to the ``TimelineSchedule`` protocol,
    /// like the one returned by ``TimelineSchedule/periodic(from:by:)``, or a custom schedule that
    /// you define, implement a custom version of this method to implement a
    /// particular kind of schedule.
    ///
    /// One or more dates in the sequence might be before the given
    /// `startDate`, in which case the timeline view performs its first
    /// update at `startDate` using the entry that most closely precedes
    /// that date. For example, if in response to a `startDate` of
    /// `10:09:55`, the method returns a sequence with the values `10:09:00`,
    /// `10:10:00`, `10:11:00`, and so on, the timeline view performs an initial
    /// update at `10:09:55` (using the `10:09:00` entry), followed by another
    /// update at the beginning of every minute, starting at `10:10:00`.
    ///
    /// A type that conforms should adjust its behavior based on the `mode` when
    /// possible. For example, a periodic schedule providing updates
    /// for a timer could restrict updates to once per minute while in the
    /// ``TimelineScheduleMode/lowFrequency`` mode:
    ///
    ///     func entries(
    ///         from startDate: Date, mode: TimelineScheduleMode
    ///     ) -> PeriodicTimelineSchedule {
    ///         .periodic(
    ///             from: startDate, by: (mode == .lowFrequency ? 60.0 : 1.0)
    ///         )
    ///     }
    ///
    /// - Parameters:
    ///   - startDate: The date by which the sequence begins.
    ///   - mode: An indication of whether the schedule updates normally,
    ///     or with some other cadence.
    /// - Returns: A sequence of dates in ascending order.
    func entries(from startDate: Date, mode: Self.Mode) -> Self.Entries
}

// MARK: - TimelineScheduleMode

/// A mode of operation for timeline schedule updates.
///
/// A ``TimelineView`` provides a mode when calling its schedule's
/// ``TimelineSchedule/entries(from:mode:)`` method.
/// The view chooses a mode based on the state of the system.
/// For example, a watchOS view might request a lower frequency
/// of updates, using the ``lowFrequency`` mode, when the user
/// lowers their wrist.
@available(OpenSwiftUI_v3_0, *)
public enum TimelineScheduleMode: Sendable {

    /// A mode that produces schedule updates at the schedule's natural cadence.
    case normal

    /// A mode that produces schedule updates at a reduced rate.
    ///
    /// In this mode, the schedule should generate only
    /// "major" updates, if possible. For example, a timeline providing
    /// updates to a timer might restrict updates to once a minute while in
    /// this mode.
    case lowFrequency
}

// MARK: - TimelineSchedule + lazyEntries [WIP]

extension UInt {
    package static var minimumTimelineScheduleLimit: UInt { 60 }
}

extension TimelineSchedule {
    package func entries(
        within interval: DateInterval,
        mode: TimelineScheduleMode,
        limit: UInt?
    ) -> [Date] {
        return []
//        AnySequence(entries(within: range, mode: mode, limit: limit))
    }

    package func lazyEntries(
        with range: Range<Date>,
        mode: TimelineScheduleMode = .normal,
        limit: UInt?
    ) -> AnySequence<Date> {
        AnySequence(entries(within: range, mode: mode, limit: limit))
    }

    private func entries(within range: Range<Date>, mode: TimelineScheduleMode, limit: UInt?) -> [Date] {
        // FIXME
        var dates: [Date] = []
        var count: UInt = 0
        let maxCount = limit ?? UInt.max

        for date in entries(from: range.lowerBound, mode: mode) {
            guard date < range.upperBound else { break }
            dates.append(date)
            count += 1
            if count >= maxCount { break }
        }

        return dates
    }
}

extension LazySequenceProtocol where Element == Date {
    private func abort(after: UInt?) -> LazyPrefixWhileSequence<Elements> {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - Concreate TimelineSchedule Types

@available(OpenSwiftUI_v3_0, *)
extension TimelineSchedule where Self == PeriodicTimelineSchedule {

    /// A schedule for updating a timeline view at regular intervals.
    ///
    /// Initialize a ``TimelineView`` with a periodic timeline schedule when
    /// you want to schedule timeline view updates periodically with a custom
    /// interval:
    ///
    ///     TimelineView(.periodic(from: startDate, by: 3.0)) { context in
    ///         Text(context.date.description)
    ///     }
    ///
    /// The timeline view updates its content at the start date, and then
    /// again at dates separated in time by the interval amount, which is every
    /// three seconds in the example above. For a start date in the
    /// past, the view updates immediately, providing as context the date
    /// corresponding to the most recent interval boundary. The view then
    /// refreshes normally at subsequent interval boundaries. For a start date
    /// in the future, the view updates once with the current date, and then
    /// begins regular updates at the start date.
    ///
    /// The schedule defines the ``PeriodicTimelineSchedule/Entries``
    /// structure to return the sequence of dates when the timeline view calls
    /// the ``PeriodicTimelineSchedule/entries(from:mode:)`` method.
    ///
    /// - Parameters:
    ///   - startDate: The date on which to start the sequence.
    ///   - interval: The time interval between successive sequence entries.
    @_alwaysEmitIntoClient
    public static func periodic(
        from startDate: Date,
        by interval: TimeInterval
    ) -> PeriodicTimelineSchedule {
        .init(from: startDate, by: interval)
    }
}

@available(OpenSwiftUI_v3_0, *)
extension TimelineSchedule where Self == EveryMinuteTimelineSchedule {

    /// A schedule for updating a timeline view at the start of every minute.
    ///
    /// Initialize a ``TimelineView`` with an every minute timeline schedule
    /// when you want to schedule timeline view updates at the start of every
    /// minute:
    ///
    ///     TimelineView(.everyMinute) { context in
    ///         Text(context.date.description)
    ///     }
    ///
    /// The schedule provides the first date as the beginning of the minute in
    /// which you use it to initialize the timeline view. For example, if you
    /// create the timeline view at `10:09:38`, the schedule's first entry is
    /// `10:09:00`. In response, the timeline view performs its first update
    /// immediately, providing the beginning of the current minute, namely
    /// `10:09:00`, as context to its content. Subsequent updates happen at the
    /// beginning of each minute that follows.
    ///
    /// The schedule defines the ``EveryMinuteTimelineSchedule/Entries``
    /// structure to return the sequence of dates when the timeline view calls
    /// the ``EveryMinuteTimelineSchedule/entries(from:mode:)`` method.
    @_alwaysEmitIntoClient
    public static var everyMinute: EveryMinuteTimelineSchedule {
        .init()
    }
}

@available(OpenSwiftUI_v3_0, *)
extension TimelineSchedule {

    /// A schedule for updating a timeline view at explicit points in time.
    ///
    /// Initialize a ``TimelineView`` with an explicit timeline schedule when
    /// you want to schedule view updates at particular points in time:
    ///
    ///     let dates = [
    ///         Date(timeIntervalSinceNow: 10), // Update ten seconds from now,
    ///         Date(timeIntervalSinceNow: 12) // and a few seconds later.
    ///     ]
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             TimelineView(.explicit(dates)) { context in
    ///                 Text(context.date.description)
    ///             }
    ///         }
    ///     }
    ///
    /// The timeline view updates its content on exactly the dates that
    /// you specify, until it runs out of dates, after which it stops changing.
    /// If the dates you provide are in the past, the timeline view updates
    /// exactly once with the last entry. If you only provide dates in the
    /// future, the timeline view renders with the current date until the first
    /// date arrives. If you provide one or more dates in the past and one or
    /// more in the future, the view renders the most recent past date,
    /// refreshing normally on all subsequent dates.
    ///
    /// - Parameter dates: The sequence of dates at which a timeline view
    ///   updates. Use a monotonically increasing sequence of dates,
    ///   and ensure that at least one is in the future.
    @_alwaysEmitIntoClient
    public static func explicit<S>(_ dates: S) -> ExplicitTimelineSchedule<S> where Self == ExplicitTimelineSchedule<S>, S: Sequence, S.Element == Date {
        .init(dates)
    }
}

/// A schedule for updating a timeline view at regular intervals.
///
/// You can also use ``TimelineSchedule/periodic(from:by:)`` to construct this
/// schedule.
@available(OpenSwiftUI_v3_0, *)
public struct PeriodicTimelineSchedule: TimelineSchedule, Sendable {

    /// The sequence of dates in periodic schedule.
    ///
    /// The ``PeriodicTimelineSchedule/entries(from:mode:)`` method returns
    /// a value of this type, which is a
    /// [Sequence](https://developer.apple.com/documentation/swift/sequence)
    /// of periodic dates in ascending order. A ``TimelineView`` that you
    /// create updates its content at the moments in time corresponding to the
    /// dates included in the sequence.
    public struct Entries: Sequence, IteratorProtocol, Sendable {
        private var date: Date

        private var interval: Double

        init(date: Date, interval: Double) {
            self.date = date
            self.interval = interval
        }

        public mutating func next() -> Date? {
            defer { date = date.addingTimeInterval(interval) }
            return date
        }
    }

    private var date: Date

    private var interval: Double

    /// Creates a periodic update schedule.
    ///
    /// Use the ``PeriodicTimelineSchedule/entries(from:mode:)`` method
    /// to get the sequence of dates.
    ///
    /// - Parameters:
    ///   - startDate: The date on which to start the sequence.
    ///   - interval: The time interval between successive sequence entries.
    public init(from startDate: Date, by interval: TimeInterval) {
        self.date = startDate
        self.interval = interval
    }

    public func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        let timeSinceScheduleStart = startDate.timeIntervalSince(date)
        let remainder = timeSinceScheduleStart.truncatingRemainder(dividingBy: interval)
        let alignedDate = startDate.addingTimeInterval(-remainder)
        return Entries(date: alignedDate, interval: interval)
    }
}

/// A schedule for updating a timeline view at the start of every minute.
///
/// You can also use ``TimelineSchedule/everyMinute`` to construct this
/// schedule.
@available(OpenSwiftUI_v3_0, *)
public struct EveryMinuteTimelineSchedule: TimelineSchedule, Sendable {

    /// The sequence of dates in an every minute schedule.
    ///
    /// The ``EveryMinuteTimelineSchedule/entries(from:mode:)`` method returns
    /// a value of this type, which is a
    /// [sequence](https://developer.apple.com/documentation/swift/sequence)
    /// of dates, one per minute, in ascending order. A ``TimelineView`` that
    /// you create updates its content at the moments in time corresponding to
    /// the dates included in the sequence.
    public struct Entries: Sequence, IteratorProtocol, Sendable {
        private var nextDate: Date?
        
        static let zeroSecondComponents = DateComponents(
            second: .zero,
            nanosecond: .zero
        )

        init(startDate: Date) {
            let calendar = Calendar.current
            if calendar.date(startDate, matchesComponents: Self.zeroSecondComponents) {
                nextDate = startDate
            } else {
                nextDate = calendar.nextDate(
                    after: startDate,
                    matching: Self.zeroSecondComponents,
                    matchingPolicy: .nextTime,
                    direction: .backward
                ) ?? startDate
            }
        }

        public mutating func next() -> Date? {
            guard let nextDate else {
                return nil
            }
            defer {
                self.nextDate = Calendar.current.nextDate(
                    after: nextDate,
                    matching: Self.zeroSecondComponents,
                    matchingPolicy: .nextTime
                )
            }
            return nextDate
        }
    }

    /// Creates a per-minute update schedule.
    ///
    /// Use the ``EveryMinuteTimelineSchedule/entries(from:mode:)`` method
    /// to get the sequence of dates.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func entries(from startDate: Date, mode: TimelineScheduleMode) -> EveryMinuteTimelineSchedule.Entries {
        Entries(startDate: startDate)
    }
}

/// A schedule for updating a timeline view at explicit points in time.
///
/// You can also use ``TimelineSchedule/explicit(_:)`` to construct this
/// schedule.
@available(OpenSwiftUI_v3_0, *)
public struct ExplicitTimelineSchedule<Entries>: TimelineSchedule where Entries: Sequence, Entries.Element == Date {

    private var entries: Entries

    /// Creates a schedule composed of an explicit sequence of dates.
    ///
    /// Use the ``ExplicitTimelineSchedule/entries(from:mode:)`` method
    /// to get the sequence of dates.
    ///
    /// - Parameter dates: The sequence of dates at which a timeline view
    ///   updates. Use a monotonically increasing sequence of dates,
    ///   and ensure that at least one is in the future.
    public init(_ dates: Entries) {
        self.entries = dates
    }

    public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
        entries
    }
}
