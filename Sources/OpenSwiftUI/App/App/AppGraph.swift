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

    @OptionalAttribute
    var rootSceneList: SceneList?

    @Attribute
    var primarySceneSummaries: [SceneList.Item.Summary]

    @Attribute
    var focusedValues: FocusedValues

    @Attribute
    var focusStore: FocusStore

    @Attribute
    var sceneKeyboardShortcuts: [SceneID: KeyboardShortcut]

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
    private var rootCommandsList: CommandsList?

    init<Application>(app: Application) where Application: App {
        makeRootScene = { inputs in
            let fields = DynamicPropertyCache.fields(of: Application.self)
            var inputs = inputs
            let accessor = AppBodyAccessor<Application>()
            let (body, _) = accessor.makeBody(
                container: .init(Attribute(value: app)),
                inputs: &inputs.base,
                fields: fields
            )
            return Application.Body._makeScene(
                scene: body,
                inputs: inputs
            )
        }
        let data = GraphHost.Data()
        let oldSubgraph = Subgraph.current
        Subgraph.current = data.globalSubgraph
        _rootScenePhase = Attribute(value: .background)
        _primarySceneSummaries = Attribute(value: [])
        _focusedValues = Attribute(value: .init())
        _focusStore = Attribute(value: .init())
        _sceneKeyboardShortcuts = Attribute(value: [:])
        super.init(data: data)
        Subgraph.current = oldSubgraph
    }

    // MARK: - Override Methods

    override package func instantiateOutputs() {
        data.updateSeed &+= 1
        let outputs = rootSubgraph.apply {
            var inputs = _SceneInputs(
                base: graphInputs,
                preferences: .init(hostKeys: data.$hostPreferenceKeys)
            )
            inputs.base.environment = Attribute(
                RootEnvironment(
                    environment: graphInputs.environment,
                    phase: $rootScenePhase,
                    sceneKeyboardShorts: $sceneKeyboardShortcuts
                )
            )
            inputs.preferences.add(HostPreferencesKey.self)
            inputs.preferences.add(SceneList.Key.self)
            inputs.preferences.add(CommandsList.Key.self)
            inputs.base.focusedValues = $focusedValues
            inputs.base.focusStore = $focusStore
            return makeRootScene(inputs)
        }
        $rootSceneList = outputs.preferences.sceneList
        $rootCommandsList = outputs.preferences.commandsList
        hostPreferenceValues = WeakAttribute(outputs.preferences.hostPreferenceValues)
    }

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
            let items = rootCommandsList?.items ?? []
            for item in items {
                guard case let .flag(f) = item.value,
                      f == flag
                else {
                    continue
                }
                return true
            }
            return false
        }
    }
}

// MARK: - AppGraphObserver

protocol AppGraphObserver: AnyObject {
    func scenesDidChange(phaseChanged: Bool)
    func commandsDidChange()
}

// MARK: - AppBodyAccessor

private struct AppBodyAccessor<Application>: BodyAccessor where Application: App {
    typealias Container = Application

    typealias Body = Application.Body

    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body
        }
    }
}

// MARK: - RootEnvironment

private struct RootEnvironment: Rule {
    @Attribute var environment: EnvironmentValues
    @Attribute var phase: ScenePhase
    @Attribute var sceneKeyboardShorts: [SceneID: KeyboardShortcut]

    var value: EnvironmentValues {
        environment
    }
}
