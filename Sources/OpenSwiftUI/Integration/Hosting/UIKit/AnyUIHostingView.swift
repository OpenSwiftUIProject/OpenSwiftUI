//
//  AnyUIHostingView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

#if os(iOS)

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

protocol AnyUIHostingView: AnyObject {
    func displayLinkTimer(timestamp: Time, isAsyncThread: Bool)
}
#endif
