//
//  AppWindowsController.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 72F61A03E62F0A97E0761B990CF02152 (SwiftUI)

#if os(macOS)
import AppKit
import OpenAttributeGraphShims

// FIXME
final class WindowController<Content>: NSWindowController where Content: View {
    init(_ hostingVC: NSHostingController<Content>, item: SceneList.Item) {
        self.hostingVC = hostingVC
        self.item = item
        super.init(window: nil)
        barAppearanceBridge.defaultTitle = item.title ?? Text(currentAppName())
        barAppearanceBridge.lastEnvironment = item.environment
        hostingVC.host.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var windowNibName: NSNib.Name? { "" }

    let hostingVC: NSHostingController<Content>

    let item: SceneList.Item

    let barAppearanceBridge = BarAppearanceBridge()

    override func loadWindow() {
        window = NSWindow(contentViewController: hostingVC)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        sizeAndPlaceWindow()
    }

    private func sizeAndPlaceWindow() {
        guard let window else {
            return
        }
        let proposal = item.defaultSize.map { _ProposedSize($0) } ?? WindowSizeConstants.defaultProposedSize
        window.setContentSize(hostingVC.host.sizeThatFits(proposal))
        placeWindow(window)
    }

    private func placeWindow(_ window: NSWindow) {
        guard let visibleFrame = NSScreen.main?.visibleFrame else {
            return
        }
        let position = item.defaultPosition ?? .center
        let frame = window.frame
        window.setFrameOrigin(CGPoint(
            x: visibleFrame.minX + (visibleFrame.width - frame.width) * position.x,
            y: visibleFrame.maxY - frame.height - (visibleFrame.height - frame.height) * position.y
        ))
    }
}

// MARK: - WindowController + NSHostingViewDelegate [TBA]

extension WindowController: NSHostingViewDelegate {
    func hostingView<V>(_ hostingView: NSHostingView<V>, didMoveTo window: NSWindow?) where V: View {
        guard let window else { return }
        Update.ensure {
            barAppearanceBridge.addPreferences(to: hostingView.viewGraph)
            barAppearanceBridge.platformStorage.defaultWindowTitleVisibility = window.titleVisibility == .hidden ? .hidden : .visible
            barAppearanceBridge.platformStorage.windowTitleBarIsTransparentByDefault = window.titlebarAppearsTransparent
        }
        // TODO: Configure the remaining window bridges.
    }

    func hostingView<V>(_ hostingView: NSHostingView<V>, willUpdate environment: inout EnvironmentValues) where V: View {
        barAppearanceBridge.update(environment: &environment)
        // TODO: Apply bar configurations with the current window context.
    }

    func hostingView<V>(_ hostingView: NSHostingView<V>, didUpdate environment: EnvironmentValues) where V: View {
        // TODO: Handle deferred window dismissal.
    }

    func hostingView<V>(_ hostingView: NSHostingView<V>, didChangePreferences preferences: PreferenceValues) where V: View {
        let updates = barAppearanceBridge.preferencesDidChange(
            preferences,
            updateContext: .init(target: hostingVC.view)
        )
        if updates.rawValue & 0x1 != 0 {
            hostingView.invalidateProperties(.environment)
        }
        // TODO: Update the remaining window bridges.
    }
}

// MARK: - RootEnvironmentModifier [FIXME]

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
