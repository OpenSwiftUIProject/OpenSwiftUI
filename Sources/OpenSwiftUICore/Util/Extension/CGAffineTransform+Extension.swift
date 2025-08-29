//
//  CGAffineTransform+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenCoreGraphicsShims
package import Foundation

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
        withUnsafePointer(to: self) { pointer in
            let pointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: CGFloat.self)
            let bufferPointer = UnsafeBufferPointer(start: pointer, count: 6)
            for index: UInt in 1 ... 6 {
                encoder.cgFloatField(
                    index,
                    bufferPointer[Int(index &- 1)],
                    defaultValue: (index == 1 || index == 4) ? 1 : 0
                )
            }
        }
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var transform = CGAffineTransform.identity
        try withUnsafeMutablePointer(to: &transform) { pointer in
            let pointer = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: CGFloat.self)
            let bufferPointer = UnsafeMutableBufferPointer(start: pointer, count: 6)
            while let field = try decoder.nextField() {
                let tag = field.tag
                switch tag {
                    case 1...6: bufferPointer[Int(tag &- 1)] = try decoder.cgFloatField(field)
                    default: try decoder.skipField(field)
                }
            }
        }
        self = transform
    }
}
