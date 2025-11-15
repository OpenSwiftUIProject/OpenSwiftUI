//
//  EncodableAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

// MARK: - CodableAnimation [WIP]

package enum CodableAnimation {
    package struct Tag: ProtobufTag {
        package let rawValue: UInt

        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - EncodableAnimation

package protocol EncodableAnimation: ProtobufEncodableMessage {
    static var leafProtobufTag: CodableAnimation.Tag? { get }
}

extension EncodableAnimation {
    package static var leafProtobufTag: CodableAnimation.Tag? { nil }

    package func encodeAnimation(to encoder: inout ProtobufEncoder) throws {
        if let leafTag = Self.leafProtobufTag {
            try encoder.messageField(leafTag.rawValue, self)
        } else {
            try encode(to: &encoder)
        }
    }
}

extension SpringAnimation: EncodableAnimation {
    package static var leafProtobufTag: CodableAnimation.Tag? {
        .init(rawValue: 2)
    }
}

extension FluidSpringAnimation: EncodableAnimation {
    package static var leafProtobufTag: CodableAnimation.Tag? {
        .init(rawValue: 3)
    }
}

extension RepeatAnimation: ProtobufEncodableMessage {
   func encode(to encoder: inout ProtobufEncoder) throws {
       encoder.messageField(5) { encoder in
           if let repeatCount {
               encoder.intField(1, repeatCount, defaultValue: .min)
           }
           encoder.boolField(2, autoreverses)
       }
   }
}

extension SpeedAnimation: ProtobufEncodableMessage {
    func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(6, speed)
    }
}

extension DefaultAnimation: EncodableAnimation {
    package static var leafProtobufTag: CodableAnimation.Tag? {
        .init(rawValue: 7)
    }
}
