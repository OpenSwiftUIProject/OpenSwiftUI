//
//  AnyUIHostingView.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#if os(iOS)

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

protocol AnyUIHostingView: AnyObject {
    var eventBridge: UIKitEventBindingBridge { get set }
    func displayLinkTimer(timestamp: Time, targetTimestamp: Time, isAsyncThread: Bool)
    var debugName: String? { get }
}

// FIXME:
class UIKitEventBindingBridge {}
#endif
