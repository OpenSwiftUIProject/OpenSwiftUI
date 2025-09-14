//
//  DateSequenceTimeline.swift
//  OpenSwiftUI
//
//  Audit for 6.5.4
//  Status: Complete
//  ID: 4A16DECB179482C36B65AC864E5087D (SwiftUI?)

#if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES

import BacklightServices
import OpenAttributeGraphShims

// MARK: - DateSequenceTimeline

class DateSequenceTimeline: BLSAlwaysOnTimeline {
    var schedule: any TimelineSchedule

    init(identifier: TimelineIdentifier, schedule: any TimelineSchedule) {
        self.schedule = schedule
        super.init(identifier: identifier, configure: nil)
    }

    override func requestedFidelityForStartEntry(
        in interval: DateInterval,
        withPreviousEntry entry: BLSAlwaysOnTimelineEntry?
    ) -> BLSUpdateFidelity {
        if let entry {
            return entry.requestedFidelity
        } else {
            let entries = schedule.lazyEntries(
                with: interval.start ..< .distantFuture,
                mode: .lowFrequency,
                limit: .minimumTimelineScheduleLimit
            )
            let iterator = entries.makeIterator()
            guard let current = iterator.next(), let next = iterator.next() else {
                return .unspecified
            }
            return estimatedFidelity(forPresentationTime: current, nextPresentationTime: next)
        }
    }

    override func unconfiguredEntries(
        for interval: DateInterval,
        previousEntry entry: BLSAlwaysOnTimelineEntry?
    ) -> [BLSAlwaysOnTimelineUnconfiguredEntry]? {
        let clampedLimit = UInt((interval.duration * 4).clamp(min: -1, max: Double(UInt.max)))
        let limit = max(.minimumTimelineScheduleLimit, clampedLimit)
        let dates = schedule.entries(
            within: interval,
            mode: .lowFrequency,
            limit: limit
        )
        guard !dates.isEmpty else {
            return []
        }
        var unconfiguredEntries: [BLSAlwaysOnTimelineUnconfiguredEntry] = []
        unconfiguredEntries.reserveCapacity(dates.count)
        for date in dates {
            let unconfiguredEntry = BLSAlwaysOnTimelineUnconfiguredEntry(
                forPresentationTime: date,
                withRequestedFidelity: .unspecified
            )
            unconfiguredEntries.append(unconfiguredEntry)
        }

        return unconfiguredEntries
    }

    static func == (lhs: DateSequenceTimeline, rhs: DateSequenceTimeline) -> Bool {
        func areEqual<T>(_ a: T, _ b: Any) -> Bool where T: Equatable {
            guard let b = b as? T else {
                return false
            }
            return a == b
        }
        guard let equatable = lhs.schedule as? any Equatable else {
            return lhs === rhs
        }
        return areEqual(equatable, rhs.schedule)
    }
}

// MARK: - TimelineView.Context + invalidate

@available(OpenSwiftUI_v4_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension TimelineView.Context {

    /// Resets any pre-rendered views the system has from the timeline.
    ///
    /// When entering Always On Display, the system might pre-render frames. If the
    /// content of these frames must change in a way that isn't reflected by
    /// the schedule or the timeline view's current bindings --- for example, because
    /// the user changes the title of a future calendar event --- call this method to
    /// request that the frames be regenerated.
    public func invalidateTimelineContent() {
        guard let bridge = invalidationAction.bridge else {
            return
        }
        bridge.invalidate(for: "Explicit timeline invalidation")
    }
}

// MARK: - TimelineIdentifier

@objc
class TimelineIdentifier: NSObject, NSCopying {
    private let identifier: UniqueID

    override init() {
        identifier = .init()
        super.init()
    }

    init(identifier: UniqueID) {
        self.identifier = identifier
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object, let other = object as? Self else {
            return false
        }
        return identifier == other.identifier
    }

    func copy(with zone: NSZone? = nil) -> Any {
        self
    }
}

// MARK: - UpdateFidelityKey

private struct UpdateFidelityKey: EnvironmentKey {
    static var defaultValue: BLSUpdateFidelity = .seconds
}

extension CachedEnvironment.ID {
    static let updateFidelity: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var updateFidelity: Attribute<BLSUpdateFidelity> {
        mapEnvironment(id: .updateFidelity) { $0[UpdateFidelityKey.self] }
    }
}

// MARK: - TimelineView.AlwaysOnTimelinePreferenceWriter

extension TimelineView where Content: View {
    struct AlwaysOnTimelinePreferenceWriter: Rule {
        var id: TimelineIdentifier
        @Attribute var schedule: Schedule

        var value: (inout [DateSequenceTimeline]) -> () {
            let timeline = DateSequenceTimeline(identifier: id, schedule: schedule)
            return { timelines in
                timelines.append(timeline)
            }
        }
    }
}
#endif
