//
//  CoreGraphicsContextTests.swift
//  OpenSwiftUI_SPITests

import OpenSwiftUI_SPI
import Testing

#if canImport(Darwin)
import CoreGraphics
import Foundation

@MainActor
struct CoreGraphicsContextTests {
    @Test
    func example() async throws {
        let width = 200
        let height = 200
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let cgContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            fatalError("Could not create CGContext")
        }

        let context = CoreGraphicsContext(cgContext: cgContext)
        #expect(CoreGraphicsContext.current == nil)
        context.push()
        #expect(CoreGraphicsContext.current != nil)
        context.pop()
        #expect(CoreGraphicsContext.current == nil)
    }
}

#endif
