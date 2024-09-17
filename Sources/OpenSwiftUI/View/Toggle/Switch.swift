//
//  Switch.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by Color
//  ID: 1246D37251EA3A918B392E2B95F8B7EF

#if os(iOS)
import UIKit

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
        Update.perform {
            _isOn.wrappedValue = sender.isOn
        }
        sender.setOn(_isOn.wrappedValue, animated: true)
    }
}

#endif
