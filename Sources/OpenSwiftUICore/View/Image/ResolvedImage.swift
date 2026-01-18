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

// MARK: - Image.Resolved + View [mustUpdate & _makeView WIP]

extension Image.Resolved: UnaryView, PrimitiveView, ShapeStyledLeafView, LeafViewLayout {
    package struct UpdateData {
        @Attribute var time: Time
        @Attribute var position: ViewOrigin
        @Attribute var size: ViewSize
        @Attribute var pixelLength: CGFloat
    }

    package mutating func mustUpdate(
        data: Image.Resolved.UpdateData,
        position: Attribute<ViewOrigin>
    ) -> Bool {
        guard case let .vectorGlyph(resolvedVectorGlyph) = image.contents else {
            return false
        }
        // TODO: ResolvedVectorGlyph
        _openSwiftUIUnimplementedWarning()
        return false
    }

    package func frame(in size: CGSize) -> CGRect {
        guard image.resizingInfo == nil else {
            return CGRect(origin: .zero, size: size)
        }
        return CGRect(
            origin: layoutMetrics?.alignmentOrigin ?? .zero,
            size: self.size
        )
    }

    package func shape(in size: CGSize) -> Image.Resolved.FramedShape {
        (.image(image), frame(in: size))
    }

    package static var hasBackground: Bool {
        true
    }

    package func backgroundShape(in size: CGSize) -> Image.Resolved.FramedShape {
        guard let backgroundShape, let layoutMetrics else {
            return (.empty, .zero)
        }
        let backgroundSize = layoutMetrics.backgroundSize
        let contentSize = layoutMetrics.contentSize
        let size = CGSize(
            width: backgroundSize.width * (size.width / contentSize.width),
            height: backgroundSize.height * (size.height / contentSize.height)
        )
        let rect = CGRect(origin: .zero, size: size)
        let path = backgroundShape.path(in: rect, cornerRadius: backgroundCornerRadius)
        return (.path(path, .init()), rect)
    }

    package func isClear(styles: ShapeStyle.Pack) -> Bool {
        switch image.contents {
        case let .vectorGlyph(resolvedVectorGlyph):
            return resolvedVectorGlyph.isClear(styles: styles) && styles.isClear(name: .background)
        default:
            return image.isTemplate && styles.isClear(name: .foreground) && styles.isClear(name: .background)
        }
    }

    package func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize {
        guard let resizingInfo = image.resizingInfo else {
            return contentSize
        }
        let capInsets = resizingInfo.capInsets
        let width = proposedSize.width.map { max($0, capInsets.horizontal) }
        let height = proposedSize.height.map { max($0, capInsets.vertical) }
        return CGSize(width: width ?? size.width, height: height ?? size.height)
    }

    nonisolated package static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        let imageLayoutAsText: Bool
        if inputs.requestsLayoutComputer, Semantics.ImagesLayoutAsText.isEnabled {
            imageLayoutAsText = true
            newInputs.requestsLayoutComputer = false
        } else {
            imageLayoutAsText = false
        }
        var outputs: _ViewOutputs
        if inputs.preferences.requiresDisplayList {
            let pixelLength = inputs.pixelLength
            if inputs.archivedView.isArchived {
                // TODO: ContentTransitionEffect
                _openSwiftUIUnimplementedFailure()
            } else {
                let group = _ShapeStyle_InterpolatorGroup()
                newInputs.containerPosition = inputs.animatedPosition()
                let shapeStyles = inputs.resolvedShapeStyles(
                    role: .stroke,
                    mode: view.value.styleResolverMode
                )
                let data = UpdateData(
                    time: inputs.time,
                    position: inputs.position,
                    size: inputs.size,
                    pixelLength: pixelLength
                )
                outputs = makeLeafView(
                    view: view,
                    inputs: newInputs,
                    styles: shapeStyles,
                    interpolatorGroup: group,
                    data: data
                )
                outputs.applyInterpolatorGroup(
                    group,
                    content:view.value,
                    inputs: inputs,
                    animatesSize: true,
                    defersRender: false
                )
            }
        } else {
            outputs = .init()
        }
        if imageLayoutAsText {
            outputs.layoutComputer = Attribute(
                ResolvedImageLayoutComputer(image: view.value)
            )
        } else {
            makeLeafLayout(&outputs, view: view, inputs: newInputs)
        }
        if let representation = inputs.requestedImageRepresentation,
           representation.shouldMakeRepresentation(inputs: inputs) {
            let context = Attribute(
                MakeRepresentableContext(
                    image: view.value,
                    tintColor: inputs.tintColor,
                    foregroundStlye: inputs.foregroundStyle
                )
            )
            representation.makeRepresentation(
                inputs: inputs,
                context: context,
                outputs: &outputs
            )
        }
        return outputs
    }

    private struct MakeRepresentableContext: Rule, AsyncAttribute {
        @Attribute var image: Image.Resolved
        @Attribute var tintColor: Color?
        @Attribute var foregroundStlye: AnyShapeStyle?

        var value: PlatformImageRepresentableContext {
            PlatformImageRepresentableContext(
                image: image,
                tintColor: tintColor,
                foregroundStyle: foregroundStlye
            )
        }
    }
}

// MARK: - ResolvedImageLayoutComputer

private struct ResolvedImageLayoutComputer: StatefulRule, AsyncAttribute {
    @Attribute var image: Image.Resolved

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let engine = ResolvedImageLayoutEngine(image: image)
        update(to: engine)
    }
}

// MARK: - ResolvedImageLayoutEngine

private struct ResolvedImageLayoutEngine: LayoutEngine {
    var image: Image.Resolved

    func spacing() -> Spacing {
        guard image.image.resizingInfo == nil,
              let layoutMetrics = image.layoutMetrics,
              image.backgroundShape == nil else {
            return .init()
        }
        let baselineOffset = layoutMetrics.baselineOffset
        let alignmentOriginY = layoutMetrics.alignmentOrigin.y
        let sum = baselineOffset + alignmentOriginY
        return Spacing(minima: [
            .init(category: .textToText, edge: .top): .distance(0),
            .init(category: .textToText, edge: .bottom): .distance(0),
            .init(category: .edgeAboveText, edge: .top): .distance(baselineOffset),
            .init(category: .edgeBelowText, edge: .bottom): .distance(baselineOffset + 1.0),
            .init(category: .textBaseline, edge: .bottom): .distance(-sum),
            .init(category: .textBaseline, edge: .top): .distance(-(layoutMetrics.contentSize.height - sum)),
        ])
    }

    func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        image.sizeThatFits(in: proposedSize)
    }

    func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat {
        image.sizeThatFits(in: proposal)[axis]
    }

    func explicitAlignment(
        _ k: AlignmentKey,
        at viewSize: ViewSize
    ) -> CGFloat? {
        guard image.image.resizingInfo == nil,
              let layoutMetrics = image.layoutMetrics else {
            return nil
        }
        let baselineOffset = layoutMetrics.baselineOffset
        let alignmentOriginY = layoutMetrics.alignmentOrigin.y
        let baseline = viewSize.height - baselineOffset - alignmentOriginY
        if VerticalAlignment.lastTextBaseline.key == k {
            return baseline
        } else if VerticalAlignment.firstTextBaseline.key == k {
            return baseline
        } else if VerticalAlignment._firstTextLineCenter.key == k {
            return baseline - layoutMetrics.capHeight / 2
        } else {
            return nil
        }
    }
}

// MARK: - Image.Resolved + InterpolatableContent [WIP]

extension Image.Resolved: InterpolatableContent {
    package static var defaultTransition: ContentTransition {
        isLinkedOnOrAfter(.v4) ? .interpolate : .identity
    }

    package func modifyTransition(
        state: inout ContentTransition.State,
        to other: Image.Resolved
    ) {
        _openSwiftUIUnimplementedWarning()
    }
}

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
