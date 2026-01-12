//
//  ResolvedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: A3C1DB6976F54697C11EFA754256BBD1 (SwiftUICore)

package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

extension Image {
    // MARK: - Image.LayoutMetrics [WIP]

    package struct LayoutMetrics: Equatable {
        package var baselineOffset: CGFloat

        package var capHeight: CGFloat

        package var contentSize: CGSize

        package var alignmentOrigin: CGPoint

        package var backgroundSize: CGSize

        package init(
            baselineOffset: CGFloat,
            capHeight: CGFloat,
            contentSize: CGSize,
            alignmentOrigin: CGPoint
        ) {
            self.baselineOffset = baselineOffset
            self.capHeight = capHeight
            self.contentSize = contentSize
            self.alignmentOrigin = alignmentOrigin
            self.backgroundSize = .zero
        }

        // TODO: CUINamedVectorGlyph
    }

    // MARK: - Image.Resolved [WIP]

    package struct Resolved: Equatable {
        package var image: GraphicsImage {
            didSet {
                _openSwiftUIUnimplementedWarning()
            }
        }

        package var label: AccessibilityImageLabel?

        @EquatableOptionalObject
        package var basePlatformItemImage: AnyObject?

        @IndirectOptional
        package var layoutMetrics: Image.LayoutMetrics?

        package var decorative: Bool

        package var backgroundShape: SymbolVariants.Shape?

        package var backgroundCornerRadius: Float?

        package var styleResolverMode: _ShapeStyle_ResolverMode

        package init(
            image: GraphicsImage,
            decorative: Bool,
            label: AccessibilityImageLabel?,
            basePlatformItemImage: AnyObject? = nil,
            backgroundShape: SymbolVariants.Shape? = nil,
            backgroundCornerRadius: CGFloat? = nil
        ) {
            _openSwiftUIUnimplementedFailure()
        }

        package var size: CGSize {
            _openSwiftUIUnimplementedFailure()
        }

        package var baselineOffset: CGFloat {
            _openSwiftUIUnimplementedFailure()
        }

        package var capHeight: CGFloat {
            _openSwiftUIUnimplementedFailure()
        }

        package var contentSize: CGSize {
            _openSwiftUIUnimplementedFailure()
        }

        package var alignmentOrigin: CGPoint {
            _openSwiftUIUnimplementedFailure()
        }

        package func foregroundColor(_ color: () -> Color.Resolved) -> Image.Resolved {
            _openSwiftUIUnimplementedFailure()
        }

        package static func == (a: Image.Resolved, b: Image.Resolved) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }
    }

    // MARK: - Image.NamedResolved [TODO]

    package struct NamedResolved {
        package var name: String

        package var location: Image.Location

        package var value: Float?

        package var symbolRenderingMode: SymbolRenderingMode.Storage?

        package var isTemplate: Bool

        package var environment: EnvironmentValues
    }
}

extension Image.Resolved: UnaryView, PrimitiveView, ShapeStyledLeafView, LeafViewLayout {
    package struct UpdateData {}

    package mutating func mustUpdate(data: Image.Resolved.UpdateData, position: Attribute<ViewOrigin>) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func frame(in size: CGSize) -> CGRect {
        _openSwiftUIUnimplementedFailure()
    }

    package func shape(in size: CGSize) -> Image.Resolved.FramedShape {
        _openSwiftUIUnimplementedFailure()
    }

    package static var hasBackground: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func backgroundShape(in size: CGSize) -> Image.Resolved.FramedShape {
        _openSwiftUIUnimplementedFailure()
    }

    package func isClear(styles: _ShapeStyle_Pack) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    nonisolated package static func _makeView(view: _GraphValue<Image.Resolved>, inputs: _ViewInputs) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v1_0, *)
    package typealias Body = Never

    @available(OpenSwiftUI_v1_0, *)
    package typealias ShapeUpdateData = Image.Resolved.UpdateData
}

//extension Image.Resolved: InterpolatableContent {
//    package static var defaultTransition: ContentTransition {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    package func modifyTransition(state: inout ContentTransition.State, to other: Image.Resolved) {
//        _openSwiftUIUnimplementedFailure()
//    }
//}

extension EnvironmentValues {
    package func imageIsTemplate(renderingMode: Image.TemplateRenderingMode? = nil) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Image.Resolved: ImageProvider {
    package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveNamedImage(in _: ImageResolutionContext) -> Image.NamedResolved? {
        _openSwiftUIUnimplementedFailure()
    }
}
