//
//  UIKitRelationshipGestureRecognizer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import UIKit

// MARK: - UIKitRelationshipGestureRecognizer

final class UIKitRelationshipGestureRecognizer: UIGestureRecognizer {
    var gesturesRequiringFailure: Set<UIGestureRecognizer> = []

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }

    override func canPrevent(
        _ preventedGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        type(of: preventedGestureRecognizer) != UIKitGestureRecognizer.self
    }

    override func canBePrevented(
        by preventingGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        canPrevent(preventingGestureRecognizer)
    }
}

#endif
