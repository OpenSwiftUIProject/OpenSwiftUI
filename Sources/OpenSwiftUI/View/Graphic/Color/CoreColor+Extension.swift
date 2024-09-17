//
//  CoreColor+Extension.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

#if canImport(Darwin)
import COpenSwiftUICore

extension CoreColor {
    package static func platformColor(resolvedColor: Color.Resolved) -> NSObject? {
        platformColor(red: CGFloat(resolvedColor.red), green: CGFloat(resolvedColor.green), blue: CGFloat(resolvedColor.blue), alpha: CGFloat(resolvedColor.opacity))
    }
    
    package static func platformColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> NSObject? {
        CorePlatformColorForRGBA(isAppKitBased(), red, green, blue, alpha)
    }
    
    #if os(iOS)
    static var systemRed: NSObject? {
        systemRedColor(withSystem: isAppKitBased())
    }
    
    static var systemOrange: NSObject? {
        systemOrangeColor(withSystem: isAppKitBased())
    }
    
    static var systemYellow: NSObject? {
        systemYellowColor(withSystem: isAppKitBased())
    }
    
    static var systemGreen: NSObject? {
        systemGreenColor(withSystem: isAppKitBased())
    }
    
    static var systemTeal: NSObject? {
        systemTealColor(withSystem: isAppKitBased())
    }
    
    static var systemMint: NSObject? {
        systemMintColor(withSystem: isAppKitBased())
    }
    
    static var systemCyan: NSObject? {
        systemCyanColor(withSystem: isAppKitBased())
    }
    
    static var systemBlue: NSObject? {
        systemBlueColor(withSystem: isAppKitBased())
    }
    
    static var systemIndigo: NSObject? {
        systemIndigoColor(withSystem: isAppKitBased())
    }
    
    static var systemPurple: NSObject? {
        systemPurpleColor(withSystem: isAppKitBased())
    }
    
    static var systemPink: NSObject? {
        systemPinkColor(withSystem: isAppKitBased())
    }
    
    static var systemBrown: NSObject? {
        systemBrownColor(withSystem: isAppKitBased())
    }
    
    static var systemGray: NSObject? {
        systemGrayColor(withSystem: isAppKitBased())
    }
    #endif
}

#endif
