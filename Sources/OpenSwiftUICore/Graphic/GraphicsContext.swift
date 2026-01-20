//
//  GraphicsContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP

#if canImport(Darwin)
public import CoreGraphics
#else
public enum CGBlendMode: Int32, @unchecked Sendable {
    case normal = 0
    case multiply = 1
    case screen = 2
    case overlay = 3
    case darken = 4
    case lighten = 5
    case colorDodge = 6
    case colorBurn = 7
    case softLight = 8
    case hardLight = 9
    case difference = 10
    case exclusion = 11
    case hue = 12
    case saturation = 13
    case color = 14
    case luminosity = 15
    case clear = 16
    case copy = 17
    case sourceIn = 18
    case sourceOut = 19
    case sourceAtop = 20
    case destinationOver = 21
    case destinationIn = 22
    case destinationOut = 23
    case destinationAtop = 24
    case xor = 25
    case plusDarker = 26
    case plusLighter = 27
}
#endif

package enum PathDrawingStyle {
    case fill(FillStyle)
    case stroke(StrokeStyle)
}

/// An immediate mode drawing destination, and its current state.
///
/// Use a context to execute 2D drawing primitives. For example, you can draw
/// filled shapes using the ``fill(_:with:style:)`` method inside a ``Canvas``
/// view:
///
///     Canvas { context, size in
///         context.fill(
///             Path(ellipseIn: CGRect(origin: .zero, size: size)),
///             with: .color(.green))
///     }
///     .frame(width: 300, height: 200)
///
/// The example above draws an ellipse that just fits inside a canvas that's
/// constrained to 300 points wide and 200 points tall:
///
/// ![A screenshot of a view that shows a green ellipse.](GraphicsContext-1)
///
/// In addition to outlining or filling paths, you can draw images, text,
/// and OpenSwiftUI views. You can also use the context to perform many common
/// graphical operations, like adding masks, applying filters and
/// transforms, and setting a blend mode. For example you can add
/// a mask using the ``clip(to:style:options:)`` method:
///
///     let halfSize = size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
///     context.clip(to: Path(CGRect(origin: .zero, size: halfSize)))
///     context.fill(
///         Path(ellipseIn: CGRect(origin: .zero, size: size)),
///         with: .color(.green))
///
/// The rectangular mask hides all but one quadrant of the ellipse:
///
/// ![A screenshot of a view that shows the upper left quarter of a green
/// ellipse.](GraphicsContext-2)
///
/// The order of operations matters. Changes that you make to the state of
/// the context, like adding a mask or a filter, apply to later
/// drawing operations. If you reverse the fill and clip operations in
/// the example above, so that the fill comes first, the mask doesn't
/// affect the ellipse.
///
/// Each context references a particular layer in a tree of transparency layers,
/// and also contains a full copy of the drawing state. You can modify the
/// state of one context without affecting the state of any other, even if
/// they refer to the same layer. For example you can draw the masked ellipse
/// from the previous example into a copy of the main context, and then add a
/// rectangle into the main context:
///
///     // Create a copy of the context to draw a clipped ellipse.
///     var maskedContext = context
///     let halfSize = size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
///     maskedContext.clip(to: Path(CGRect(origin: .zero, size: halfSize)))
///     maskedContext.fill(
///         Path(ellipseIn: CGRect(origin: .zero, size: size)),
///         with: .color(.green))
///
///     // Go back to the original context to draw the rectangle.
///     let origin = CGPoint(x: size.width / 4, y: size.height / 4)
///     context.fill(
///         Path(CGRect(origin: origin, size: halfSize)),
///         with: .color(.blue))
///
/// The mask doesn't clip the rectangle because the mask isn't part of the
/// main context. However, both contexts draw into the same view because
/// you created one context as a copy of the other:
///
/// ![A screenshot of a view that shows the upper left quarter of a green
/// ellipse, overlaid by a blue rectangle centered in the
/// view.](GraphicsContext-3)
///
/// The context has access to an ``EnvironmentValues`` instance called
/// ``environment`` that's initially copied from the environment of its
/// enclosing view. OpenSwiftUI uses environment values --- like the display
/// resolution and color scheme --- to resolve types like ``Image`` and
/// ``Color`` that appear in the context. You can also access values stored
/// in the environment for your own purposes.
@available(OpenSwiftUI_v3_0, *)
@frozen
public struct GraphicsContext {
    @usableFromInline
    final class Storage {
        
    }
    
    var storage: Storage
    
    /// The ways that a graphics context combines new content with background
    /// content.
    ///
    /// Use one of these values to set the
    /// ``GraphicsContext/blendMode-swift.property`` property of a
    /// ``GraphicsContext``. The value that you set affects how content
    /// that you draw replaces or combines with content that you
    /// previously drew into the context.
    ///
    @frozen
    public struct BlendMode: RawRepresentable, Equatable {
        public let rawValue: Int32
        
        @inlinable
        public init(rawValue: Int32) { self.rawValue = rawValue }
        
        /// A mode that paints source image samples over the background image
        /// samples.
        ///
        /// This is the default blend mode.
        @inlinable
        public static var normal: BlendMode {
            self.init(rawValue: CGBlendMode.normal.rawValue)
        }
        
        /// A mode that multiplies the source image samples with the background
        /// image samples.
        ///
        /// Drawing in this mode results in colors that are at least as
        /// dark as either of the two contributing sample colors.
        @inlinable
        public static var multiply: BlendMode {
            self.init(rawValue: CGBlendMode.multiply.rawValue)
        }
        
        /// A mode that multiplies the inverse of the source image samples with
        /// the inverse of the background image samples.
        ///
        /// Drawing in this mode results in colors that are at least as light
        /// as either of the two contributing sample colors.
        @inlinable
        public static var screen: BlendMode {
            self.init(rawValue: CGBlendMode.screen.rawValue)
        }
        
        /// A mode that either multiplies or screens the source image samples
        /// with the background image samples, depending on the background
        /// color.
        ///
        /// Drawing in this mode overlays the existing image samples
        /// while preserving the highlights and shadows of the
        /// background. The background color mixes with the source
        /// image to reflect the lightness or darkness of the
        /// background.
        @inlinable
        public static var overlay: BlendMode {
            self.init(rawValue: CGBlendMode.overlay.rawValue)
        }
        
        /// A mode that creates composite image samples by choosing the darker
        /// samples from either the source image or the background.
        ///
        /// When you draw in this mode, source image samples that are darker
        /// than the background replace the background.
        /// Otherwise, the background image samples remain unchanged.
        @inlinable
        public static var darken: BlendMode {
            self.init(rawValue: CGBlendMode.darken.rawValue)
        }
        
        /// A mode that creates composite image samples by choosing the lighter
        /// samples from either the source image or the background.
        ///
        /// When you draw in this mode, source image samples that are lighter
        /// than the background replace the background.
        /// Otherwise, the background image samples remain unchanged.
        @inlinable
        public static var lighten: BlendMode {
            self.init(rawValue: CGBlendMode.lighten.rawValue)
        }
        
        /// A mode that brightens the background image samples to reflect the
        /// source image samples.
        ///
        /// Source image sample values that
        /// specify black do not produce a change.
        @inlinable
        public static var colorDodge: BlendMode {
            self.init(rawValue: CGBlendMode.colorDodge.rawValue)
        }

        /// A mode that darkens background image samples to reflect the source
        /// image samples.
        ///
        /// Source image sample values that specify
        /// white do not produce a change.
        @inlinable
        public static var colorBurn: BlendMode {
            self.init(rawValue: CGBlendMode.colorBurn.rawValue)
        }

        /// A mode that either darkens or lightens colors, depending on the
        /// source image sample color.
        ///
        /// If the source image sample color is
        /// lighter than 50% gray, the background is lightened, similar
        /// to dodging. If the source image sample color is darker than
        /// 50% gray, the background is darkened, similar to burning.
        /// If the source image sample color is equal to 50% gray, the
        /// background is not changed. Image samples that are equal to
        /// pure black or pure white produce darker or lighter areas,
        /// but do not result in pure black or white. The overall
        /// effect is similar to what you'd achieve by shining a
        /// diffuse spotlight on the source image. Use this to add
        /// highlights to a scene.
        @inlinable
        public static var softLight: BlendMode {
            self.init(rawValue: CGBlendMode.softLight.rawValue)
        }

        /// A mode that either multiplies or screens colors, depending on the
        /// source image sample color.
        ///
        /// If the source image sample color
        /// is lighter than 50% gray, the background is lightened,
        /// similar to screening. If the source image sample color is
        /// darker than 50% gray, the background is darkened, similar
        /// to multiplying. If the source image sample color is equal
        /// to 50% gray, the source image is not changed. Image samples
        /// that are equal to pure black or pure white result in pure
        /// black or white. The overall effect is similar to what you'd
        /// achieve by shining a harsh spotlight on the source image.
        /// Use this to add highlights to a scene.
        @inlinable
        public static var hardLight: BlendMode {
            self.init(rawValue: CGBlendMode.hardLight.rawValue)
        }

        /// A mode that subtracts the brighter of the source image sample color
        /// or the background image sample color from the other.
        ///
        /// Source image sample values that are black produce no change; white
        /// inverts the background color values.
        @inlinable
        public static var difference: BlendMode {
            self.init(rawValue: CGBlendMode.difference.rawValue)
        }

        /// A mode that produces an effect similar to that produced by the
        /// difference blend mode, but with lower contrast.
        ///
        /// Source image sample values that are black don't produce a change;
        /// white inverts the background color values.
        @inlinable
        public static var exclusion: BlendMode {
            self.init(rawValue: CGBlendMode.exclusion.rawValue)
        }

        /// A mode that uses the luminance and saturation values of the
        /// background with the hue of the source image.
        @inlinable
        public static var hue: BlendMode {
            self.init(rawValue: CGBlendMode.hue.rawValue)
        }

        /// A mode that uses the luminance and hue values of the background with
        /// the saturation of the source image.
        ///
        /// Areas of the background that have no saturation --- namely,
        /// pure gray areas --- don't produce a change.
        @inlinable
        public static var saturation: BlendMode {
            self.init(rawValue: CGBlendMode.saturation.rawValue)
        }

        /// A mode that uses the luminance values of the background with the hue
        /// and saturation values of the source image.
        ///
        /// This mode preserves the gray levels in the image. You can use this
        /// mode to color monochrome images or to tint color images.
        @inlinable
        public static var color: BlendMode {
            self.init(rawValue: CGBlendMode.color.rawValue)
        }

        /// A mode that uses the hue and saturation of the background with the
        /// luminance of the source image.
        ///
        /// This mode creates an effect that is inverse to the effect created
        /// by the ``color`` mode.
        @inlinable
        public static var luminosity: BlendMode {
            self.init(rawValue: CGBlendMode.luminosity.rawValue)
        }

        /// A mode that clears any pixels that the source image overwrites.
        ///
        /// With this mode, you can use the source image like an eraser.
        ///
        /// This mode implements the equation `R = 0` where
        /// `R` is the composite image.
        @inlinable
        public static var clear: BlendMode {
            self.init(rawValue: CGBlendMode.clear.rawValue)
        }

        /// A mode that replaces background image samples with source image
        /// samples.
        ///
        /// Unlike the ``normal`` mode, the source image completely replaces
        /// the background, so that even transparent pixels in the source image
        /// replace opaque pixels in the background, rather than letting the
        /// background show through.
        ///
        /// This mode implements the equation `R = S` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        @inlinable
        public static var copy: BlendMode {
            self.init(rawValue: CGBlendMode.copy.rawValue)
        }

        /// A mode that you use to paint the source image, including
        /// its transparency, onto the opaque parts of the background.
        ///
        /// This mode implements the equation `R = S*Da` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `Da` is the source background's alpha value.
        @inlinable
        public static var sourceIn: BlendMode {
            self.init(rawValue: CGBlendMode.sourceIn.rawValue)
        }

        /// A mode that you use to paint the source image onto the
        /// transparent parts of the background, while erasing the background.
        ///
        /// This mode implements the equation `R = S*(1 - Da)` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `Da` is the source background's alpha value.
        @inlinable
        public static var sourceOut: BlendMode {
            self.init(rawValue: CGBlendMode.sourceOut.rawValue)
        }

        /// A mode that you use to paint the opaque parts of the
        /// source image onto the opaque parts of the background.
        ///
        /// This mode implements the equation `R = S*Da + D*(1 - Sa)` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `D` is the background.
        /// * `Sa` is the source image's alpha value.
        /// * `Da` is the source background's alpha value.
        @inlinable
        public static var sourceAtop: BlendMode {
            self.init(rawValue: CGBlendMode.sourceAtop.rawValue)
        }

        /// A mode that you use to paint the source image under
        /// the background.
        ///
        /// This mode implements the equation `R = S*(1 - Da) + D` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `D` is the background.
        /// * `Da` is the source background's alpha value.
        @inlinable
        public static var destinationOver: BlendMode {
            self.init(rawValue: CGBlendMode.destinationOver.rawValue)
        }

        /// A mode that you use to erase any of the background that
        /// isn't covered by opaque source pixels.
        ///
        /// This mode implements the equation `R = D*Sa` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `Da` is the source background's alpha value.
        @inlinable
        public static var destinationIn: BlendMode {
            self.init(rawValue: CGBlendMode.destinationIn.rawValue)
        }

        /// A mode that you use to erase any of the background that
        /// is covered by opaque source pixels.
        ///
        /// This mode implements the equation `R = D*(1 - Sa)` where
        /// * `R` is the composite image.
        /// * `D` is the background.
        /// * `Sa` is the source image's alpha value.
        @inlinable
        public static var destinationOut: BlendMode {
            self.init(rawValue: CGBlendMode.destinationOut.rawValue)
        }

        /// A mode that you use to paint the source image under
        /// the background, while erasing any of the background not matched
        /// by opaque pixels from the source image.
        ///
        /// This mode implements the equation `R = S*(1 - Da) + D*Sa` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `D` is the background.
        /// * `Sa` is the source image's alpha value.
        /// * `Da` is the source background's alpha value.
        @inlinable
        public static var destinationAtop: BlendMode {
            self.init(rawValue: CGBlendMode.destinationAtop.rawValue)
        }

        /// A mode that you use to clear pixels where both the source and
        /// background images are opaque.
        ///
        /// This mode implements the equation `R = S*(1 - Da) + D*(1 - Sa)` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `D` is the background.
        /// * `Sa` is the source image's alpha value.
        /// * `Da` is the source background's alpha value.
        ///
        /// This XOR mode is only nominally related to the classical bitmap
        /// XOR operation, which OpenSwiftUI doesn't support.
        @inlinable
        public static var xor: BlendMode {
            self.init(rawValue: CGBlendMode.xor.rawValue)
        }

        /// A mode that adds the inverse of the color components of the source
        /// and background images, and then inverts the result, producing
        /// a darkened composite.
        ///
        /// This mode implements the equation `R = MAX(0, 1 - ((1 - D) + (1 - S)))` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `D` is the background.
        @inlinable
        public static var plusDarker: BlendMode {
            self.init(rawValue: CGBlendMode.plusDarker.rawValue)
        }

        /// A mode that adds the components of the source and background images,
        /// resulting in a lightened composite.
        ///
        /// This mode implements the equation `R = MIN(1, S + D)` where
        /// * `R` is the composite image.
        /// * `S` is the source image.
        /// * `D` is the background.
        @inlinable
        public static var plusLighter: BlendMode {
            self.init(rawValue: CGBlendMode.plusLighter.rawValue)
        }
    }

    // MARK: - GraphicsContext.ClipOptions

    /// Options that affect the use of clip shapes.
    ///
    /// Use these options to affect how OpenSwiftUI interprets a clip shape
    /// when you call ``clip(to:style:options:)`` to add a path to the array of
    /// clip shapes, or when you call ``clipToLayer(opacity:options:content:)``
    /// to add a clipping layer.
    @frozen
    public struct ClipOptions: OptionSet {
        public let rawValue: UInt32

        @inlinable
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// An option to invert the shape or layer alpha as the clip mask.
        ///
        /// When you use this option, OpenSwiftUI uses `1 - alpha` instead of
        /// `alpha` for the given clip shape.
        @inlinable
        public static var inverse: ClipOptions { Self(rawValue: 1 << 0) }
    }

    // FIXME
    package enum ResolvedShading: Sendable {
        case backdrop(Color.Resolved)
        case color(Color.Resolved)
        case style(_ShapeStyle_Pack.Style)
        case levels([GraphicsContext.ResolvedShading])
    }
}

extension GraphicsContext {
    package func draw(_ path: Path, with shading: GraphicsContext.ResolvedShading, style: PathDrawingStyle) {
        _openSwiftUIUnimplementedFailure()
    }

    // FIXME
    #if canImport(CoreGraphics)
    static func renderingTo(
        cgContext: CGContext,
        environment: EnvironmentValues,
        deviceScale: CGFloat?,
        content: (inout GraphicsContext) -> ()
    ) {
        _openSwiftUIUnimplementedFailure()
    }
    #endif
}
