//
//  AlwaysOnBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: ED1CCB5A10919A16BDE683BBA73F40A5 (SwiftUI)

#if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
import OpenSwiftUI_SPI

// MARK: - AnyAlwaysOnBridge

class AnyAlwaysOnBridge {
    func invalidate(for reason: String) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func didRender() {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: AlwaysOnBridge [WIP]

final class AlwaysOnBridge<Content>: AnyAlwaysOnBridge where Content: View {
    weak var hostingController:PlatformHostingController<Content>?

    private var updatingTraitsCount: UInt64 = .zero

    private var frameSpecifier: BLSAlwaysOnFrameSpecifier? = nil

    var isLuminanceReduced: Bool = false

    var isUpdatingForFrameSpecifier: Bool = false

    var timelineRegistrationsSeed: VersionSeed = .empty

    var timelineRegistrations: [DateSequenceTimeline] = [] {
        didSet {
            // TODO
            invalidate(for: "Timeline registrations changed.")
        }
    }

    func configureTransaction(_ transaction: inout Transaction) {
        updatingTraitsCount &+= 1
        transaction.addAnimationListener {
            DispatchQueue.main.async {
                self.updatingTraitsCount &-= 1
            }
        }
    }

    func hostingControllerWillDisappear() {
        guard frameSpecifier != nil else { return }
        frameSpecifier = nil
        hostingController!.host.invalidateProperties(.environment)
    }

    override func invalidate(for reason: String) {
        let host = hostingController!.host
        guard let window = host.window,
              let scene = window.windowScene,
              let backlightSceneEnvironment = scene._backlightSceneEnvironment
        else { return }
        backlightSceneEnvironment.invalidateAllTimelines(forReason: reason)
    }

    var isActiveHost: Bool {
        let host = hostingController!.host
        guard let window = host.window,
              let scene = window.windowScene
        else { return false }
        var controllers: [any UIViewController & _UIBacklightEnvironmentObserver] = []
        for window in scene.windows {
            controllers.append(contentsOf: window.rootViewController?._effectiveControllersForAlwaysOnTimelines ?? [])
        }
        return controllers.contains { $0 === hostingController }
    }

    func preferencesDidChange(_ preference: PreferenceValues) {
        let value = preference[AlwaysOnTimelinesKey.self]
        guard !value.seed.matches(timelineRegistrationsSeed) else {
            return
        }
        timelineRegistrationsSeed = value.seed
        timelineRegistrations = value.value
    }

    func timelines(for _: DateInterval) -> [BLSAlwaysOnTimeline] {
        timelineRegistrations
    }

    func update(environment: inout EnvironmentValues) {
        environment.suppliedBridges.formUnion(.alwaysOnBridge)
        if isActiveHost {
            environment[AlwaysOnFrameSpecifier.self] = frameSpecifier
        }
        environment[AlwaysOnInvalidationKey.self] = .init(bridge: self)
        isLuminanceReduced = environment.isLuminanceReduced
    }

    func update(with specifier: BLSAlwaysOnFrameSpecifier?) {
        isUpdatingForFrameSpecifier = true
        frameSpecifier = specifier
        let viewGraph = hostingController!.host.viewGraph
        var transaction = Transaction()
        transaction.disablesAnimations = true
        transaction.disablesContentTransitions = true
        viewGraph.emptyTransaction(transaction)
        hostingController!.host.invalidateProperties(.environment)
        hostingController!.host.layoutIfNeeded()
    }
}

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

#endif
