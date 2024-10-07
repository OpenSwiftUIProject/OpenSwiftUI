//
//  AnyUIHostingView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if os(iOS)

@_spi(ForOpenSwiftUIOnly) internal import OpenSwiftUICore

protocol AnyUIHostingView: AnyObject {
    func displayLinkTimer(timestamp: Time, isAsyncThread: Bool)
}
#endif
