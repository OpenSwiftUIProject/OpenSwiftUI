//
//  UIKitGestureUtilities.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import UIKit
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

extension UIGestureRecognizer.State {
    func nextState(for phase: GesturePhase<Void>) -> UIGestureRecognizer.State {
        switch phase {
        case .possible:
            self
        case .active:
            self == .possible ? .began : .changed
        case .ended:
            .ended
        case .failed:
            self == .possible || self == .failed ? .failed : .cancelled
        @unknown default:
            _openSwiftUIUnreachableCode()
        }
    }
}

extension UIPress.PressType {
    static let back: UIPress.PressType = .init(rawValue: 7)!
}
#endif
