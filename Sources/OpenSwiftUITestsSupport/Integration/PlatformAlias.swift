//
//  PlatformAlias.swift
//  OpenSwiftUITestsSupport

#if OPENSWIFTUI
package import OpenSwiftUI
#else
package import SwiftUI
#endif

#if os(iOS)
package import UIKit
package typealias PlatformViewController = UIViewController
package typealias PlatformView = UIView
package typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
package typealias PlatformViewRepresentable = UIViewRepresentable
package typealias PlatformHostingController = UIHostingController

package typealias PlatformColor = UIColor
extension Color {
    package init(platformColor: PlatformColor) {
        self.init(uiColor: platformColor)
    }
}
#elseif os(macOS)
package import AppKit
package typealias PlatformViewController = NSViewController
package typealias PlatformView = NSView
// package typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
// package typealias PlatformViewRepresentable = NSViewRepresentable
package typealias PlatformHostingController = NSHostingController

package typealias PlatformColor = NSColor
extension Color {
    package init(platformColor: PlatformColor) {
        self.init(nsColor: platformColor)
    }
}
#endif
