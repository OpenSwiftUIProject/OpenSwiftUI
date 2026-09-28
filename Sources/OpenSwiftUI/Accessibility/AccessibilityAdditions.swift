//
//  AccessibilityAdditions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F0090706A080B6CC8EC7D33D6ADC922D (SwiftUI)

import Foundation
import OpenSwiftUICore
#if canImport(ObjectiveC)
import ObjectiveC
#endif
import COpenSwiftUI

// MARK: - NSObject + AccessibilityNode

#if canImport(ObjectiveC)
@objc(OpenSwiftUIAccessibilityPrivate)
#endif
extension NSObject {
    var accessibilityNodeForPlatformElement: AccessibilityNode? {
        get {
            #if canImport(ObjectiveC)
            objc_getAssociatedObject(
                self,
                &accessibilityNodeForPlatformElementKey
            ) as? AccessibilityNode
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
        set {
            #if canImport(ObjectiveC)
            objc_setAssociatedObject(
                self,
                &accessibilityNodeForPlatformElementKey,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN
            )
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }
}

private var accessibilityNodeForPlatformElementKey: UInt8 = 0
