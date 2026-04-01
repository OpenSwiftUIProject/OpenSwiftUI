//
//  CodableAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complte

// MARK: - CodableAnimation

package final class CodableAnimation: ProtobufMessage {
    package struct Tag: ProtobufTag {
        package let rawValue: UInt

        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    var base: any CustomAnimation

    init(base: any CustomAnimation) {
        self.base = base
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        let animation = base as? any EncodableAnimation ?? DefaultAnimation()
        try animation.encodeAnimation(to: &encoder)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var base: (any CustomAnimation)?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                base = try decoder.messageField(field) as BezierAnimation
            case 2:
                base = try decoder.messageField(field) as SpringAnimation
            case 3:
                base = try decoder.messageField(field) as FluidSpringAnimation
            case 4:
                guard let existing = base else { continue }
                let delay = try decoder.doubleField(field)
                base = Animation(existing)
                    .modifier(DelayAnimation(delay: delay))
                    .codableValue
            case 5:
                let (repeatCount, autoreverses) = try decoder.messageField(field) { decoder in
                    try Animation.decodeRepeatMessage(from: &decoder)
                }
                guard let existing = base else { continue }
                base = Animation(existing)
                    .modifier(RepeatAnimation(repeatCount: repeatCount, autoreverses: autoreverses))
                    .codableValue
            case 6:
                guard let existing = base else { continue }
                let speed = try decoder.doubleField(field)
                base = Animation(existing)
                    .modifier(SpeedAnimation(speed: speed))
                    .codableValue
            case 7:
                base = try decoder.messageField(field) { _ in
                    DefaultAnimation()
                }
            default:
                try decoder.skipField(field)
            }
        }
        guard let base else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.base = base
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
