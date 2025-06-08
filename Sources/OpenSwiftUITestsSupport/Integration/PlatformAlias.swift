//
//  PlatformAlias.swift
//  OpenSwiftUITestsSupport

package import OpenSwiftUI
#if os(iOS)
package import UIKit
package typealias PlatformViewController = UIViewController
package typealias PlatformView = UIView
package typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
package typealias PlatformViewRepresentable = UIViewRepresentable
package typealias PlatformHostingController = UIHostingController
#elseif os(macOS)
package import AppKit
package typealias PlatformViewController = NSViewController
package typealias PlatformView = NSView
// package typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
// package typealias PlatformViewRepresentable = NSViewRepresentable
package typealias PlatformHostingController = NSHostingController
#endif
