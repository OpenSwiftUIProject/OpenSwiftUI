//
//  DisplayLink.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: D912470A6161D66810B373079EE9F26A

#if canImport(Darwin) && os(iOS) // Disable macOS temporary due to CADisplayLink issue
import QuartzCore
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

final class DisplayLink: NSObject {
    private weak var host: AnyUIHostingView?
    private var link: CADisplayLink?
    private var nextUpdate: Time
    private var currentUpdate: Time?
    private var interval: Double
    private var reasons: Set<UInt32>
    private var currentThread: ThreadName
    private var nextThread: ThreadName
    
    #if os(iOS)
    init(host: AnyUIHostingView, window: UIWindow) {
        preconditionFailure("TODO")
    }
    #elseif os(macOS)
    init(host: AnyUIHostingView, window: NSWindow) {
        preconditionFailure("TODO")
    }
    #endif
    
    var willRender: Bool {
        nextUpdate < .infinity
    }
        
    func setNextUpdate(delay: Double, interval: Double, reasons: Set<UInt32>) {
        // TODO
    }
    
    func invalidate() {
        Update.locked {
            // TODO
        }
    }
    
    @inline(__always)
    func startAsyncRendering() {
        nextThread = .async
    }
    
    @inline(__always)
    func cancelAsyncRendering() {
        nextThread = .main
    }
}

extension DisplayLink {
    enum ThreadName: Hashable {
        case main
        case async
    }
}
#endif
