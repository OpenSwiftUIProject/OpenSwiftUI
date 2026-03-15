//
//  VectorImageLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FD14FB6A78229243CA216236680C9BDD (SwiftUICore)

public import Foundation
#if OPENSWIFTUI_LINK_COREUI
package import CoreUI
#endif
@_spiOnly public import OpenRenderBoxShims
public import OpenCoreGraphicsShims

// MARK: - VectorImageLayer

package struct VectorImageLayer: Hashable {
    package var contents: VectorImageContents
    var location: Image.Location?
    var name: String?

    package init(_ contents: VectorImageContents) {
        self.contents = contents
        self.location = nil
        self.name = nil
    }

    #if canImport(CoreGraphics) && OPENSWIFTUI_LINK_COREUI
    package init?(image: CUINamedVectorImage, location: Image.Location, size: CGSize) {
        let contents: VectorImageContents
        if let pdfImage = image as? CUINamedVectorPDFImage,
           let pdfDocument = pdfImage.pdfDocument,
           let page = pdfDocument.page(at: 1) {
            let catalog: CUICatalog?
            if case .bundle(let bundle) = location,
               let (cat, retain) = NamedImage.sharedCache[bundle],
               retain {
                catalog = cat
            } else {
                catalog = nil
            }
            contents = PDFImageContents(page: page, catalog: catalog, size: size)
        } else if let svgImage = image as? CUINamedVectorSVGImage,
                  let svgDocument = svgImage.svgDocument {
            let catalog: CUICatalog?
            if case .bundle(let bundle) = location,
               let (cat, retain) = NamedImage.sharedCache[bundle],
               retain {
                catalog = cat
            } else {
                catalog = nil
            }
            contents = SVGImageContents(document: svgDocument, catalog: catalog, size: size)
        } else {
            return nil
        }
        self.contents = contents
        self.location = location
        self.name = image.name
    }
    #endif

    #if canImport(CoreGraphics) && OPENSWIFTUI_LINK_COREUI
    package init(pdfPage: CGPDFPage, size: CGSize) {
        let contents = PDFImageContents(page: pdfPage, catalog: nil, size: size)
        self.init(contents)
    }
    #endif

    #if canImport(CoreGraphics) && OPENSWIFTUI_LINK_COREUI
    package init(svgDocument: CGSVGDocument, size: CGSize) {
        let contents = SVGImageContents(document: svgDocument, catalog: nil, size: size)
        self.init(contents)
    }
    #endif

    package var size: CGSize {
        contents.size
    }

    package var displayList: any ORBDisplayListContents {
        contents.displayList
    }

    package func image(size: CGSize, imageScale: CGFloat, prefersMask: Bool = false) -> CGImage? {
        contents.image(size: size, imageScale: imageScale, prefersMask: prefersMask)
    }

    package static func == (lhs: VectorImageLayer, rhs: VectorImageLayer) -> Bool {
        lhs.contents === rhs.contents
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(contents))
    }
}

// MARK: - VectorImageLayer + ProtobufMessage

extension VectorImageLayer: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, CodableRBDisplayListContents(contents.displayList))
        try encoder.messageField(2, contents.size)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var displayListContents: (any ORBDisplayListContents)?
        var size: CGSize = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                let codable: CodableRBDisplayListContents = try decoder.messageField(field)
                displayListContents = codable.base
            case 2:
                size = try decoder.messageField(field)
            default:
                try decoder.skipField(field)
            }
        }
        guard let dl = displayListContents else {
            throw ProtobufDecoder.DecodingError.failed
        }
        let contents = DisplayListImageContents(displayList: dl, size: size)
        self.init(contents)
    }
}

// MARK: - VectorImageContents

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class VectorImageContents {
    package init() {
        _openSwiftUIEmptyStub()
    }

    open var size: CGSize {
        _openSwiftUIBaseClassAbstractMethod()
    }

    open var displayList: any ORBDisplayListContents {
        _openSwiftUIBaseClassAbstractMethod()
    }

    open func image(size: CGSize, imageScale: CGFloat, prefersMask: Bool) -> CGImage? {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension VectorImageContents: @unchecked Sendable {}

// MARK: - CachedVectorImageContents

package class CachedVectorImageContents: VectorImageContents {
    struct CacheKey: Hashable {
        var hasColor: Bool
    }

    var imageCache: [CacheKey: CGImage] = [:]

    package override init() {
        super.init()
    }

    func draw(in context: CGContext) {
        displayList.render(in: context, options: nil)
    }

    package override func image(size: CGSize, imageScale: CGFloat, prefersMask: Bool) -> CGImage? {
        #if canImport(CoreGraphics)
        let nativeSize = self.size
        let sizeMatches = size == nativeSize
        let key = CacheKey(hasColor: !prefersMask)
        if sizeMatches, let cached = imageCache[key] {
            return cached
        }
        let pixelWidth = Int(ceil(size.width * imageScale))
        let pixelHeight = Int(ceil(size.height * imageScale))
        guard let context = CGImage.context(pixelWidth, pixelHeight, prefersMask: prefersMask) else {
            return nil
        }
        context.scaleBy(
            x: CGFloat(pixelWidth) / size.width,
            y: CGFloat(pixelHeight) / size.height
        )
        context.scaleBy(
            x: size.width / nativeSize.width,
            y: size.height / nativeSize.height
        )
        draw(in: context)
        let image = context.makeImage()
        if let image, sizeMatches {
            imageCache[key] = image
        }
        return image
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

// MARK: - DrawableImageContents

private class DrawableImageContents: CachedVectorImageContents {
    let _size: CGSize
    var _displayList: (any ORBDisplayListContents)?

    init(size: CGSize) {
        self._size = size
        self._displayList = nil
        super.init()
    }

    override var size: CGSize {
        _size
    }

    override var displayList: any ORBDisplayListContents {
        if let cached = _displayList {
            return cached
        }
        let list = ORBDisplayList()
        list.defaultColorSpace = .SRGB
        let context = list.beginCGContext(withAlpha: 1.0)
        draw(in: context)
        list.endCGContext()
        let contents = list.moveContents()!
        _displayList = contents
        return contents
    }
}

// MARK: - PDFImageContents

#if canImport(CoreGraphics) && OPENSWIFTUI_LINK_COREUI
private class PDFImageContents: DrawableImageContents {
    let page: CGPDFPage
    let catalog: CUICatalog?

    init(page: CGPDFPage, catalog: CUICatalog?, size: CGSize) {
        self.page = page
        self.catalog = catalog
        super.init(size: size)
    }

    override func draw(in context: CGContext) {
        context.saveGState()
        let rect = CGRect(origin: .zero, size: _size)
        let transform = page.getDrawingTransform(.cropBox, rect: rect, rotate: 0, preserveAspectRatio: true)
        context.concatenate(transform)
        context.drawPDFPage(page)
        context.restoreGState()
    }
}
#endif

// MARK: - SVGImageContents

#if canImport(CoreGraphics) && OPENSWIFTUI_LINK_COREUI
private class SVGImageContents: DrawableImageContents {
    let document: CGSVGDocument
    let catalog: CUICatalog?

    init(document: CGSVGDocument, catalog: CUICatalog?, size: CGSize) {
        self.document = document
        self.catalog = catalog
        super.init(size: size)
    }

    override func draw(in context: CGContext) {
        context.draw(document)
    }
}

extension CGContext {
    fileprivate func draw(_ document: CGSVGDocument) {
        CGContextDrawSVGDocument(self, document)
    }
}
#endif

// MARK: - DisplayListImageContents

package class DisplayListImageContents: CachedVectorImageContents {
    let _displayList: any ORBDisplayListContents
    let _size: CGSize

    package init(displayList: any ORBDisplayListContents, size: CGSize) {
        self._displayList = displayList
        self._size = size
        super.init()
    }

    package override var size: CGSize {
        _size
    }

    package override var displayList: any ORBDisplayListContents {
        _displayList
    }
}

// MARK: - CodableRBDisplayListContents [TODO] [Other]

package struct CodableRBDisplayListContents: ProtobufMessage {
    package var base: any ORBDisplayListContents

    package init(_ base: any ORBDisplayListContents) {
        self.base = base
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        // TODO: ArchiveWriter
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        // TODO: ArchiveReader
        _openSwiftUIUnimplementedFailure()
    }
}
