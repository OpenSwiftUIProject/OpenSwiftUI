//
//  VectorImageLayer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 53095E34581C439FFBDB89F0B27FB221 (SwiftUI)

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore
import OpenRenderBoxShims
public import AppKit

// MARK: - VectorImageLayer + NSImage

extension VectorImageLayer {
    @inline(__always)
    package init(nsImage: NSImage, scale: CGFloat) {
        let contents = NSImageContents(image: nsImage, scale: scale)
        self.init(contents)
    }
}

// MARK: - NSImageContents

private final class NSImageContents: VectorImageContents {
    var _image: NSImage
    var _scale: CGFloat
    var _displayList: (any ORBDisplayListContents)?

    init(image: NSImage, scale: CGFloat) {
        _image = image
        _scale = scale
        super.init()
    }

    override var size: CGSize {
        _image.size
    }

    override var displayList: any ORBDisplayListContents {
        if let cached = _displayList {
            return cached
        }
        let displayList = ORBDisplayList()
        displayList.defaultColorSpace = .SRGB
        let size = _image.size
        var rect = CGRect(origin: .zero, size: size)
        if let cgImage = _image.cgImage(
            forProposedRect: &rect,
            context: nil,
            hints: [.ctm: AffineTransform(scale: _scale)]
        ) {
            let context: CGContext = displayList.beginCGContext(withAlpha: 1.0)
            context.draw(cgImage, in: CGRect(origin: .zero, size: size), byTiling: false)
            displayList.endCGContext()
        }
        let contents = displayList.moveContents()
        _displayList = contents
        return _displayList!
    }

    override func image(size: CGSize, imageScale: CGFloat, prefersMask: Bool) -> CGImage? {
        var rect = CGRect(origin: .zero, size: size)
        return _image.cgImage(
            forProposedRect: &rect,
            context: nil,
            hints: [.ctm: AffineTransform(scale: imageScale)]
        )
    }
}
#endif
