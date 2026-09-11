//
//  UIKitNavigationBridge.swift
//  OpenSwiftUI
//
//  Status: Empty

#if os(iOS) || os(visionOS)

// FIXME
class UIKitNavigationBridge {

}

class NavigationBridge_PhoneTV<V>: UIKitNavigationBridge where V: View {
    func updateViewInputs(_ inputs: inout _ViewInputs) {
        _openSwiftUIUnimplementedWarning()
    }
}

extension _UIHostingView {
    var navigationBridge: NavigationBridge_PhoneTV<Content>? {
        viewController?.navigationBridge
    }
}

#endif
