//
//  Text+Image.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A6FE71E8A6E76FC7E51CBB0D97E0D052 (SwiftUICore)

// MARK: - Text + Image

@available(OpenSwiftUI_v2_0, *)
extension Text {
    /// Creates an instance that wraps an `Image`, suitable for concatenating
    /// with other `Text`
    @available(OpenSwiftUI_v2_0, *)
    public init(_ image: Image) {
        self.init(anyTextStorage: AttachmentTextStorage(image: image))
    }
}

// MARK: - LocalizedStringKey.StringInterpolation + Image

@available(OpenSwiftUI_v2_0, *)
extension LocalizedStringKey.StringInterpolation {
    /// Appends an image to a string interpolation.
    ///
    /// Don't call this method directly; it's used by the compiler when
    /// interpreting string interpolations.
    ///
    /// - Parameter image: The image to append.
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(_ image: Image) {
        appendInterpolation(Text(image))
    }
}

// MARK: - AttachmentTextStorage

final private class AttachmentTextStorage: AnyTextStorage, @unchecked Sendable {
    let image: Image

    init(image: Image) {
        self.image = image
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        let context = ImageResolutionContext(
            environment: environment,
            textStyle: result.style
        )
        guard resolveAndWriteAuxiliaryMetadataIfNeeded(
            into: &result,
            context: context,
            environment: environment,
            options: options
        ) else {
            result.append(
                image.resolve(in: context),
                in: environment,
                with: options
            )
            return
        }
    }

    override func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        false
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? AttachmentTextStorage else {
            return false
        }
        return image == other.image
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        true
    }

    func resolveAndWriteAuxiliaryMetadataIfNeeded<T>(
        into result: inout T,
        context: ImageResolutionContext,
        environment: EnvironmentValues,
        options: Text.ResolveOptions
    ) -> Bool where T: ResolvedTextContainer {
        guard options.contains(.writeAuxiliaryMetadata),
              let image = image.resolveNamedImage(in: context)
        else {
            return false
        }
        result.append(
            image,
            in: environment,
            with: options
        )
        return true
    }
}
