//
//  CoreColor+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

#if canImport(Darwin)
package import Foundation
import OpenSwiftUI_SPI

extension CoreColor {
    package static func platformColor(resolvedColor: Color.Resolved) -> NSObject? {
        platformColor(red: CGFloat(resolvedColor.red), green: CGFloat(resolvedColor.green), blue: CGFloat(resolvedColor.blue), alpha: CGFloat(resolvedColor.opacity))
    }
    
    package static func platformColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> NSObject? {
        CorePlatformColorForRGBA(system: isAppKitBased() ? .appKit : .uiKit, red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
