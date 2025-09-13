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

// MARK: TimelineIdentifier

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

// MARK: UpdateFidelityKey

private struct UpdateFidelityKey: EnvironmentKey {
    static var defaultValue: BLSUpdateFidelity = .seconds
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
