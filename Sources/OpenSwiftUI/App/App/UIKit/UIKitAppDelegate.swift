//
//  UIKitAppDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 4475FD12FD59DEBA453321BD91F6EA04 (SwiftUI)

#if os(iOS) || os(visionOS)
import OpenAttributeGraphShims
package import OpenSwiftUICore
public import UIKit
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

// MARK: - AppDelegate [TODO]

final class AppDelegate: UIResponder, UIApplicationDelegate {
    private var fallbackDelegate: UIApplicationDelegate?
    var mainMenuController: UIKitMainMenuController?

    override init() {
        fallbackDelegate = nil
        mainMenuController = nil
        super.init()
        let delegate: UIApplicationDelegate?
        if let box = AppGraph.delegateBox,
           let appDelegate = box.delegate as? UIApplicationDelegate {
            delegate = appDelegate
        } else {
            delegate = nil
        }
        fallbackDelegate = delegate
        // SceneNavigationStrategy_Phone
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        guard let fallbackDelegate,
              let selector = fallbackDelegate.application(_:didFinishLaunchingWithOptions:)
        else { return true }
        return selector(application, launchOptions)
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let items: [SceneList.Item]? = Update.ensure {
            guard let appGraph = AppGraph.shared else {
                return nil
            }
            return appGraph.rootSceneList?.items ?? []
        }
        switch connectingSceneSession.role {
        case .windowApplication:
            let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
            config.delegateClass = AppSceneDelegate.self
            return config
        default:
            _ = items
            // TODO: Handle different roles (carPlay, externalDisplay, etc.)
            _openSwiftUIUnimplementedFailure()
        }
    }

    override func responds(to aSelector: Selector!) -> Bool {
        let canDelegateRespond = fallbackDelegate?.responds(to: aSelector) ?? false
        let canSelfRespond = AppDelegate.instancesRespond(to: aSelector)
        return canDelegateRespond || canSelfRespond
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        fallbackDelegate
    }

    override func buildMenu(with builder: any UIMenuBuilder) {
        Update.perform {
            guard builder.system == UIMenuSystem.main else {
                return
            }
            if mainMenuController == nil {
                mainMenuController = UIKitMainMenuController()
            }
            mainMenuController!.buildMenu(with: builder)
            if let responder = fallbackDelegate as? UIResponder {
                responder.buildMenu(with: builder)
            }
        }
    }

    override func validate(_ command: UICommand) {
        if let mainMenuController {
            mainMenuController.validate(command)
        } else {
            super.validate(command)
        }
        if let responder = fallbackDelegate as? UIResponder {
            responder.validate(command)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if let mainMenuController {
            return mainMenuController.canPerformAction(action, withSender: sender)
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    override func _performMainMenuShortcutKeyCommand(_ keyCommand: UIKeyCommand) {
        if let mainMenuController {
            mainMenuController._performMainMenuShortcutKeyCommand(keyCommand)
        }
    }

    // TODO
}

// MARK: - AppSceneDelegate [Stubbed]

final class AppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private lazy var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    private var sceneItemID: SceneID?
    private var lastVersion: DisplayList.Version = .init()
    private var sceneBridge: SceneBridge?
    private var scenePhase: ScenePhase = .background
    private var sceneDelegateBox: AnyFallbackDelegateBox?
    private var sceneStorageValues: SceneStorageValues?
    private var presentationDataType: Any.Type?
    private var rawPresentationDataValue: Data?
    private var presentationDataValue: AnyHashable?
    private lazy var isDocumentViewControllerRootEnabled: Bool = Semantics.DocumentViewControllerRoot.isEnabled

    override init() {
        super.init()
    }

    override func responds(to aSelector: Selector!) -> Bool {
        let boxResponds = (sceneDelegateBox?.delegate as? any UISceneDelegate)?.responds(to: aSelector) ?? false
        let selfResponds = AppSceneDelegate.instancesRespond(to: aSelector)
        return boxResponds || selfResponds
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard let delegate = (sceneDelegateBox?.delegate as? any UISceneDelegate) else {
            return nil
        }
        return delegate
    }

    // MARK: - hostingView [Stubbed]

    func hostingView<V>(_ view: _UIHostingView<V>, willUpdate: inout EnvironmentValues) {
        _openSwiftUIUnimplementedWarning()
    }

    // MARK: - Test [Stubbed]

    // var pptTestCases: [PPTTestCase.Name] { [] }

    func runTest(_ name: String, options: [AnyHashable: Any]) {
        _openSwiftUIUnimplementedWarning()
    }

    // MARK: - UISceneDelegate [Stubbed]

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        _openSwiftUIUnimplementedWarning()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        _openSwiftUIUnimplementedWarning()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        _openSwiftUIUnimplementedWarning()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        _openSwiftUIUnimplementedWarning()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        _openSwiftUIUnimplementedWarning()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        _openSwiftUIUnimplementedWarning()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        _openSwiftUIUnimplementedWarning()
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        _openSwiftUIUnimplementedWarning()
        return nil
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _openSwiftUIUnimplementedWarning()
    }

    // MARK: - Scene related [Stubbed]

    func sceneItem() -> SceneList.Item {
        _openSwiftUIUnimplementedFailure()
    }

    func sceneDidChange(phaseChange: Bool) {
        _openSwiftUIUnimplementedWarning()
    }

    // MARK: - ConnectionOption [Stubbed]

    var connectionOptionDefinitionTarget: AnyObject? {
        sceneDelegateBox?.delegate
    }

    func handleConnectionOptionDefinition<Definition>(payload: Definition.Payload, definition: Definition.Type, scene: Definition.SceneType) async throws where Definition : UISceneConnectionOptionDefinition {
        _openSwiftUIUnimplementedWarning()
    }

    // MARK: - Document [Stubbed]

    // func makeDocumentIntroView(documentGroups: [IdentifiedDocumentGroupConfiguration], configuration: DocumentIntroductionConfiguration) -> DocumentGroupsIntroRootView
    // func makeConfiguredDocumentRootViewController(_ controller: DocumentViewController) -> UIViewController

    // MARK: - Root view and modifier

    private var rootModifier: RootModifier {
        guard let sceneBridge else {
            preconditionFailure("Application configuration error.")
        }
        guard let sceneStorageValues else {
            preconditionFailure("State restoration error.")
        }
        return RootModifier(
            sceneBridge: sceneBridge,
            sceneDelegateBox: sceneDelegateBox,
            sceneStorageValues: sceneStorageValues,
            presentationDataValue: presentationDataValue,
            scenePhase: scenePhase,
            sceneID: sceneItemID
        )
    }

    private func makeRootView(_ view: AnyView) -> ModifiedContent<AnyView, RootModifier> {
        applyAppRootModifier(view).modifier(rootModifier)
    }
}

// MARK: - RootModifier

struct RootModifier: ViewModifier {
    weak var sceneBridge: SceneBridge?
    weak var sceneDelegateBox: AnyFallbackDelegateBox?
    weak var sceneStorageValues: SceneStorageValues?
    var presentationDataValue: AnyHashable?
    var scenePhase: ScenePhase
    var sceneID: SceneID?
    @Namespace var rootFocusScope

    func body(content: Content) -> some View {
        content
            .rootEnvironment(
                sceneBridge: sceneBridge,
                sceneDelegateBox: sceneDelegateBox,
                sceneStorageValues: sceneStorageValues,
                scenePhase: scenePhase,
                sceneID: sceneID
            )
            .presentedSceneValue(presentationDataValue)
    }
}

// MARK: - EnvironmentValues + sceneSession

private struct SceneSessionKey: EnvironmentKey {
    static let defaultValue: WeakBox<UISceneSession>? = nil
}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension EnvironmentValues {
    public var sceneSession: UISceneSession? {
        get { self[SceneSessionKey.self]?.base }
        set { self[SceneSessionKey.self] = newValue.map(WeakBox.init) }
    }
}

// MARK: - RootEnvironmentModifier

extension View {
    func rootEnvironment(
        sceneBridge: SceneBridge? = nil,
        sceneDelegateBox: AnyFallbackDelegateBox? = nil,
        sceneStorageValues: SceneStorageValues? = nil,
        scenePhase: ScenePhase = .background,
        sceneID: SceneID? = nil
    ) -> some View {
        modifier(RootEnvironmentModifier(
            sceneBridge: sceneBridge,
            sceneDelegateBox: sceneDelegateBox,
            sceneStorageValues: sceneStorageValues,
            scenePhase: scenePhase,
            sceneID: sceneID
        ))
    }
}

private struct RootEnvironmentModifier: PrimitiveViewModifier, _GraphInputsModifier {
    weak var sceneBridge: SceneBridge?
    weak var sceneDelegateBox: AnyFallbackDelegateBox?
    weak var sceneStorageValues: SceneStorageValues?
    var scenePhase: ScenePhase
    var sceneID: SceneID?

    static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        inputs.environment = Attribute(
            Child(
                modifier: modifier.value,
                env: inputs.environment
            )
        )
    }

    struct Child: StatefulRule {
        @Attribute var modifier: RootEnvironmentModifier
        @Attribute var env: EnvironmentValues
        var oldModifier: RootEnvironmentModifier?

        typealias Value = EnvironmentValues

        mutating func updateValue() {
            let (modifier, modifierChanged) = $modifier.changedValue()
            let (environment, environmentChanged) = $env.changedValue()
            let shouldUpdate: Bool
            if environmentChanged {
                shouldUpdate = true
            } else if modifierChanged && oldModifier.map({ compareValues($0, modifier) }) != false {
                shouldUpdate = true
            } else if !hasValue {
                shouldUpdate = true
            } else {
                shouldUpdate = false
            }
            guard shouldUpdate else {
                return
            }
            var result = environment
            result[keyPath: SceneBridge.environmentStore] = modifier.sceneBridge
            result.sceneStorageValues = modifier.sceneStorageValues
            result.scenePhase = modifier.scenePhase
            result.sceneID = modifier.sceneID
            if modifier.scenePhase != .active {
                result.redactionReasons.formUnion(.privacy)
            }
            modifier.sceneDelegateBox?.addDelegate(to: &result)
            AppGraph.delegateBox?.addDelegate(to: &result)
            value = result
            oldModifier = modifier
        }
    }
}
#endif
