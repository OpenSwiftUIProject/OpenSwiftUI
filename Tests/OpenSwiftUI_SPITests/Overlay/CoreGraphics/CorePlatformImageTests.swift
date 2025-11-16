//
//  CorePlatformImageTests.swift
//  OpenSwiftUI_SPITests

#if canImport(Darwin)
import CoreGraphics
import Foundation
import OpenSwiftUI_SPI
import OpenSwiftUICore
import Testing
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
struct CorePlatformImageTests {
    @Test
    func nilCGImage() {
        let image: NSObject
        #if os(iOS) || os(visionOS)
        image = UIImage()
        #elseif os(macOS)
        image = NSImage(size: CGSize(width: 100, height: 100))
        #endif
        let coreImage = CorePlatformImage(system: .appKit, kitImage: image)
        #expect(coreImage.cgImage == nil)
        #expect(coreImage.size == .zero)
    }
    
    @Test
    func nonNilCGImage() {
        let image: NSObject
        #if os(iOS) || os(visionOS)
        image = UIImage.add
        #elseif os(macOS)
        image = NSImage(named: NSImage.addTemplateName)!
        #endif
        let coreImage = CorePlatformImage(system: .appKit, kitImage: image)
        #expect(coreImage.cgImage != nil)
        #expect(coreImage.size != .zero)
    }
}

#endif
