//
//  AppKitApp.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: CD9513E1DBF2FF41775224EE6D5A7974 (SwiftUI)

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
import AppKit

// MARK: - runApp

func runApp(_ app: some App) -> Never {
    let delegate = Update.dispatchImmediately(reason: nil) {
        let graph = AppGraph(app: app)
        graph.instantiate()
        AppGraph.shared = graph
        return AppDelegate(appGraph: graph)
    }
    runApp(delegate)
}

// MARK: - runTestingApp [WIP]

func runTestingApp<V1, V2>(
    rootView: V1,
    comparisonView: V2,
    didLaunch: @escaping (any TestHost, any TestHost) -> ()
) -> Never where V1: View, V2: View {
    CoreTesting.isRunning = true
    // AppKitApplication.shared
    // FIXME
    // let delegate = TestingAppDelegate(rootView: rootView, comparisonView: comparisonView, didLaunch: didLaunch)
    let delegate = TestingAppDelegate()
    runApp(delegate)
}

func runApp(_ delegate: NSResponder & NSApplicationDelegate) -> Never {
    AppKitApplication.shared.delegate = delegate
    AppKitApplication.shared.nextResponder = delegate
    let code = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    exit(code)
}

// MARK: - AppKitApplication

private final class AppKitApplication: PlatformApplication {
    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func _shouldLoadMainNibNamed(_ name: String?) -> Bool {
        false
    }

    override func _shouldLoadMainStoryboardNamed(_ name: String?) -> Bool {
        false
    }
}
#endif
