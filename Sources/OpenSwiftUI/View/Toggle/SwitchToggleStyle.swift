//
//  SwitchToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 1246D37251EA3A918B392E2B95F8B7EF (SwiftUI)

// MARK: - SwitchToggleStyle [TODO]

extension ToggleStyle where Self == SwitchToggleStyle {
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var `switch`: SwitchToggleStyle {
        .init()
    }
}

public struct SwitchToggleStyle: ToggleStyle {
    @Environment(\.controlSize)
    private var controlSize: ControlSize

//    @Environment(\.tintColor)
//    private var controlTint: Color?
//
//    @Environment(\.placementTint)
//    private var placementTint: [TintPlacement: AnyShapeStyle]
//
    @Environment(\.effectiveFont)
    private var font: Font

    let tint: Color?

    public init() {
        tint = nil
    }

    @available(*, deprecated, message: "Use ``View/tint(_)`` instead.")
    @available(tvOS, unavailable)
    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        preconditionFailure("")
//        Switch(isOn: configuration.$isOn, tint: tint)
//            .fixedSize()
//            .contentShape(Capsule())
            // .accessibilityLabel(<#T##Text#>)
    }
}

@available(*, unavailable)
extension SwitchToggleStyle: Sendable {}

#if os(iOS)
import UIKit

// MARK: - Switch [WIP]

private struct Switch: UIViewRepresentable {
    typealias UIViewType = UISwitch

    typealias Coordinator = PlatformSwitchCoordinator
    
    @Binding var isOn: Bool
    var tint: Color?
    
    func makeUIView(context: Context) -> UISwitch {
        let view = UISwitch()
        view.addTarget(
            context.coordinator,
            action: #selector(PlatformSwitchCoordinator.isOnChanged),
            for: .valueChanged
        )
        return view
    }
    
    func updateUIView(_ uiView: UISwitch, context: Context) {
        let isOn = isOn
        let animated: Bool
        if let _ = context.transaction.animation, !context.transaction.disablesAnimations {
            animated = true
        } else {
            animated = false
        }
        uiView.setOn(isOn, animated: animated)
        uiView.preferredStyle = .sliding
        
        let color: UIColor?
        if let _ = tint {
            // TODO: Resolve the color from the environment
            color = nil
        } else {
            color = nil
        }
        let onTintColor = uiView.onTintColor
        if let color {
            if onTintColor == nil || color != onTintColor {
                uiView.onTintColor = color
            }
        } else {
            if onTintColor != nil {
                uiView.onTintColor = nil
            }
        }
        context.coordinator._isOn = _isOn
    }
    
    func makeCoordinator() -> Coordinator {
        PlatformSwitchCoordinator(isOn: _isOn)
    }
    
}

private class PlatformSwitchCoordinator: PlatformViewCoordinator {
    var _isOn: Binding<Bool>
    
    init(isOn: Binding<Bool>) {
        _isOn = isOn
        super.init()
    }

    @objc
    func isOnChanged(_ sender: UISwitch) {
        Update.dispatchImmediately {
            _isOn.wrappedValue = sender.isOn
        }
        sender.setOn(_isOn.wrappedValue, animated: true)
    }
}

#endif
