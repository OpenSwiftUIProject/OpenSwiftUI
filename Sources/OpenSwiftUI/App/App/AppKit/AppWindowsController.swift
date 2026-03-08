//
//  AppWindowsController.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: 72F61A03E62F0A97E0761B990CF02152 (SwiftUI)

#if os(macOS)
import AppKit
import OpenAttributeGraphShims

// FIXME
final class WindowController<Content>: NSWindowController where Content: View {
    init(_ hostingVC: NSHostingController<Content>) {
        self.hostingVC = hostingVC
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var windowNibName: NSNib.Name? { "" }

    let hostingVC: NSHostingController<Content>

    override func loadWindow() {
        window = NSWindow(contentViewController: hostingVC)
        window?.center()
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
