//
//  AnyUIHostingView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if os(iOS)
protocol AnyUIHostingView: AnyObject {
    func displayLinkTimer(timestamp: Time, isAsyncThread: Bool)
}
#endif
