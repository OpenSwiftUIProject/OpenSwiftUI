//
//  UIKitResponderGestureRecognizer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 662C41D74B7DB02BE62C701B7B796750 (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

private let isUIKitGestureDebuggingEnabled = UserDefaults.uiKit?.bool(forKey: "LogGesture") ?? false

// MARK: - UIKitResponderGestureRecognizer

final class UIKitResponderGestureRecognizer: UIKitGestureRecognizer {
    weak var responder: (any AnyGestureResponder)? {
        didSet {
            guard let responder,
                  responder.inputs.base.interfaceIdiom.accepts(.carPlay) else {
                return
            }
            allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        }
    }

    override init() {
        super.init()
        delegate = self
    }

    override var name: String? {
        get {
            if let label = Update.ensure({ responder?.label }) {
                return label
            }
            if isUIKitGestureDebuggingEnabled, let responder {
                return "\(responder.gestureType)"
            }
            return super.name
        }
        set {
            super.name = newValue
        }
    }

    override func didAttach(to eventBridge: EventBindingBridge?) {
        guard let eventBridge = eventBridge as? UIKitResponderEventBindingBridge else {
            return
        }
        addTarget(
            eventBridge,
            action: #selector(UIKitResponderEventBindingBridge.flushActions)
        )
    }

    override func isKind(of aClass: AnyClass) -> Bool {
        if aClass == UITapGestureRecognizer.self,
           let responder,
           responder.requiredTapCount != nil {
            return true
        }
        return super.isKind(of: aClass)
    }

    override func _isGestureType(_ type: Int) -> Bool {
        type == 0 && responder?.requiredTapCount != nil
    }

    override func numberOfTapsRequired() -> UInt {
        UInt(responder?.requiredTapCount ?? 0)
    }

    override func numberOfTouchesRequired() -> UInt {
        1
    }

    override func buttonMaskRequired() -> UIEvent.ButtonMask {
        .primary
    }

    override func canPrevent(
        _ preventedGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let responder {
            if let otherRecognizer = preventedGestureRecognizer as? UIKitResponderGestureRecognizer,
               let otherResponder = otherRecognizer.responder {
                return responder.canPrevent(
                    otherResponder,
                    otherExclusionPolicy: otherResponder.exclusionPolicy
                )
            }
            if let scrollView = preventedGestureRecognizer.view as? HostingScrollView,
               let scrollResponder = scrollView.responder,
               scrollView.panGestureRecognizer === preventedGestureRecognizer {
                return responder.canPrevent(
                    scrollResponder,
                    otherExclusionPolicy: responder.isCancellable ? .simultaneous : .default
                )
            }
            if responder.isCancellable,
               responder.exclusionPolicy != .highPriority,
               preventedGestureRecognizer.isCancellingGesture {
                return false
            }
            if responder.exclusionPolicy == .simultaneous {
                return false
            }
            if let isPrioritized = responder.isPrioritized(over: preventedGestureRecognizer) {
                return isPrioritized
            }
            if preventedGestureRecognizer.isTextMultiTapRecognizer {
                return false
            }
        }
        return super.canPrevent(preventedGestureRecognizer)
    }

    override func canBePrevented(
        by preventingGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let responder {
            if let otherRecognizer = preventingGestureRecognizer as? UIKitResponderGestureRecognizer,
               let otherResponder = otherRecognizer.responder {
                return otherResponder.canPrevent(
                    responder,
                    otherExclusionPolicy: responder.exclusionPolicy
                )
            }
            if responder.exclusionPolicy == .simultaneous {
                return false
            }
            if let isPrioritized = responder.isPrioritized(over: preventingGestureRecognizer) {
                return !isPrioritized
            }
        }
        return super.canBePrevented(by: preventingGestureRecognizer)
    }

    override func shouldRequireFailure(
        of otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let responder {
            if let otherRecognizer = otherGestureRecognizer as? UIKitResponderGestureRecognizer,
               let otherResponder = otherRecognizer.responder {
                return responder.shouldRequireFailure(of: otherResponder)
            }
            if responder.isCancellable,
               (otherGestureRecognizer.isScrollViewDelayedTouchesBeganRecognizer
                || otherGestureRecognizer.name == "UISwitch-longPress") {
                return true
            }
        }
        return super.shouldRequireFailure(of: otherGestureRecognizer)
    }

    override func shouldBeRequiredToFail(
        by otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let responder {
            if let otherRecognizer = otherGestureRecognizer as? UIKitResponderGestureRecognizer,
               let otherResponder = otherRecognizer.responder {
                return otherResponder.shouldRequireFailure(of: responder)
            }
        }
        return super.shouldBeRequiredToFail(by: otherGestureRecognizer)
    }
}

// MARK: - UIKitResponderGestureRecognizer + UIGestureRecognizerDelegatePrivate

extension UIKitResponderGestureRecognizer: UIGestureRecognizerDelegatePrivate {
    func _gestureRecognizer(
        _: UIGestureRecognizer,
        canBeCancelledBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let responder {
            if let otherRecognizer = otherGestureRecognizer as? UIKitResponderGestureRecognizer,
               let otherResponder = otherRecognizer.responder,
               (responder.exclusionPolicy == .simultaneous || otherResponder.exclusionPolicy == .simultaneous) {
                return false
            }
            if otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self)
                || otherGestureRecognizer.isKind(of: UILongPressGestureRecognizer.self)
                || otherGestureRecognizer.isTextMultiTapRecognizer
            {
                return false
            }
            return responder.isCancellable && otherGestureRecognizer.isCancellingGesture
        }
        return false
    }
}

// MARK: - Gesture Private Util

extension AnyGestureResponder {
    fileprivate func isPrioritized(over gestureRecognizer: UIGestureRecognizer) -> Bool? {
        lazy var isLongPress = gestureRecognizer.name == "UISwitch-longPress"
        guard exclusionPolicy == .highPriority || isLongPress,
              let view = gestureRecognizer.view,
              let gestureContainer else {
            return nil
        }
        let result = OpenSwiftUIGestureRecognizerContainerCompare(
            gestureContainer,
            view,
            false
        )
        return result == .orderedAscending ? !isLongPress : nil
    }
}

extension UIGestureRecognizer {
    fileprivate var isCancellingGesture: Bool {
        name == "com.apple.UIKit.dragInitiation"
            || name == "com.apple.UIKit.clickPresentationExclusion"
            || name == "com.apple.UIKit.dragExclusionRelationships"
            || self is UIPanGestureRecognizer
    }

    @inline(__always)
    var isTextMultiTapRecognizer: Bool {
        isKind(ofPrivateClassNamed: "UITextMultiTapRecognizer")
    }

    @inline(__always)
    var isScrollViewDelayedTouchesBeganRecognizer: Bool {
        isKind(
            ofPrivateClassNamed:
                "UIScrollViewDelayedTouchesBeganGestureRecognizer"
        )
    }

    private func isKind(ofPrivateClassNamed name: String) -> Bool {
        guard let privateClass = NSClassFromString(name) else {
            return false
        }
        return isKind(of: privateClass)
    }
}

// TODO: ScrollView
class HostingScrollView: UIScrollView {
    weak var responder: ViewResponder?
}

#endif
