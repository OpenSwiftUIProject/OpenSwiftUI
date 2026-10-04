//
//  AccessibilityNode.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 2F6327E72581B7F866C81F7546545BE8 (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if canImport(UIKit)
import UIKit
typealias AccessibilityNodeBase = UIResponder
#else
typealias AccessibilityNodeBase = NSObject
#endif

// FIXME
class AccessibilityNode: AccessibilityNodeBase {
    weak var bridgedChild: AccessibilityNode?

    var platformElement: PlatformAccessibilityElement? {
        // TODO: Resolve the platform element from accessibility attachments.
        _openSwiftUIUnimplementedFailure()
    }

    var visibility: AccessibilityVisibilityStorage {
        _openSwiftUIUnimplementedFailure()
    }

    func visibilityIgnoringAttachment(with token: AccessibilityAttachmentToken) -> AccessibilityVisibilityStorage {
        _openSwiftUIUnimplementedFailure()
    }

    var isPlaceholderOrIgnored: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    var sortPriority: Double? {
        _openSwiftUIUnimplementedFailure()
    }
}

//private struct AccessibilityAttachmentStorage {
//    var attachment: AccessibilityAttachment
//    var geometry: AccessibilityGeometryStorage
//    let token: AccessibilityAttachmentToken
//}
