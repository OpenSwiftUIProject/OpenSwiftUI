//
//  AppKitAppDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: CD9513E1DBF2FF41775224EE6D5A7974 (SwiftUI)

#if os(macOS)
import AppKit

class AppDelegate: NSResponder, NSApplicationDelegate {
    var graph: AppGraph
//    var windowsController: AppWindowsController
    private var sceneListVersion: DisplayList.Version = .init()
    private var commandsListVersion: DisplayList.Version = .init()
    private var appDelegate: NSApplicationDelegate? = nil
//    private var menuBarExtrasController: AppMenuBarExtrasController = .init()
//    private var dialogController: AppModalDialogsController = .init()
//    private var badgeSeed: VersionSeedTracker<BadgePreferenceKey> = .init(.invalid)
    var isFinishedLaunching: Bool = false
    var shouldPresentInitialWindowOnLauncher: Bool = true

    init(appGraph: AppGraph) {
        graph = appGraph
        // windowsController
        // SceneNavigationStrategy_Mac.shared
        let delegate: NSApplicationDelegate?
        if let box = AppGraph.delegateBox,
           let appDelegate = box.delegate as? NSApplicationDelegate {
            delegate = appDelegate
        } else {
            delegate = nil
        }
        appDelegate = delegate
        NSMenu._setAlwaysCallDelegateBeforeSidebandUpdaters(true)
        NSMenu._setAlwaysInstallWindowTabItems(true)
        NSDocumentController._setUsingModernDocuments(true)
        super.init()
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Decoding not supported")
    }

    override func responds(to aSelector: Selector!) -> Bool {
        let canDelegateRespond = appDelegate?.responds(to: aSelector) ?? false
        let canSelfRespond = AppDelegate.instancesRespond(to: aSelector)
        return canDelegateRespond || canSelfRespond
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        appDelegate
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        Update.begin()
        defer { Update.end() }
        // FIXME
        let items = AppGraph.shared?.rootSceneList?.items ?? []
        let view = items[0].value.view
        let hostingVC = NSHostingController(rootView: view.frame(width: 500, height: 300).rootEnvironment())
        let windowVC = WindowController(hostingVC)
        windowVC.showWindow(nil)
        self.windowVC = windowVC
    }
    
    var windowVC: NSWindowController?
}

// MARK: - App Utils

func currentAppName() -> String {
    if let name = Bundle.main.localizedValue(for: "CFBundleDisplayName") {
        return name
    } else if let name = Bundle.main.localizedValue(for: "CFBundleName") {
        return name
    } else {
        return ProcessInfo.processInfo.processName
    }
}

extension Bundle {
    fileprivate func localizedValue(for key: String) -> String? {
        if let localizedInfoDictionary,
           let value = localizedInfoDictionary[key] as? String {
            return value
        } else if let infoDictionary,
                  let value = infoDictionary[key] as? String {
            return value
        } else {
            return nil
        }
    }
}

#endif
