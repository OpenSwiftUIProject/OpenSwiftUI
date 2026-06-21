//
//  UIKitEventBindingBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if os(iOS) || os(visionOS)

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
package import UIKit

// FIXME
package class UIKitEventBindingBridge: EventBindingBridge {
    package var gestureRecognizer: UIGestureRecognizer?
    // var hoverGestureRecognizer: UIKitHoverGestureRecognizer
    // var keyPressResponder: UIKitKeyPressResponder?
}
#endif
