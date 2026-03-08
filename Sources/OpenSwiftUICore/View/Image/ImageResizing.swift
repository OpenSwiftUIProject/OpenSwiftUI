//
//  ImageResizing.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - Image + Resizable

@available(OpenSwiftUI_v1_0, *)
extension Image {

    /// The modes that OpenSwiftUI uses to resize an image to fit within
    /// its containing view.
    public enum ResizingMode : Sendable {

        /// A mode to repeat the image at its original size, as many
        /// times as necessary to fill the available space.
        case tile

        /// A mode to enlarge or reduce the size of an image so that it
        /// fills the available space.
        case stretch
    }

    /// Sets the mode by which OpenSwiftUI resizes an image to fit its space.
    /// - Parameters:
    ///   - capInsets: Inset values that indicate a portion of the image that
    ///   OpenSwiftUI doesn't resize.
    ///   - resizingMode: The mode by which OpenSwiftUI resizes the image.
    /// - Returns: An image, with the new resizing behavior set.
    public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> Image {
        Image(
            ResizableProvider(
                base: self,
                capInsets: capInsets,
                resizingMode: resizingMode
            )
        )
    }

    package struct ResizingInfo: Equatable {
        package var capInsets: EdgeInsets

        package var mode: Image.ResizingMode

        package static let resizable: Image.ResizingInfo = .init(capInsets: .zero, mode: .stretch)

        package init(capInsets: EdgeInsets, mode: Image.ResizingMode) {
            self.capInsets = capInsets
            self.mode = mode
        }
    }

    package struct ResizableProvider: ImageProvider {
        package var base: Image

        package var capInsets: EdgeInsets

        package var resizingMode: Image.ResizingMode

        package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
            var resolved = base.resolve(in: context)
            resolved.image.resizingInfo = ResizingInfo(capInsets: capInsets, mode: resizingMode)
            return resolved
        }

        package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
            base.resolveNamedImage(in: context)
        }
    }
}

// MARK: - Image.ResizingInfo + ProtobufMessage

extension Image.ResizingInfo: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, mode, defaultValue: .stretch)
        try encoder.messageField(2, capInsets, defaultValue: .zero)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var mode: Image.ResizingMode?
        var capInsets: EdgeInsets = .zero
        while let field = try decoder.nextField() {
            let tag = field.tag
            switch tag {
            case 1: mode = try decoder.enumField(field)
            case 2: capInsets = try decoder.messageField(field)
            default:
                try decoder.skipField(field)
            }
        }
        self.init(capInsets: capInsets, mode: mode ?? .stretch)
    }
}

// MARK: - Image.ResizingMode + ProtobufEnum

extension Image.ResizingMode: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .tile: 1
        case .stretch: 0
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .stretch
        case 1: self = .tile
        default: return nil
        }
    }
}
