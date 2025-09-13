//
//  AlwaysOnBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: ED1CCB5A10919A16BDE683BBA73F40A5 (SwiftUI)

#if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES

import OpenAttributeGraphShims
@_spi(Private)
import OpenSwiftUICore
import OpenSwiftUI_SPI

class AnyAlwaysOnBridge {
    func invalidate(for: String) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func didRender() {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

//class AlwaysOnBridge<Content>: AnyAlwaysOnBridge where Content: View {
//    weak var hostingController:PlatformHostingController<Content>?
//    private var updatingTraitsCount: UInt64
////  private var frameSpecifier: BLSAnimationFrameSpecifier? From: BacklightServices
//    var isLuminanceReduced: Bool
//    var isUpdatingForFrameSpecifier: Bool
//    var timelineRegistrationsSeed: VersionSeed
//    // var timelineRegistrations: [DateSequenceTimeline]
//}
//

// MARK: AlwaysOnTimelinesKey

struct AlwaysOnTimelinesKey: HostPreferenceKey {
    static let defaultValue: [DateSequenceTimeline] = []

    static func reduce(value: inout [DateSequenceTimeline], nextValue: () -> [DateSequenceTimeline]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - TimelineInvalidationAction

struct TimelineInvalidationAction: Equatable {
    weak var bridge: AnyAlwaysOnBridge?

    static func == (lhs: TimelineInvalidationAction, rhs: TimelineInvalidationAction) -> Bool {
        lhs.bridge === rhs.bridge
    }
}

// MARK: - AlwaysOnFrameSpecifier

private struct AlwaysOnFrameSpecifier: EnvironmentKey {
    static var defaultValue: BLSAlwaysOnFrameSpecifier? { nil }
}

// MARK: - AlwaysOnInvalidationKey

private struct AlwaysOnInvalidationKey: EnvironmentKey {
    static let defaultValue: TimelineInvalidationAction = .init()
}

// MARK: - OpenSwiftUITextAlwaysOnProvider

struct OpenSwiftUITextAlwaysOnProvider: TextAlwaysOnProvider {
    static func makeAlwaysOn(
        inputs: _ViewInputs,
        schedule: @autoclosure () -> Attribute<(any TimelineSchedule)?>,
        outputs: inout _ViewOutputs
    ) {

        guard _UIAlwaysOnEnvironment._alwaysOnSupported else {
            return
        }
        outputs.preferences.makePreferenceWriter(
            inputs: inputs.preferences,
            key: AlwaysOnTimelinesKey.self,
            value: Attribute(AlwaysOnTimelinePreferenceWriter(id: .init(), schedule: schedule()))
        )
    }
}

// MARK: - AlwaysOnTimelinePreferenceWriter

struct AlwaysOnTimelinePreferenceWriter: Rule {
    var id: TimelineIdentifier
    @Attribute var schedule: (any TimelineSchedule)?

    var value: [DateSequenceTimeline] {
        guard let schedule else {
            return []
        }
        return [DateSequenceTimeline(identifier: id, schedule: schedule)]
    }
}

// FIXME: BLSAlwaysOnFrameSpecifier

class BLSAlwaysOnFrameSpecifier {}

#endif
