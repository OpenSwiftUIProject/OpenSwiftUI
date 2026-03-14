//
//  Platform+TypeAlias.swift
//  Shared
//
//  Created by Kyle on 2025/7/20.
//

#if OPENSWIFTUI
public import OpenSwiftUI
#else
public import SwiftUI
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
public typealias PlatformView = NSView
public typealias PlatformViewController = NSViewController
public typealias PlatformHostingController = NSHostingController
public typealias PlatformHostingView = NSHostingView
#elseif canImport(UIKit)
public import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
public typealias PlatformView = UIView
public typealias PlatformViewController = UIViewController
public typealias PlatformHostingController = UIHostingController
public typealias PlatformHostingView = _UIHostingView
#endif

extension Color {
    public init(platformColor: PlatformColor) {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        self.init(nsColor: platformColor)
        #elseif canImport(UIKit)
        self.init(uiColor: platformColor)
        #endif
    }
}

extension Image {
    public init(platformImage: PlatformImage) {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        self.init(nsImage: platformImage)
        #elseif canImport(UIKit)
        self.init(uiImage: platformImage)
        #endif
    }
}
