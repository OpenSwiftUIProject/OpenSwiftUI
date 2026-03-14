//
//  ImageConversionsTests.swift
//  OpenSwiftUITests

#if canImport(Darwin)
import Testing
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@MainActor
struct ImageConversionsTests {
    @Test
    func initWithSystemUIImage() {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let platformImage = NSImage(named: NSImage.addTemplateName)!
        let image = Image(nsImage: platformImage)
        let box = image.provider as? ImageProviderBox<NSImage>
        #else
        let platformImage = UIImage(systemName: "star")!
        let image = Image(uiImage: platformImage)
        let box = image.provider as? ImageProviderBox<UIImage>
        #endif
        #expect(box != nil)
        #expect(box?.base === platformImage)
    }

    @Test
    func initWithEmptyUIImage() {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let platformImage = NSImage(size: CGSize(width: 10, height: 10))
        let image = Image(nsImage: platformImage)
        let box = image.provider as? ImageProviderBox<NSImage>
        #else
        let platformImage = UIImage()
        let image = Image(uiImage: platformImage)
        let box = image.provider as? ImageProviderBox<UIImage>
        #endif
        #expect(box != nil)
        #expect(box?.base === platformImage)
    }
}
#endif
