//
//  UIKitAppDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 4475FD12FD59DEBA453321BD91F6EA04 (SwiftUI)

#if os(iOS) || os(visionOS)
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
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
#endif
