//
//  CGAffineTransform+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

#if canImport(Darwin)

package import CoreGraphics

extension CGAffineTransform {
    package init(rotation: Angle) {
        let sin = sin(rotation.radians)
        let cos = cos(rotation.radians)
        self.init(a: cos, b: sin, c: -sin, d: cos, tx: 0, ty: 0)
    }
    
    package var isTranslation: Bool {
        return a == 1 && b == 0 && c == 0 && d == 1
    }
    
    package var isRectilinear: Bool {
        return (b == 0 && c == 0) || (a == 0 && d == 0)
    }
    
    package var isUniform: Bool {
        guard isRectilinear else {
            return false
        }
        return a == d && b == c
    }
    
    package func rotated(by angle: Angle) -> CGAffineTransform {
        CGAffineTransform(rotation: angle).concatenating(self)
    }
    
    package var scale: CGFloat {
        let m = a * a + b * b
        let n = c * c + d * d
        
        if m == 1.0 && n == 1.0 {
            return 1.0
        } else {
            return (sqrt(m) + sqrt(n)) / 2
        }
    }
}

extension CGAffineTransform: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.cgFloatField(1, a, defaultValue: 1)
        encoder.cgFloatField(2, b, defaultValue: 0)
        encoder.cgFloatField(3, c, defaultValue: 0)
        encoder.cgFloatField(4, d, defaultValue: 1)
        encoder.cgFloatField(5, tx, defaultValue: 0)
        encoder.cgFloatField(6, ty, defaultValue: 0)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var transform = CGAffineTransform.identity
        while let field = try decoder.nextField() {
            switch field.tag {
                case 1: transform.a = try decoder.cgFloatField(field)
                case 2: transform.b = try decoder.cgFloatField(field)
                case 3: transform.c = try decoder.cgFloatField(field)
                case 4: transform.d = try decoder.cgFloatField(field)
                case 5: transform.tx = try decoder.cgFloatField(field)
                case 6: transform.ty = try decoder.cgFloatField(field)
                default: try decoder.skipField(field)
            }
        }
        self = transform
    }
}

#endif
