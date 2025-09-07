//
//  VariableBlurStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 6.5.4
//  Status: Complete

package import Foundation

package struct VariableBlurStyle: Equatable {
    package enum Mask: Equatable {
        case none
        case image(GraphicsImage)
    }

    package var radius: CGFloat
    package var isOpaque: Bool
    package var dither: Bool
    package var mask: VariableBlurStyle.Mask

    package init(
        radius: CGFloat = 0,
        isOpaque: Bool = false,
        dither: Bool = false,
        mask: VariableBlurStyle.Mask = .none
    ) {
        self.radius = radius
        self.isOpaque = isOpaque
        self.dither = dither
        self.mask = mask
    }

    package var caFilterRadius: CGFloat {
        get { radius * 0.5 }
        set { radius = newValue / 0.5 }
    }

    package var isIdentity: Bool {
        radius <= 0.0 || mask == .none
    }
}

extension VariableBlurStyle: RendererEffect {
    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .filter(.variableBlur(self))
    }
}

extension VariableBlurStyle: Animatable {
    package var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
}

extension VariableBlurStyle: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.cgFloatField(1, radius)
        encoder.boolField(2, isOpaque)
        encoder.boolField(3, dither)
        try encoder.messageField(4, mask)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var style = VariableBlurStyle()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: style.radius = try decoder.cgFloatField(field)
            case 2: style.isOpaque = try decoder.boolField(field)
            case 3: style.dither = try decoder.boolField(field)
            case 4: style.mask = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = style
    }
}

extension VariableBlurStyle.Mask: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case .none: break
        case .image(let image): try encoder.messageField(1, image)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var mask = VariableBlurStyle.Mask.none
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                let image: GraphicsImage = try decoder.messageField(field)
                mask = .image(image)
            default:
                try decoder.skipField(field)
            }
        }
        self = mask
    }
}
