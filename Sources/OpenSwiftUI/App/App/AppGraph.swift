//
//  AppGraph.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A363922CEBDF47986D9772B903C8737A (SwiftUI)

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) package import OpenSwiftUICore

package final class AppGraph: GraphHost {
    static var shared: AppGraph? = nil {
        willSet {
            precondition(shared == nil, "AppGraph.shared may only be set once!")
        }
    }

    static var delegateBox: AnyFallbackDelegateBox? = nil

    private var makeRootScene: (_SceneInputs) -> _SceneOutputs

    private var observers: Set<HashableWeakBox<AnyObject>> = .init()

    @Attribute
    var rootScenePhase: ScenePhase

//    @OptionalAttribute
//    var rootSceneList: SceneList??
//
//    @Attribute
//    var primarySceneSummaries: [SceneList.Item.Summary]
//
//    @Attribute
//    var focusedValues: FocusedValues
//
//    @Attribute
//    var focusStore: FocusStore

//    @Attribute
//    var sceneKeyboardShortcuts: [SceneID: KeyboardShortcut]

    private struct LaunchProfileOptions: OptionSet {
        let rawValue: Int32

        static var trace: LaunchProfileOptions { .init(rawValue: 1 << 0) }

        static var profile: LaunchProfileOptions { .init(rawValue: 1 << 1) }
    }

    private lazy var launchProfileOptions = LaunchProfileOptions(
        rawValue: EnvironmentHelper.int32(for: "OPENSWIFTUI_PROFILE_LAUNCH") ?? 0
    )

    private lazy var traceLaunch: Bool = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_TRACE_LAUNCH")

    private var didCollectLaunchProfile: Bool = false

    @OptionalAttribute
    var rootCommandsList: CommandsList?

    // TODO
    init(app: some App) {
        let data = GraphHost.Data()
        _openSwiftUIUnimplementedFailure()
        super.init(data: data)
    }

    // MARK: - Override Methods

    // MARK: - Profile related

    func startProfilingIfNecessary() {
        guard !didCollectLaunchProfile else {
            return
        }
        if traceLaunch {
            Graph.startTracing(options: nil)
        } else if launchProfileOptions.contains(.profile) {
            Graph.startProfiling()
        }
    }

    func stopProfilingIfNecessary() {
        guard !didCollectLaunchProfile else {
            return
        }
        didCollectLaunchProfile = true
        if traceLaunch {
            Graph.stopTracing()
        } else {
            if launchProfileOptions.contains(.profile) {
                Graph.stopProfiling()
            }
            if !launchProfileOptions.isEmpty {
                // /tmp/graph.ag-gzon
                Graph.archiveJSON(name: nil)
            }
        }
    }
}

extension AppGraph {
    func supports(_ flag: CommandFlag) -> Bool {
        Update.ensure {
            // TODO
            false
        }
    }
}

// MARK: - AppGraphObserver

protocol AppGraphObserver: AnyObject {
    func sceneDidChange(phaseChanged: Bool)
    func commandsDidChange()
}

// MARK: - AppBodyAccessor

private struct AppBodyAccessor<Container: App>: BodyAccessor {
    typealias Body = Container.Body

    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body
        }
    }
}
