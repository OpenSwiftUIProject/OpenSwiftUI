//
//  BlurStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 6.5.4
//  Status: Complete

package import Foundation

package struct BlurStyle: Equatable {
    package var radius: CGFloat
    package var isOpaque: Bool
    package var dither: Bool

    package init(
        radius: CGFloat = 0,
        isOpaque: Bool = false,
        dither: Bool = false,
        hardEdges: Bool = false
    ) {
        self.radius = radius
        self.isOpaque = isOpaque
        self.dither = dither
    }

    package var isIdentity: Bool {
        radius <= 0.0
    }
}

extension BlurStyle: Animatable {
    package var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
}

extension BlurStyle: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.cgFloatField(1, radius)
        encoder.boolField(2, isOpaque)
        encoder.boolField(3, dither)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var style = BlurStyle()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: style.radius = try decoder.cgFloatField(field)
            case 2: style.isOpaque = try decoder.boolField(field)
            case 3: style.dither = try decoder.boolField(field)
            default: try decoder.skipField(field)
            }
        }
        self = style
    }
}
