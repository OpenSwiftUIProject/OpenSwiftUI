//
//  Image.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by ImageResolutionContext and View
//  ID: BE2D783904D422377BBEBAC3C942583C (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - Image

/// A view that displays an image.
///
/// Use an `Image` instance when you want to add images to your OpenSwiftUI app.
/// You can create images from many sources:
///
/// * Image files in your app's asset library or bundle. Supported types include
/// PNG, JPEG, HEIC, and more.
/// * Instances of platform-specific image types, like
/// [UIImage](https://developer.apple.com/documentation/uikit/uiimage) and
/// [NSImage](https://developer.apple.com/documentation/appkit/nsimage).
/// * A bitmap stored in a Core Graphics
/// [CGImage](https://developer.apple.com/documentation/coregraphics/cgimage)
///  instance.
/// * System graphics from the SF Symbols set.
///
/// The following example shows how to load an image from the app's asset
/// library or bundle and scale it to fit within its container:
///
///     Image("Landscape_4")
///         .resizable()
///         .aspectRatio(contentMode: .fit)
///     Text("Water wheel")
///
/// ![An image of a water wheel and its adjoining building, resized to fit the
/// width of an iPhone display. The words Water wheel appear under this
/// image.](Image-1.png)
///
/// You can use methods on the `Image` type as well as
/// standard view modifiers to adjust the size of the image to fit your app's
/// interface. Here, the `Image` type's
/// ``Image/resizable(capInsets:resizingMode:)`` method scales the image to fit
/// the current view. Then, the
/// ``View/aspectRatio(_:contentMode:)`` view modifier adjusts
/// this resizing behavior to maintain the image's original aspect ratio, rather
/// than scaling the x- and y-axes independently to fill all four sides of the
/// view. The article
/// <doc:Fitting-Images-into-Available-Space> shows how to apply scaling,
/// clipping, and tiling to `Image` instances of different sizes.
///
/// An `Image` is a late-binding token; the system resolves its actual value
/// only when it's about to use the image in an environment.
///
/// ### Making images accessible
///
/// To use an image as a control, use one of the initializers that takes a
/// `label` parameter. This allows the system's accessibility frameworks to use
/// the label as the name of the control for users who use features like
/// VoiceOver. For images that are only present for aesthetic reasons, use an
/// initializer with the `decorative` parameter; the accessibility systems
/// ignore these images.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Image: Equatable, Sendable {
    package var provider: AnyImageProviderBox

    package init<P>(_ provider: P) where P: ImageProvider {
        self.provider = ImageProviderBox(base: provider)
    }

    package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        provider.resolve(in: context)
    }

    package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        provider.resolveNamedImage(in: context)
    }

    public static func == (lhs: Image, rhs: Image) -> Bool {
        lhs.provider.isEqual(to: rhs.provider)
    }
}

// MARK: - ImageResolutionContext [WIP]

package struct ImageResolutionContext {
    package struct Options: OptionSet {
        package let rawValue: UInt8

        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        package static let inferSymbolRenderingMode: ImageResolutionContext.Options = .init(rawValue: 1 << 0)

        package static let isArchived: ImageResolutionContext.Options = .init(rawValue: 1 << 1)

        package static let useCatalogReferences: ImageResolutionContext.Options = .init(rawValue: 1 << 2)

        package static let animationsDisabled: ImageResolutionContext.Options = .init(rawValue: 1 << 3)

        package static let preservesVectors: ImageResolutionContext.Options = .init(rawValue: 1 << 4)
    }

    package var environment: EnvironmentValues

//    package var symbolAnimator: RBSymbolAnimator?

    package var textStyle: Text.Style?

    package var transaction: OptionalAttribute<Transaction>

    package var symbolRenderingMode: SymbolRenderingMode?

    package var allowedDynamicRange: Image.DynamicRange?

    package var options: ImageResolutionContext.Options

    package init(
        environment: EnvironmentValues,
        textStyle: Text.Style? = nil,
        transaction: OptionalAttribute<Transaction> = .init()
    ) {
        _openSwiftUIUnimplementedFailure()
    }

//    package var effectiveAllowedDynamicRange: Image.DynamicRange? {
//        _openSwiftUIUnimplementedFailure()
//    }
}

// MARK: - ImageProvider

package protocol ImageProvider: Equatable {
    func resolve(in context: ImageResolutionContext) -> Image.Resolved

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved?
}

// MARK: - Image + View [WIP]

package protocol ImageStyleProtocol {
    static func _makeImageView(view: _GraphValue<Image>, inputs: _ViewInputs) -> _ViewOutputs
}

@available(OpenSwiftUI_v1_0, *)
extension Image: View, UnaryView, PrimitiveView {
    package struct Style: ViewInput {
        package static let defaultValue: Stack<any ImageStyleProtocol.Type> = .empty
    }

    nonisolated public static func _makeView(view: _GraphValue<Image>, inputs: _ViewInputs) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ImageProviderBox

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnyImageProviderBox: @unchecked Sendable {
    func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnyImageProviderBox) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

final package class ImageProviderBox<Base>: AnyImageProviderBox, @unchecked Sendable where Base: ImageProvider {
    package let base: Base

    init(base: Base) {
        self.base = base
    }

    override func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        base.resolve(in: context)
    }

    override func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        base.resolveNamedImage(in: context)
    }

    override func isEqual(to other: AnyImageProviderBox) -> Bool {
        guard let other = (other as? ImageProviderBox<Base>) else {
            return false
        }
        return base == other.base
    }
}
