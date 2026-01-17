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

    // MARK: - Image.Resolved

    package struct Resolved: Equatable {
        package var image: GraphicsImage {
            didSet {
                var newMode = image.styleResolverMode
                newMode.options.setValue(styleResolverMode.options.contains(.background), for: .background)
                styleResolverMode = newMode
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

        package var styleResolverMode: ShapeStyle.ResolverMode

        package init(
            image: GraphicsImage,
            decorative: Bool,
            label: AccessibilityImageLabel?,
            basePlatformItemImage: AnyObject? = nil,
            backgroundShape: SymbolVariants.Shape? = nil,
            backgroundCornerRadius: CGFloat? = nil
        ) {
            self.image = image
            self.label = label
            self.basePlatformItemImage = basePlatformItemImage
            self.decorative = decorative
            self.backgroundShape = backgroundShape
            self.backgroundCornerRadius = backgroundCornerRadius.map { Float($0) }
            self.styleResolverMode = image.styleResolverMode
        }

        package var size: CGSize {
            image.size
        }

        package var baselineOffset: CGFloat {
            guard let layoutMetrics else {
                return .zero
            }
            return layoutMetrics.baselineOffset
        }

        package var capHeight: CGFloat {
            guard let layoutMetrics else {
                return size.height
            }
            return layoutMetrics.capHeight
        }

        package var contentSize: CGSize {
            guard let layoutMetrics else {
                return size
            }
            return layoutMetrics.contentSize
        }

        package var alignmentOrigin: CGPoint {
            guard let layoutMetrics else {
                return .zero
            }
            return layoutMetrics.alignmentOrigin
        }

        package func foregroundColor(_ color: () -> Color.Resolved) -> Image.Resolved {
            var resolved = self
            if image.maskColor == nil {
                resolved.image.maskColor = color()
            }
            return resolved
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

// MARK: - Image.Resolved + View

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
        (renderingMode ?? defaultRenderingMode) == .template
    }
}

// MARK: - Image.Resolved + ImageProvider

extension Image.Resolved: ImageProvider {
    package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        self
    }

    package func resolveNamedImage(in _: ImageResolutionContext) -> Image.NamedResolved? {
        nil
    }
}
