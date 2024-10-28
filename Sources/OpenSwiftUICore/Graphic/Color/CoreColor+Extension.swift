//
//  CoreColor+Extension.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

#if canImport(Darwin)
import Foundation
internal import OpenSwiftUI_SPI

extension OpenSwiftUICoreColor {
    package static func platformColor(resolvedColor: Color.Resolved) -> NSObject? {
        platformColor(red: CGFloat(resolvedColor.red), green: CGFloat(resolvedColor.green), blue: CGFloat(resolvedColor.blue), alpha: CGFloat(resolvedColor.opacity))
    }
    
    package static func platformColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> NSObject? {
        OpenSwiftUICorePlatformColorForRGBA(isAppKitBased(), red, green, blue, alpha)
    }
}

#endif
