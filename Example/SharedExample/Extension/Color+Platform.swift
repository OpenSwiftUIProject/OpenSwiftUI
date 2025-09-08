//
//  Color+Platform.swift
//  SharedExample
//
//  Created by Kyle on 2025/7/20.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

extension Color {
    init(platformColor: PlatformColor) {
        #if os(iOS) || os(visionOS)
        self.init(uiColor: platformColor)
        #elseif os(macOS)
        self.init(nsColor: platformColor)
        #endif
    }
}
