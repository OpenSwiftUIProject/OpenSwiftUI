//
//  ImageLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete - Blocked by AsyncUpdate
//  ID: 854C382F3D9A82BFCF900A549E57F233 (SwiftUICore)

#if canImport(Darwin)
package import QuartzCore
import QuartzCore_Private

// MARK: - ImageLayer

final package class ImageLayer: CALayer {
    override dynamic package init() {
        super.init()
    }

    override dynamic package init(layer: Any) {
        super.init(layer: layer)
    }

    required dynamic package init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Updates the layer to display the given graphics image at the specified size.
    ///
    /// This method configures all relevant CALayer properties based on the GraphicsImage:
    /// - Contents (CGImage, IOSurface, or rendered image)
    /// - Background color (for solid color images)
    /// - Contents scale and center (for proper resizing)
    /// - Antialiasing and interpolation settings
    /// - HDR/EDR settings for extended dynamic range content
    ///
    /// - Parameters:
    ///   - image: The graphics image to display.
    ///   - size: The target size for the layer content.
    func update(image: GraphicsImage, size: CGSize) {
        // Determine layer contents and background color based on image type
        let layerContents: Any?
        let bgColor: CGColor?
        switch image.contents {
        case let .cgImage(cgImage):
            layerContents = cgImage
            bgColor = nil
        case let .ioSurface(surface):
            layerContents = surface
            bgColor = nil
        case let .color(resolved):
            layerContents = nil
            bgColor = resolved.cgColor
        case .vectorGlyph, .vectorLayer, .named:
            layerContents = image.render(at: size, prefersMask: image.isTemplate)
            bgColor = nil
        case nil:
            layerContents = nil
            bgColor = nil
        }
        contents = layerContents
        backgroundColor = bgColor
        allowsEdgeAntialiasing = image.isAntialiased
        guard contents != nil else { return }

        contentsScale = image.scale

        // Configure swizzle and tint for template images
        if let maskColor = image.maskColor {
            _CALayerSetSplatsContentsAlpha(self, true)
            contentsMultiplyColor = maskColor.cgColor
        } else {
            _CALayerSetSplatsContentsAlpha(self, false)
            contentsMultiplyColor = nil
        }

        // Configure resizing behavior
        let (centerRect, isTiled) = image.layerStretchInPixels(size: size)
        contentsCenter = centerRect
        contentsScaling = isTiled ? .repeat : .stretch

        // Configure interpolation filters
        switch image.interpolation {
        case .none:
            minificationFilter = .nearest
            magnificationFilter = .nearest
        case .low, .medium:
            minificationFilter = .linear
            magnificationFilter = .linear
        case .high:
            // Use box filter for high-quality minification
            minificationFilter = .box
            magnificationFilter = .linear
        }

        // Configure HDR/Extended Dynamic Range
        let headroom: Image.Headroom
        switch image.allowedDynamicRange?.storage {
        case .standard, .none: headroom = .standard
        case .constrainedHigh: headroom = min(image.headroom, .constrainedHigh)
        case .high: headroom = min(image.headroom, .high)
        }

        let wasUsingEDR = wantsExtendedDynamicRangeContent
        let currentMaxEDR = wasUsingEDR ? contentsMaximumDesiredEDR : 1.0

        // Enable EDR if needed
        if headroom > .standard {
            wantsExtendedDynamicRangeContent = true
        }
        contentsMaximumDesiredEDR = headroom.rawValue

        // Animate EDR transitions
        let edrDelta = headroom.rawValue - currentMaxEDR
        let shouldAnimate = (headroom > .standard || wasUsingEDR) && edrDelta != 0.0
        if shouldAnimate && isLinkedOnOrAfter(.v6) {
            addEDRSpringAnimation(delta: edrDelta)
        }
    }

    @inline(__always)
    private func addEDRSpringAnimation(delta: CGFloat) {
        let animation = CASpringAnimation(keyPath: "contentsMaximumDesiredEDR")
        animation.fromValue = NSNumber(value: -delta)
        animation.toValue = NSNumber(value: 0.0)
        animation.isAdditive = true
        animation.duration = 3.0
        animation.mass = 2.0
        animation.stiffness = 19.7392  // 2π²
        animation.damping = 12.5664    // 4π
        animation.fillMode = .backwards
        add(animation, forKey: nil)
    }

//    func updateAsync(
//        layer: DisplayList.ViewUpdater.AsyncLayer,
//        oldImage: GraphicsImage,
//        oldSize: CGSize,
//        newImage: GraphicsImage,
//        newSize: CGSize
//    ) -> Bool {
//        _openSwiftUIUnimplementedFailure()
//    }
}

// MARK: - GraphicsImage + LayerStretch

extension GraphicsImage {

    /// Computes the contentsCenter rect and tiling mode for CALayer configuration.
    ///
    /// The returned rect is normalized to 0...1 coordinates for use with CALayer.contentsCenter.
    /// For thin stretch regions (≤1 pixel), a minimal stretch line is used instead of tiling.
    ///
    /// - Parameter size: The target size for the layer.
    /// - Returns: A tuple of (centerRect, isTiled) for CALayer configuration.
    fileprivate func layerStretchInPixels(size: CGSize) -> (center: CGRect, tiled: Bool) {
        let adjustedSize = size.apply(bitmapOrientation)
        guard slicesAndTiles(at: adjustedSize) != nil else {
            return (CGRect(x: 0, y: 0, width: 1, height: 1), false)
        }
        var isTiled = isTiledWhenStretchedToSize(adjustedSize)
        let rect = contentStretchInPixels()
        let stretchRect = rect.isNull ? .zero : rect

        let pxSize = unrotatedPixelSize
        var x = stretchRect.origin.x
        var y = stretchRect.origin.y
        var width = stretchRect.size.width
        var height = stretchRect.size.height

        let thinStretchOffset = 0.01
        let thinStretchSize = 0.02

        let isThinStretchX: Bool
        if x == 0, width == pxSize.width {
            width = 1.0
            isThinStretchX = false
        } else if isTiled {
            x /= pxSize.width
            width /= pxSize.width
            isThinStretchX = false
        } else {
            width = max(0, width - 1)
            x = (x + 0.5) / pxSize.width
            if width <= 1 {
                x -= thinStretchOffset / pxSize.width
                width = thinStretchSize / pxSize.width
                isThinStretchX = true
            } else {
                width /= pxSize.width
                isThinStretchX = false
            }
        }
        if y == 0, height == pxSize.height {
            if isThinStretchX {
                isTiled = false
            }
            height = 1.0
        } else if isTiled {
            y /= pxSize.height
            height /= pxSize.height
        } else {
            height = max(0, height - 1)
            y = (y + 0.5) / pxSize.height
            if height <= 1 {
                isTiled = false
                y -= thinStretchOffset / pxSize.height
                height = thinStretchSize / pxSize.height
            } else {
                height /= pxSize.height
            }
        }
        return (CGRect(x: x, y: y, width: width, height: height), isTiled)
    }

    /// Determines if the image should be tiled when stretched to the given size.
    ///
    /// - Parameter targetSize: The target size to stretch to.
    /// - Returns: `true` if tiling should be used; `false` otherwise.
    fileprivate func isTiledWhenStretchedToSize(_ targetSize: CGSize) -> Bool {
        guard let resizingInfo, resizingInfo.mode == .tile else {
            return false
        }

        let pointSize = size
        let insets = resizingInfo.capInsets
        let stretchWidth = pointSize.width - insets.leading - insets.trailing
        if stretchWidth > 1 && pointSize.width != targetSize.width {
            return true
        }
        let stretchHeight = pointSize.height - insets.top - insets.bottom
        if stretchHeight > 1 && pointSize.height != targetSize.height {
            return true
        }
        return false
    }

    /// Returns the stretch rectangle in pixel coordinates.
    ///
    /// This is the center portion of the image that can be stretched or tiled,
    /// excluding the cap insets.
    fileprivate func contentStretchInPixels() -> CGRect {
        // Get insets (zero if no resizingInfo)
        let insets = resizingInfo?.capInsets ?? EdgeInsets()
        let pixelSize = pixelSize
        let insetRect = CGRect(
            origin: .zero,
            size: pixelSize
        ).inset(by: insets * scale)
        return insetRect.unapply(bitmapOrientation, in: pixelSize)
    }
}

#endif
