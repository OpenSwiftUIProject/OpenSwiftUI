//
//  CodableEffectAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - CodableEffectAnimation

package struct CodableEffectAnimation: ProtobufMessage {
    package struct Tag: ProtobufTag {
        package let rawValue: UInt

        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    var base: any _DisplayList_AnyEffectAnimation

    package func encode(to encoder: inout ProtobufEncoder) throws {
        try base.encodeAnimation(to: &encoder)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var base: (any _DisplayList_AnyEffectAnimation)?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                base = try decoder.messageField(field) as DisplayList.OffsetAnimation
            case 2:
                base = try decoder.messageField(field) as DisplayList.ScaleAnimation
            case 3:
                base = try decoder.messageField(field) as DisplayList.RotationAnimation
            case 4:
                base = try decoder.messageField(field) as DisplayList.OpacityAnimation
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

// MARK: - _DisplayList_AnyEffectAnimation + Encode

extension _DisplayList_AnyEffectAnimation {
    package func encodeAnimation(to encoder: inout ProtobufEncoder) throws {
        if let leafTag = Self.leafProtobufTag {
            try encoder.messageField(leafTag.rawValue, self)
        } else {
            try encode(to: &encoder)
        }
    }
}
