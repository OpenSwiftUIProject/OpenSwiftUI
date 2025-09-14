//
//  DateSequenceTimeline.swift
//  OpenSwiftUI
//
//  Audit for 6.5.4
//  Status: WIP
//  ID: 4A16DECB179482C36B65AC864E5087D (SwiftUI?)

#if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES

import BacklightServices
import OpenAttributeGraphShims

// MARK: - DateSequenceTimeline [WIP]

class DateSequenceTimeline: BLSAlwaysOnTimeline {
    var schedule: any TimelineSchedule

    init(identifier: TimelineIdentifier, schedule: any TimelineSchedule) {
        self.schedule = schedule
        super.init(identifier: identifier, configure: nil)
    }


    override func requestedFidelityForStartEntry(inDateInterval interval: Any, withPreviousEntry entry: Any) -> BLSUpdateFidelity {
        // TODO
        .milliseconds
    }

    override func unconfiguredEntries(forDateInterval interval: Any, previousEntry entry: Any) -> Any {
        // TODO
        return [0]
    }

    static func == (lhs: DateSequenceTimeline, rhs: DateSequenceTimeline) -> Bool {
        func areEqual<T>(_ a: T, _ b: Any) -> Bool where T: Equatable {
            guard let b = b as? T else {
                return false
            }
            return a == b
        }
        // TODO
        return false
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
class TimelineIdentifier: NSObject {
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
