//
//  ProjectionTransform.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18
//  Status: Complete

public import Foundation
#if canImport(QuartzCore)
public import QuartzCore
#else
// FIXME: Use Silica or other implementation
public struct CGAffineTransform {
    public init()

    public init(a: Double, b: Double, c: Double, d: Double, tx: Double, ty: Double)

    public var a: Double

    public var b: Double

    public var c: Double

    public var d: Double

    public var tx: Double

    public var ty: Double
}
#endif

@frozen
public struct ProjectionTransform {
    public var m11: CGFloat = 1.0, m12: CGFloat = 0.0, m13: CGFloat = 0.0
    public var m21: CGFloat = 0.0, m22: CGFloat = 1.0, m23: CGFloat = 0.0
    public var m31: CGFloat = 0.0, m32: CGFloat = 0.0, m33: CGFloat = 1.0

    @inline(__always)
    package init (
        m11: CGFloat, m12: CGFloat, m13: CGFloat,
        m21: CGFloat, m22: CGFloat, m23: CGFloat,
        m31: CGFloat, m32: CGFloat, m33: CGFloat
    ) {
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
    }
    
    @inlinable
    public init() {}

    #if canImport(QuartzCore)
    @inlinable
    public init(_ m: CGAffineTransform) {
        m11 = m.a
        m12 = m.b
        m21 = m.c
        m22 = m.d
        m31 = m.tx
        m32 = m.ty
    }

    @inlinable
    public init(_ m: CATransform3D) {
        m11 = m.m11
        m12 = m.m12
        m13 = m.m14
        m21 = m.m21
        m22 = m.m22
        m23 = m.m24
        m31 = m.m41
        m32 = m.m42
        m33 = m.m44
    }
    #endif

    @inlinable
    public var isIdentity: Bool {
        self == ProjectionTransform()
    }

    @inlinable
    public var isAffine: Bool {
        m13 == 0 && m23 == 0 && m33 == 1
    }
    
    package var determinant: CGFloat {
        if isAffine {
            return m11 * m22 - m12 * m21
        }
        let det1 = m22 * m33 - m23 * m32
        let det2 = m21 * m33 - m23 * m31
        let det3 = m21 * m32 - m22 * m31
        
        return m11 * det1 - m12 * det2 + m13 * det3
    }
    
    package var isInvertible: Bool {
        determinant != 0
    }
    
    public mutating func invert() -> Bool {
        let det = determinant
        guard det != 0 else { return false }
        
        let invDet = 1.0 / det
        
        // Calculate cofactors
        let c11 = m22 * m33 - m23 * m32
        let c12 = m21 * m33 - m23 * m31
        let c13 = m21 * m32 - m22 * m31
        
        let c21 = m12 * m33 - m13 * m32
        let c22 = m11 * m33 - m13 * m31
        let c23 = m11 * m32 - m12 * m31
        
        let c31 = m12 * m23 - m13 * m22
        let c32 = m11 * m23 - m13 * m21
        let c33 = m11 * m22 - m12 * m21
        
        // Calculate adjugate matrix and multiply by 1/determinant
        m11 = c11 * invDet
        m12 = -c21 * invDet
        m13 = c31 * invDet
        m21 = -c12 * invDet
        m22 = c22 * invDet
        m23 = -c32 * invDet
        m31 = c13 * invDet
        m32 = -c23 * invDet
        m33 = c33 * invDet
        
        return true
    }
    
    public func inverted() -> ProjectionTransform {
        var copy = self
        let result = copy.invert()
        if !result {
            Log.runtimeIssues("Cannot invert singular matrix")
        }
        return copy
    }
}

extension ProjectionTransform: Equatable {}

extension ProjectionTransform {
    @inline(__always)
    @inlinable
    func dot(_ a: (CGFloat, CGFloat, CGFloat), _ b: (CGFloat, CGFloat, CGFloat)) -> CGFloat {
        a.0 * b.0 + a.1 * b.1 + a.2 * b.2
    }
    
    @inlinable
    public func concatenating(_ rhs: ProjectionTransform) -> ProjectionTransform {
        var m = ProjectionTransform()
        m.m11 = dot((m11, m12, m13), (rhs.m11, rhs.m21, rhs.m31))
        m.m12 = dot((m11, m12, m13), (rhs.m12, rhs.m22, rhs.m32))
        m.m13 = dot((m11, m12, m13), (rhs.m13, rhs.m23, rhs.m33))
        m.m21 = dot((m21, m22, m23), (rhs.m11, rhs.m21, rhs.m31))
        m.m22 = dot((m21, m22, m23), (rhs.m12, rhs.m22, rhs.m32))
        m.m23 = dot((m21, m22, m23), (rhs.m13, rhs.m23, rhs.m33))
        m.m31 = dot((m31, m32, m33), (rhs.m11, rhs.m21, rhs.m31))
        m.m32 = dot((m31, m32, m33), (rhs.m12, rhs.m22, rhs.m32))
        m.m33 = dot((m31, m32, m33), (rhs.m13, rhs.m23, rhs.m33))
        return m
    }
}

extension CGPoint {
    public func applying(_ t: ProjectionTransform) -> CGPoint {
        let w = t.m13 * x + t.m23 * y + t.m33
        
        let scale: CGFloat
        if w == 1 {
            scale = 1
        } else if w <= 0 {
            scale = .infinity
        } else {
            scale = 1 / w
        }
        
        let px = (t.m11 * x + t.m21 * y + t.m31) * scale
        let py = (t.m12 * x + t.m22 * y + t.m32) * scale
        
        return CGPoint(x: px, y: py)
    }
}
extension CGPoint {
    package func unapplying(_ m: ProjectionTransform) -> CGPoint {
        var inverse = m
        guard inverse.invert() else { return self }
        return applying(inverse)
    }
}

#if canImport(QuartzCore)
extension CGAffineTransform {
    package init(_ m: ProjectionTransform) {
        self.init(
            a: m.m11, b: m.m12,
            c: m.m21, d: m.m22,
            tx: m.m31, ty: m.m32
        )
    }
}

extension CATransform3D {
    package init(_ m: ProjectionTransform) {
        self.init(
            m11: m.m11, m12: m.m12, m13: 0, m14: m.m13,
            m21: m.m21, m22: m.m22, m23: 0, m24: m.m23,
            m31: 0, m32: 0, m33: 1, m34: 0,
            m41: m.m31, m42: m.m32, m43: 0, m44: m.m33
        )
    }
}
#endif

extension ProjectionTransform: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        withUnsafePointer(to: self) { pointer in
            let pointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: CGFloat.self)
            let bufferPointer = UnsafeBufferPointer(start: pointer, count: 9)
            for index: UInt in 1 ... 9 {
                encoder.cgFloatField(
                    index,
                    bufferPointer[Int(index &- 1)],
                    defaultValue: (index == 1 || index == 5 || index == 9) ? 1 : 0
                )
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var transform = ProjectionTransform()
        try withUnsafeMutablePointer(to: &transform) { pointer in
            let pointer = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: CGFloat.self)
            let bufferPointer = UnsafeMutableBufferPointer(start: pointer, count: 9)
            while let field = try decoder.nextField() {
                let tag = field.tag
                switch tag {
                    case 1...9: bufferPointer[Int(tag &- 1)] = try decoder.cgFloatField(field)
                    default: try decoder.skipField(field)
                }
            }
        }
        self = transform
    }
}
