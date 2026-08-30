//
//  UIKitGestureUtilities.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import COpenSwiftUI
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

extension EventPhase {
    @inline(__always)
    init(_ phase: UITouch.Phase) {
        self = switch phase {
        case .began: .began
        case .moved, .stationary, .regionEntered, .regionMoved: .active
        case .ended, .regionExited: .ended
        case .cancelled: .failed
        @unknown default: .failed
        }
    }

    @inline(__always)
    init(_ phase: UIPress.Phase) {
        self = switch phase {
        case .began: .began
        case .changed, .stationary: .active
        case .ended: .ended
        case .cancelled: .failed
        @unknown default: .failed
        }
    }

    @inline(__always)
    init(_ phase: UITransformPhase) {
        self = switch phase {
        case .began: .began
        case .active: .active
        case .ended: .ended
        case .failed: .failed
        @unknown default: .failed
        }
    }
}

extension TouchType {
    @inline(__always)
    init(_ type: UITouch.TouchType) {
        self = switch type {
        case .direct: .direct
        case .indirect: .indirect
        case .pencil: .pencil
        case .indirectPointer: .indirectPointer
        @unknown default: _openSwiftUIUnreachableCode()
        }
    }
}

extension UIPress.PressType {
    static let back: UIPress.PressType = .init(rawValue: 7)!

    static var pageUp: UIPress.PressType {
        .init(rawValue: 30)!
    }

    static var pageDown: UIPress.PressType {
        .init(rawValue: 31)!
    }
}

extension PhysicalButtonEvent.ButtonType {
    @inline(__always)
    init(_ type: UIPress.PressType) {
        self = switch type {
        case .upArrow: .upArrow
        case .downArrow: .downArrow
        case .leftArrow: .leftArrow
        case .rightArrow: .rightArrow
        case .select: .select
        case .menu: .menu
        case .playPause: .playPause
        case .back: .back
        case .pageUp: .pageUp
        case .pageDown: .pageDown
        @unknown default: _openSwiftUIUnreachableCode()
        }
    }
}
#endif
