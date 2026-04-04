//
//  CodableAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - CodableAnimation

package struct CodableAnimation: ProtobufMessage {
    package struct Tag: ProtobufTag {
        package let rawValue: UInt

        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    var base: Animation

    init(base: Animation) {
        self.base = base
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        let animation = base.codableValue as? any EncodableAnimation ?? DefaultAnimation()
        try animation.encodeAnimation(to: &encoder)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var animation: Animation?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                animation = Animation(try decoder.messageField(field) as BezierAnimation)
            case 2:
                animation = Animation(try decoder.messageField(field) as SpringAnimation)
            case 3:
                animation = Animation(try decoder.messageField(field) as FluidSpringAnimation)
            case 4:
                guard let existing = animation else { continue }
                let delay = try decoder.doubleField(field)
                animation = existing.modifier(DelayAnimation(delay: delay))
            case 5:
                let (repeatCount, autoreverses) = try decoder.messageField(field) { decoder in
                    try Animation.decodeRepeatMessage(from: &decoder)
                }
                guard let existing = animation else { continue }
                animation = existing.modifier(
                    RepeatAnimation(repeatCount: repeatCount, autoreverses: autoreverses)
                )
            case 6:
                guard let existing = animation else { continue }
                let speed = try decoder.doubleField(field)
                animation = existing.modifier(SpeedAnimation(speed: speed))
            case 7:
                animation = try decoder.messageField(field) { _ in
                    Animation(DefaultAnimation())
                }
            default:
                try decoder.skipField(field)
            }
        }
        guard let animation else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.base = animation
    }
}

// MARK: - Animation + decodeRepeatMessage

extension Animation {
    package static func decodeRepeatMessage(
        from decoder: inout ProtobufDecoder
    ) throws -> (Int?, Bool) {
        var repeatCount: Int?
        var autoreverses = false
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                repeatCount = try decoder.intField(field)
            case 2:
                autoreverses = try decoder.boolField(field)
            default:
                try decoder.skipField(field)
            }
        }
        return (repeatCount, autoreverses)
    }
}
