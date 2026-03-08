//
//  ImageRenderingMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6CBDCABF463BFE9CC4C20C83C3F5C7C1 (SwiftUICore)

// MARK: - Image + renderingMode

@available(OpenSwiftUI_v1_0, *)
extension Image {

    /// Indicates whether OpenSwiftUI renders an image as-is, or
    /// by using a different mode.
    ///
    /// The ``TemplateRenderingMode`` enumeration has two cases:
    /// ``TemplateRenderingMode/original`` and ``TemplateRenderingMode/template``.
    /// The original mode renders pixels as they appear in the original source
    /// image. Template mode renders all nontransparent pixels as the
    /// foreground color, which you can use for purposes like creating image
    /// masks.
    ///
    /// The following example shows both rendering modes, as applied to an icon
    /// image of a green circle with darker green border:
    ///
    ///     Image("dot_green")
    ///         .renderingMode(.original)
    ///     Image("dot_green")
    ///         .renderingMode(.template)
    ///
    /// ![Two identically-sized circle images. The circle on top is green
    /// with a darker green border. The circle at the bottom is a solid color,
    /// either white on a black background, or black on a white background,
    /// depending on the system's current dark mode
    /// setting.](OpenSwiftUI-Image-TemplateRenderingMode-dots.png)
    ///
    /// You also use `renderingMode` to produce multicolored system graphics
    /// from the SF Symbols set. Use the ``TemplateRenderingMode/original``
    /// mode to apply a foreground color to all parts of the symbol except
    /// those that have a distinct color in the graphic. The following
    /// example shows three uses of the `person.crop.circle.badge.plus` symbol
    /// to achieve different effects:
    ///
    /// * A default appearance with no foreground color or template rendering
    /// mode specified. The symbol appears all black in light mode, and all
    /// white in Dark Mode.
    /// * The multicolor behavior achieved by using `original` template
    /// rendering mode, along with a blue foreground color. This mode causes the
    /// graphic to override the foreground color for distinctive parts of the
    /// image, in this case the plus icon.
    /// * A single-color template behavior achieved by using `template`
    /// rendering mode with a blue foreground color. This mode applies the
    /// foreground color to the entire image, regardless of the user's Appearance preferences.
    ///
    ///```swift
    ///HStack {
    ///    Image(systemName: "person.crop.circle.badge.plus")
    ///    Image(systemName: "person.crop.circle.badge.plus")
    ///        .renderingMode(.original)
    ///        .foregroundColor(.blue)
    ///    Image(systemName: "person.crop.circle.badge.plus")
    ///        .renderingMode(.template)
    ///        .foregroundColor(.blue)
    ///}
    ///.font(.largeTitle)
    ///```
    ///
    /// ![A horizontal layout of three versions of the same symbol: a person
    /// icon in a circle with a plus icon overlaid at the bottom left. Each
    /// applies a diffent set of colors based on its rendering mode, as
    /// described in the preceding
    /// list.](OpenSwiftUI-Image-TemplateRenderingMode-sfsymbols.png)
    ///
    /// Use the SF Symbols app to find system images that offer the multicolor
    /// feature. Keep in mind that some multicolor symbols use both the
    /// foreground and accent colors.
    ///
    /// - Parameter renderingMode: The mode OpenSwiftUI uses to render images.
    /// - Returns: A modified ``Image``.
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Image {
        Image(
            RenderingModeProvider(
                base: self,
                renderingMode: renderingMode
            )
        )
    }

    // MARK: - RenderingModeProvider

    private struct RenderingModeProvider: ImageProvider {
        var base: Image

        var renderingMode: Image.TemplateRenderingMode?

        func resolve(in context: ImageResolutionContext) -> Image.Resolved {
            var context = context
            if !context.environment.imageIsTemplate(renderingMode: renderingMode),
               context.symbolRenderingMode == nil {
                context.symbolRenderingMode = .multicolor
            }
            var resolved = base.resolve(in: context)
            switch resolved.image.contents {
            case .vectorGlyph:
                break
            default:
                resolved.image.maskColor = context.environment.imageIsTemplate(renderingMode: renderingMode) ? .white : nil
            }
            return resolved
        }

        func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
            var context = context
            if !context.environment.imageIsTemplate(renderingMode: renderingMode),
               context.symbolRenderingMode == nil {
                context.symbolRenderingMode = .multicolor
            }
            guard var resolved = base.resolveNamedImage(in: context) else { return nil }
            resolved.isTemplate = context.environment.imageIsTemplate(renderingMode: renderingMode)
            return resolved
        }
    }
}
