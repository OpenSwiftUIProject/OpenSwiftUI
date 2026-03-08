//
//  ImageLayerTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin)
import OpenCoreGraphicsShims
@_spi(Private)
@testable
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "ImageLayer.swift")
#endif
import OpenSwiftUICore
import Testing

// MARK: - GraphicsImage + LayerStretch Tests

struct GraphicsImageLayerStretchTests {
    // Helper to create a basic GraphicsImage for testing
    private func makeImage(
        scale: CGFloat = 1.0,
        pixelSize: CGSize,
        orientation: Image.Orientation = .up,
        resizingInfo: Image.ResizingInfo? = nil
    ) -> GraphicsImage {
        GraphicsImage(
            contents: nil,
            scale: scale,
            unrotatedPixelSize: pixelSize,
            orientation: orientation,
            isTemplate: false,
            resizingInfo: resizingInfo
        )
    }

    // MARK: - contentStretchInPixels Tests

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test(arguments: [
        // (pixelSize, scale, capInsets, orientation, expected)
        // No insets - full size
        (CGSize(width: 100, height: 100), 1.0, EdgeInsets(), Image.Orientation.up,
         CGRect(x: 0, y: 0, width: 100, height: 100)),
        // With insets at scale 1
        (CGSize(width: 100, height: 100), 1.0, EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), Image.Orientation.up,
         CGRect(x: 10, y: 10, width: 80, height: 80)),
        // With insets at scale 2
        (CGSize(width: 200, height: 200), 2.0, EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), Image.Orientation.up,
         CGRect(x: 20, y: 20, width: 160, height: 160)),
        // Asymmetric insets
        (CGSize(width: 100, height: 100), 1.0, EdgeInsets(top: 5, leading: 10, bottom: 15, trailing: 20), Image.Orientation.up,
         CGRect(x: 10, y: 5, width: 70, height: 80)),
    ])
    func contentStretchInPixels(
        _ pixelSize: CGSize,
        _ scale: CGFloat,
        _ insets: EdgeInsets,
        _ orientation: Image.Orientation,
        _ expected: CGRect
    ) {
        let resizingInfo: Image.ResizingInfo? = insets == EdgeInsets() ? nil : Image.ResizingInfo(capInsets: insets, mode: .stretch)
        let image = makeImage(scale: scale, pixelSize: pixelSize, orientation: orientation, resizingInfo: resizingInfo)
        let result = image.contentStretchInPixels()
        #expect(result == expected)
    }
    #endif

    // MARK: - isTiledWhenStretchedToSize Tests

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test(arguments: [
        // (pixelSize, capInsets, mode, targetSize, expected)
        // No resizingInfo (nil insets) → false
        (CGSize(width: 100, height: 100), EdgeInsets?.none, Image.ResizingMode?.none,
         CGSize(width: 200, height: 200), false),
        // Stretch mode → false
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), Image.ResizingMode.stretch,
         CGSize(width: 200, height: 200), false),
        // Tile mode, same size → false
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), Image.ResizingMode.tile,
         CGSize(width: 100, height: 100), false),
        // Tile mode, different width → true
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), Image.ResizingMode.tile,
         CGSize(width: 200, height: 100), true),
        // Tile mode, different height → true
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10), Image.ResizingMode.tile,
         CGSize(width: 100, height: 200), true),
        // Tile mode, thin stretch region → false
        (CGSize(width: 100, height: 100), EdgeInsets(top: 49, leading: 49, bottom: 50, trailing: 50), Image.ResizingMode.tile,
         CGSize(width: 200, height: 200), false),
    ])
    func isTiledWhenStretchedToSize(
        _ pixelSize: CGSize,
        _ insets: EdgeInsets?,
        _ mode: Image.ResizingMode?,
        _ targetSize: CGSize,
        _ expected: Bool
    ) {
        let resizingInfo: Image.ResizingInfo? = if let insets, let mode {
            Image.ResizingInfo(capInsets: insets, mode: mode)
        } else {
            nil
        }
        let image = makeImage(pixelSize: pixelSize, resizingInfo: resizingInfo)
        #expect(image.isTiledWhenStretchedToSize(targetSize) == expected)
    }
    #endif

    // MARK: - layerStretchInPixels Tests

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test(arguments: [
        // (pixelSize, capInsets, mode, targetSize, expectedCenter, expectedTiled)
        // No slicesAndTiles (no resizingInfo) → full rect
        (CGSize(width: 100, height: 100), EdgeInsets?.none, Image.ResizingMode?.none,
         CGSize(width: 100, height: 100),
         CGRect(x: 0, y: 0, width: 1, height: 1), false),
        // Full span X/Y → 1x1
        (CGSize(width: 100, height: 100), EdgeInsets.zero, Image.ResizingMode.stretch,
         CGSize(width: 200, height: 200),
         CGRect(x: 0, y: 0, width: 1, height: 1), false),
        // Tiled mode → linear normalization
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20), Image.ResizingMode.tile,
         CGSize(width: 200, height: 200),
         CGRect(x: 0.2, y: 0.1, width: 0.6, height: 0.8), true),
        // Stretch mode → centered normalization
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20), Image.ResizingMode.stretch,
         CGSize(width: 200, height: 200),
         CGRect(x: 0.205, y: 0.105, width: 0.59, height: 0.79), false),
        // Thin stretch X → uses thin line
        (CGSize(width: 100, height: 100), EdgeInsets(top: 10, leading: 49, bottom: 10, trailing: 49), Image.ResizingMode.stretch,
         CGSize(width: 200, height: 200),
         CGRect(x: 0.4949, y: 0.105, width: 0.0002, height: 0.79), false),
        // Thin stretch Y → forces isTiled=false
        (CGSize(width: 100, height: 100), EdgeInsets(top: 49, leading: 10, bottom: 49, trailing: 10), Image.ResizingMode.stretch,
         CGSize(width: 200, height: 200),
         CGRect(x: 0.105, y: 0.4949, width: 0.79, height: 0.0002), false),
        // Thin stretch X + full height Y → isTiled=false
        (CGSize(width: 100, height: 100), EdgeInsets(top: 0, leading: 49, bottom: 0, trailing: 49), Image.ResizingMode.stretch,
         CGSize(width: 200, height: 200),
         CGRect(x: 0.4949, y: 0, width: 0.0002, height: 1.0), false),
    ])
    func layerStretchInPixels(
        _ pixelSize: CGSize,
        _ insets: EdgeInsets?,
        _ mode: Image.ResizingMode?,
        _ targetSize: CGSize,
        _ expectedCenter: CGRect,
        _ expectedTiled: Bool
    ) {
        let resizingInfo: Image.ResizingInfo? = if let insets, let mode {
            Image.ResizingInfo(capInsets: insets, mode: mode)
        } else {
            nil
        }
        let image = makeImage(pixelSize: pixelSize, resizingInfo: resizingInfo)
        let (center, tiled) = image.layerStretchInPixels(size: targetSize)
        #expect(center.origin.x.isApproximatelyEqual(to: expectedCenter.origin.x))
        #expect(center.origin.y.isApproximatelyEqual(to: expectedCenter.origin.y))
        #expect(center.size.width.isApproximatelyEqual(to: expectedCenter.size.width))
        #expect(center.size.height.isApproximatelyEqual(to: expectedCenter.size.height))
        #expect(tiled == expectedTiled)
    }
    #endif
}

#endif
