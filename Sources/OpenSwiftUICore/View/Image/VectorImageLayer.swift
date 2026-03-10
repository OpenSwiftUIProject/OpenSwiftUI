//
//  VectorImageLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 988D5168E40F7399F12C543D2EE9C5E9 (SwiftUICore)

public import Foundation
#if OPENSWIFTUI_LINK_COREUI
package import CoreUI
#endif
@_spiOnly public import OpenRenderBoxShims
public import OpenCoreGraphicsShims

// MARK: - VectorImageLayer [WIP]

package struct VectorImageLayer: Hashable {
    package var contents: VectorImageContents
    var location: Image.Location?
    var name: String?

    package init(_ contents: VectorImageContents) {
        self.contents = contents
        self.location = nil
        self.name = nil
    }

    #if OPENSWIFTUI_LINK_COREUI
    package init?(image: CUINamedVectorImage, location: Image.Location, size: CGSize) {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    #if canImport(CoreGraphics)
    package init(pdfPage: CGPDFPage, size: CGSize) {
        _openSwiftUIUnimplementedFailure()
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

// TODO: RB
