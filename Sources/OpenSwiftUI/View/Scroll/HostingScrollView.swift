//
//  HostingScrollView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 12C63B62017D4F73E286C388C7056C07 (SwiftUI?)

#if os(iOS) || os(visionOS)
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - HostingScrollView [TBA]

// TODO: ScrollView
class HostingScrollView: UIScrollView {
    weak var responder: ViewResponder?

    // MARK: - PlatformGroupContainer [TBA]

    class PlatformGroupContainer: UIView {
        weak var scrollView: HostingScrollView?
        @WeakAttribute var focusableBounds: [FocusableBounds]?
        @WeakAttribute var focusableFillerBounds: [FocusableFillerBounds]?
        @WeakAttribute var focusableBorder: FocusableBorder??
        @WeakAttribute var pixelLength: CGFloat?
        var fillerItems: [any UIKitProxyFocusItem] = []
        var requestedFocusItem: (any UIFocusItem)?
    }
}
#endif
