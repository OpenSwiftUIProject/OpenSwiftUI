//
//  CATransform3D.swift
//  CoreGraphicsShims
//
//  License: MIT
//  Modified from https://github.com/flowkey/UIKit-cross-platform/blob/7e28dc4c62d20afe03e55bbba660076ec06fd79a/Sources/CATransform3D.swift

#if !canImport(QuartzCore)
public import Foundation

public struct CATransform3D {
    public init(
        m11: CGFloat, m12: CGFloat, m13: CGFloat, m14: CGFloat,
        m21: CGFloat, m22: CGFloat, m23: CGFloat, m24: CGFloat,
        m31: CGFloat, m32: CGFloat, m33: CGFloat, m34: CGFloat,
        m41: CGFloat, m42: CGFloat, m43: CGFloat, m44: CGFloat
    ) {
        self.m11 = m11; self.m12 = m12; self.m13 = m13; self.m14 = m14;
        self.m21 = m21; self.m22 = m22; self.m23 = m23; self.m24 = m24;
        self.m31 = m31; self.m32 = m32; self.m33 = m33; self.m34 = m34;
        self.m41 = m41; self.m42 = m42; self.m43 = m43; self.m44 = m44;
    }

    public init() {
        self.m11 = 0.0; self.m12 = 0.0; self.m13 = 0.0; self.m14 = 0.0;
        self.m21 = 0.0; self.m22 = 0.0; self.m23 = 0.0; self.m24 = 0.0;
        self.m31 = 0.0; self.m32 = 0.0; self.m33 = 0.0; self.m34 = 0.0;
        self.m41 = 0.0; self.m42 = 0.0; self.m43 = 0.0; self.m44 = 0.0;
    }

    public var m11: CGFloat; public var m12: CGFloat; public var m13: CGFloat; public var m14: CGFloat
    public var m21: CGFloat; public var m22: CGFloat; public var m23: CGFloat; public var m24: CGFloat
    public var m31: CGFloat; public var m32: CGFloat; public var m33: CGFloat; public var m34: CGFloat
    public var m41: CGFloat; public var m42: CGFloat; public var m43: CGFloat; public var m44: CGFloat
}

internal extension CATransform3D {
    func transformingVector(x: CGFloat, y: CGFloat, z: CGFloat) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        let newX = Double(m11) * Double(x) + Double(m21) * Double(y) + Double(m31) * Double(z) + Double(m41)
        let newY = Double(m12) * Double(x) + Double(m22) * Double(y) + Double(m32) * Double(z) + Double(m42)
        let newZ = Double(m13) * Double(x) + Double(m23) * Double(y) + Double(m33) * Double(z) + Double(m43)
        let newW = Double(m14) * Double(x) + Double(m24) * Double(y) + Double(m34) * Double(z) + Double(m44)

        return (
            x: CGFloat(newX / newW),
            y: CGFloat(newY / newW),
            z: CGFloat(newZ / newW)
        )
    }
}

public let CATransform3DIdentity = CATransform3D(
    m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0,
    m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0,
    m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0,
    m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0
)

public func CATransform3DEqualToTransform(_ a: CATransform3D, _ b: CATransform3D) -> Bool {
    return
        a.m11 == b.m11 && a.m12 == b.m12 && a.m13 == b.m13 && a.m14 == b.m14 &&
        a.m21 == b.m21 && a.m22 == b.m22 && a.m23 == b.m23 && a.m24 == b.m24 &&
        a.m31 == b.m31 && a.m32 == b.m32 && a.m33 == b.m33 && a.m34 == b.m34 &&
        a.m41 == b.m41 && a.m42 == b.m42 && a.m43 == b.m43 && a.m44 == b.m44
}

extension CATransform3D: Equatable {
    public static func == (_ lhs: CATransform3D, _ rhs: CATransform3D) -> Bool {
        return CATransform3DEqualToTransform(lhs, rhs)
    }

    // This isn't public API on iOS, although it'd probably be quite useful
    internal static func * (_ lhs: CATransform3D, _ rhs: CATransform3D) -> CATransform3D {
        return lhs.concat(rhs)
    }
}

extension CATransform3D: CustomStringConvertible {
    public var description: String {
        return """
        \(m11)\t\t\(m12)\t\t\(m13)\t\t\(m14)
        \(m21)\t\t\(m22)\t\t\(m23)\t\t\(m24)
        \(m31)\t\t\(m32)\t\t\(m33)\t\t\(m34)
        \(m41)\t\t\(m42)\t\t\(m43)\t\t\(m44)
        """
    }
}


// https://stackoverflow.com/a/5508486/3086440
/*
 | a b 0 |      | a b 0 0 |
 | d e 0 |  =>  | d e 0 0 |
 | g h 1 |      | 0 0 1 0 |
                | g h 0 1 |
 */
public func CATransform3DMakeAffineTransform(_ m: CGAffineTransform) -> CATransform3D {
    return CATransform3D(
        m11: m.a,  m12: m.b,  m13: 0.0, m14: 0.0,
        m21: m.c,  m22: m.d,  m23: 0.0, m24: 0.0,
        m31: 0.0,  m32: 0.0,  m33: 1.0, m34: 0.0,
        m41: m.tx, m42: m.ty, m43: 0.0, m44: 1.0
    )
}

public func CATransform3DMakeTranslation(_ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> CATransform3D {
    return CATransform3D(
        m11: 1,  m12: 0,  m13: 0,  m14: 0,
        m21: 0,  m22: 1,  m23: 0,  m24: 0,
        m31: 0,  m32: 0,  m33: 1,  m34: 0,
        m41: tx, m42: ty, m43: tz, m44: 1
    )
}

public func CATransform3DMakeScale(_ sx: CGFloat, _ sy: CGFloat, _ sz: CGFloat) -> CATransform3D {
    return CATransform3D(
        m11: sx, m12: 0,  m13: 0,  m14: 0,
        m21: 0,  m22: sy, m23: 0,  m24: 0,
        m31: 0,  m32: 0,  m33: sz, m34: 0,
        m41: 0,  m42: 0,  m43: 0,  m44: 1
    )
}

/// Returns a transform that rotates by `angle` radians about the vector
/// `(x, y, z)`. If the vector has length zero the identity transform is
/// returned.
public func CATransform3DMakeRotation(_ angle: CGFloat, _ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> CATransform3D {
    let ax = Double(x)
    let ay = Double(y)
    let az = Double(z)
    let len = sqrt(ax * ax + ay * ay + az * az)
    guard len > 0 else {
        return CATransform3DIdentity
    }

    let ux = CGFloat(ax / len)
    let uy = CGFloat(ay / len)
    let uz = CGFloat(az / len)

    let a = Double(angle)
    let c = CGFloat(cos(a))
    let s = CGFloat(sin(a))
    let omc = 1 - c

    // Compute standard rotation matrix components (Rodrigues' formula)
    let r11 = c + ux * ux * omc
    let r12 = ux * uy * omc - uz * s
    let r13 = ux * uz * omc + uy * s

    let r21 = uy * ux * omc + uz * s
    let r22 = c + uy * uy * omc
    let r23 = uy * uz * omc - ux * s

    let r31 = uz * ux * omc - uy * s
    let r32 = uz * uy * omc + ux * s
    let r33 = c + uz * uz * omc

    // Store the transpose of the standard rotation matrix into CATransform3D
    // so that the effective transform used by this implementation matches the
    // expected row/column layout when applied to points.
    let m11 = r11
    let m12 = r21
    let m13 = r31
    let m14: CGFloat = 0.0

    let m21 = r12
    let m22 = r22
    let m23 = r32
    let m24: CGFloat = 0.0

    let m31 = r13
    let m32 = r23
    let m33 = r33
    let m34: CGFloat = 0.0

    let m41: CGFloat = 0.0
    let m42: CGFloat = 0.0
    let m43: CGFloat = 0.0
    let m44: CGFloat = 1.0

    return CATransform3D(
        m11: m11, m12: m12, m13: m13, m14: m14,
        m21: m21, m22: m22, m23: m23, m24: m24,
        m31: m31, m32: m32, m33: m33, m34: m34,
        m41: m41, m42: m42, m43: m43, m44: m44
    )
}

/// Translate `t` by `(tx, ty, tz)` and return the result:
/// t' = translate(tx, ty, tz) * t.
public func CATransform3DTranslate(_ t: CATransform3D, _ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> CATransform3D {
    return CATransform3DConcat(CATransform3DMakeTranslation(tx, ty, tz), t)
}

/// Scale `t` by `(sx, sy, sz)` and return the result:
/// t' = scale(sx, sy, sz) * t.
public func CATransform3DScale(_ t: CATransform3D, _ sx: CGFloat, _ sy: CGFloat, _ sz: CGFloat) -> CATransform3D {
    return CATransform3DConcat(CATransform3DMakeScale(sx, sy, sz), t)
}

/// Rotate `t` by `angle` radians about the vector `(x, y, z)` and return
/// the result. If the vector has zero length the behavior is undefined:
/// t' = rotation(angle, x, y, z) * t.
public func CATransform3DRotate(_ t: CATransform3D, _ angle: CGFloat, _ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> CATransform3D {
    return CATransform3DConcat(CATransform3DMakeRotation(angle, x, y, z), t)
}

public func CATransform3DConcat(_ a: CATransform3D, _ b: CATransform3D) -> CATransform3D {
    if a == CATransform3DIdentity { return b }
    if b == CATransform3DIdentity { return a }

    var result = CATransform3D()

    result.m11 = a.m11 * b.m11 + a.m21 * b.m12 + a.m31 * b.m13 + a.m41 * b.m14
    result.m12 = a.m12 * b.m11 + a.m22 * b.m12 + a.m32 * b.m13 + a.m42 * b.m14
    result.m13 = a.m13 * b.m11 + a.m23 * b.m12 + a.m33 * b.m13 + a.m43 * b.m14
    result.m14 = a.m14 * b.m11 + a.m24 * b.m12 + a.m34 * b.m13 + a.m44 * b.m14

    result.m21 = a.m11 * b.m21 + a.m21 * b.m22 + a.m31 * b.m23 + a.m41 * b.m24
    result.m22 = a.m12 * b.m21 + a.m22 * b.m22 + a.m32 * b.m23 + a.m42 * b.m24
    result.m23 = a.m13 * b.m21 + a.m23 * b.m22 + a.m33 * b.m23 + a.m43 * b.m24
    result.m24 = a.m14 * b.m21 + a.m24 * b.m22 + a.m34 * b.m23 + a.m44 * b.m24

    result.m31 = a.m11 * b.m31 + a.m21 * b.m32 + a.m31 * b.m33 + a.m41 * b.m34
    result.m32 = a.m12 * b.m31 + a.m22 * b.m32 + a.m32 * b.m33 + a.m42 * b.m34
    result.m33 = a.m13 * b.m31 + a.m23 * b.m32 + a.m33 * b.m33 + a.m43 * b.m34
    result.m34 = a.m14 * b.m31 + a.m24 * b.m32 + a.m34 * b.m33 + a.m44 * b.m34

    result.m41 = a.m11 * b.m41 + a.m21 * b.m42 + a.m31 * b.m43 + a.m41 * b.m44
    result.m42 = a.m12 * b.m41 + a.m22 * b.m42 + a.m32 * b.m43 + a.m42 * b.m44
    result.m43 = a.m13 * b.m41 + a.m23 * b.m42 + a.m33 * b.m43 + a.m43 * b.m44
    result.m44 = a.m14 * b.m41 + a.m24 * b.m42 + a.m34 * b.m43 + a.m44 * b.m44

    return result
}

extension CATransform3D {
    func concat(_ other: CATransform3D) -> CATransform3D {
        return CATransform3DConcat(self, other)
    }
}

public func CATransform3DGetAffineTransform(_ t: CATransform3D) -> CGAffineTransform {
    return CGAffineTransform(
        a: t.m11,  b: t.m12,
        c: t.m21,  d: t.m22,
        tx: t.m41, ty: t.m42
    )
}

/// Invert 't' and return the result. Returns the original matrix if 't'
/// has no inverse.
public func CATransform3DInvert(_ t: CATransform3D) -> CATransform3D {
    // For identity matrix, return identity
    if t == CATransform3DIdentity {
        return t
    }
    
    // Calculate determinant to check if matrix can be inverted
    let det = t.m11 * (t.m22 * (t.m33 * t.m44 - t.m34 * t.m43) - 
                       t.m23 * (t.m32 * t.m44 - t.m34 * t.m42) + 
                       t.m24 * (t.m32 * t.m43 - t.m33 * t.m42)) -
              t.m12 * (t.m21 * (t.m33 * t.m44 - t.m34 * t.m43) - 
                       t.m23 * (t.m31 * t.m44 - t.m34 * t.m41) + 
                       t.m24 * (t.m31 * t.m43 - t.m33 * t.m41)) +
              t.m13 * (t.m21 * (t.m32 * t.m44 - t.m34 * t.m42) - 
                       t.m22 * (t.m31 * t.m44 - t.m34 * t.m41) + 
                       t.m24 * (t.m31 * t.m42 - t.m32 * t.m41)) -
              t.m14 * (t.m21 * (t.m32 * t.m43 - t.m33 * t.m42) - 
                       t.m22 * (t.m31 * t.m43 - t.m33 * t.m41) + 
                       t.m23 * (t.m31 * t.m42 - t.m32 * t.m41))
    
    // If determinant is too close to zero, matrix cannot be inverted
    if abs(det) < 1e-6 {
        return t
    }
    
    let invDet = 1.0 / det
    
    // Calculate adjugate matrix and multiply by 1/determinant
    var result = CATransform3D()
    
    // Row 1
    result.m11 = invDet * (
        t.m22 * (t.m33 * t.m44 - t.m34 * t.m43) - 
        t.m23 * (t.m32 * t.m44 - t.m34 * t.m42) + 
        t.m24 * (t.m32 * t.m43 - t.m33 * t.m42)
    )
    
    result.m12 = -invDet * (
        t.m12 * (t.m33 * t.m44 - t.m34 * t.m43) - 
        t.m13 * (t.m32 * t.m44 - t.m34 * t.m42) + 
        t.m14 * (t.m32 * t.m43 - t.m33 * t.m42)
    )
    
    result.m13 = invDet * (
        t.m12 * (t.m23 * t.m44 - t.m24 * t.m43) - 
        t.m13 * (t.m22 * t.m44 - t.m24 * t.m42) + 
        t.m14 * (t.m22 * t.m43 - t.m23 * t.m42)
    )
    
    result.m14 = -invDet * (
        t.m12 * (t.m23 * t.m34 - t.m24 * t.m33) - 
        t.m13 * (t.m22 * t.m34 - t.m24 * t.m32) + 
        t.m14 * (t.m22 * t.m33 - t.m23 * t.m32)
    )
    
    // Row 2
    result.m21 = -invDet * (
        t.m21 * (t.m33 * t.m44 - t.m34 * t.m43) - 
        t.m23 * (t.m31 * t.m44 - t.m34 * t.m41) + 
        t.m24 * (t.m31 * t.m43 - t.m33 * t.m41)
    )
    
    result.m22 = invDet * (
        t.m11 * (t.m33 * t.m44 - t.m34 * t.m43) - 
        t.m13 * (t.m31 * t.m44 - t.m34 * t.m41) + 
        t.m14 * (t.m31 * t.m43 - t.m33 * t.m41)
    )
    
    result.m23 = -invDet * (
        t.m11 * (t.m23 * t.m44 - t.m24 * t.m43) - 
        t.m13 * (t.m21 * t.m44 - t.m24 * t.m41) + 
        t.m14 * (t.m21 * t.m43 - t.m23 * t.m41)
    )
    
    result.m24 = invDet * (
        t.m11 * (t.m23 * t.m34 - t.m24 * t.m33) - 
        t.m13 * (t.m21 * t.m34 - t.m24 * t.m31) + 
        t.m14 * (t.m21 * t.m33 - t.m23 * t.m31)
    )
    
    // Row 3
    result.m31 = invDet * (
        t.m21 * (t.m32 * t.m44 - t.m34 * t.m42) - 
        t.m22 * (t.m31 * t.m44 - t.m34 * t.m41) + 
        t.m24 * (t.m31 * t.m42 - t.m32 * t.m41)
    )
    
    result.m32 = -invDet * (
        t.m11 * (t.m32 * t.m44 - t.m34 * t.m42) - 
        t.m12 * (t.m31 * t.m44 - t.m34 * t.m41) + 
        t.m14 * (t.m31 * t.m42 - t.m32 * t.m41)
    )
    
    result.m33 = invDet * (
        t.m11 * (t.m22 * t.m44 - t.m24 * t.m42) - 
        t.m12 * (t.m21 * t.m44 - t.m24 * t.m41) + 
        t.m14 * (t.m21 * t.m42 - t.m22 * t.m41)
    )
    
    result.m34 = -invDet * (
        t.m11 * (t.m22 * t.m34 - t.m24 * t.m32) - 
        t.m12 * (t.m21 * t.m34 - t.m24 * t.m31) + 
        t.m14 * (t.m21 * t.m32 - t.m22 * t.m31)
    )
    
    // Row 4
    result.m41 = -invDet * (
        t.m21 * (t.m32 * t.m43 - t.m33 * t.m42) - 
        t.m22 * (t.m31 * t.m43 - t.m33 * t.m41) + 
        t.m23 * (t.m31 * t.m42 - t.m32 * t.m41)
    )
    
    result.m42 = invDet * (
        t.m11 * (t.m32 * t.m43 - t.m33 * t.m42) - 
        t.m12 * (t.m31 * t.m43 - t.m33 * t.m41) + 
        t.m13 * (t.m31 * t.m42 - t.m32 * t.m41)
    )
    
    result.m43 = -invDet * (
        t.m11 * (t.m22 * t.m43 - t.m23 * t.m42) - 
        t.m12 * (t.m21 * t.m43 - t.m23 * t.m41) + 
        t.m13 * (t.m21 * t.m42 - t.m22 * t.m41)
    )
    
    result.m44 = invDet * (
        t.m11 * (t.m22 * t.m33 - t.m23 * t.m32) - 
        t.m12 * (t.m21 * t.m33 - t.m23 * t.m31) + 
        t.m13 * (t.m21 * t.m32 - t.m22 * t.m31)
    )
    
    return result
}

#endif
