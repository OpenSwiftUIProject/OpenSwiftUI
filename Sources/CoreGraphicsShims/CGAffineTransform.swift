//
//  CGAffineTransform.swift
//  CoreGraphicsShims

#if !canImport(CoreGraphics)
public import Foundation

public struct CGAffineTransform: Equatable {
    public init() {
        a = .zero
        b = .zero
        c = .zero
        d = .zero
        tx = .zero
        ty = .zero
    }

    public init(a: Double, b: Double, c: Double, d: Double, tx: Double, ty: Double) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.tx = tx
        self.ty = ty
    }

    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var tx: Double
    public var ty: Double

    public static let identity = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
}

extension CGAffineTransform {
    public init(translationX tx: CGFloat, y ty: CGFloat) {
        self.init(a: 1, b: 0, c: 0, d: 1, tx: Double(tx), ty: Double(ty))
    }

    public init(scaleX sx: CGFloat, y sy: CGFloat) {
        self.init(a: Double(sx), b: 0, c: 0, d: Double(sy), tx: 0, ty: 0)
    }

    public init(rotationAngle angle: CGFloat) {
        let radians = Double(angle)
        self.init(a: cos(radians), b: sin(radians), c: -sin(radians), d: cos(radians), tx: 0, ty: 0)
    }

    public var isIdentity: Bool {
        return self == CGAffineTransform.identity
    }

    public func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
        CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: Double(tx), ty: Double(ty)).concatenating(self)
    }

    public func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
        CGAffineTransform(a: Double(sx), b: 0, c: 0, d: Double(sy), tx: 0, ty: 0).concatenating(self)
    }

    public func rotated(by angle: CGFloat) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: angle).concatenating(self)
    }

    public func inverted() -> CGAffineTransform {
        let det = a * d - b * c
        if abs(det) < 1e-12 {
            return self
        }
        let inv = 1.0 / det
        let ra =  d * inv
        let rb = -b * inv
        let rc = -c * inv
        let rd =  a * inv
        let rtx = -(tx * ra + ty * rc)
        let rty = -(tx * rb + ty * rd)
        return CGAffineTransform(a: ra, b: rb, c: rc, d: rd, tx: rtx, ty: rty)
    }

    public func concatenating(_ transform: CGAffineTransform) -> CGAffineTransform {
        // Matrix multiplication: self * transform
        let a1 = a, b1 = b, c1 = c, d1 = d, tx1 = tx, ty1 = ty
        let a2 = transform.a, b2 = transform.b, c2 = transform.c, d2 = transform.d, tx2 = transform.tx, ty2 = transform.ty

        let ra = a1 * a2 + b1 * c2
        let rb = a1 * b2 + b1 * d2
        let rc = c1 * a2 + d1 * c2
        let rd = c1 * b2 + d1 * d2
        let rtx = tx1 * a2 + ty1 * c2 + tx2
        let rty = tx1 * b2 + ty1 * d2 + ty2

        return CGAffineTransform(a: ra, b: rb, c: rc, d: rd, tx: rtx, ty: rty)
    }
}

extension CGPoint {
    public func applying(_ t: CGAffineTransform) -> CGPoint {
        CGPoint(
            x: t.a * x + t.c * y + t.tx,
            y: t.b * x + t.d * y + t.ty
        )
    }
}

extension CGSize {
    public func applying(_ t: CGAffineTransform) -> CGSize {
        let rect = CGRect(origin: .zero, size: self).applying(t)
        return rect.size
    }
}

extension CGRect {
    public func applying(_ t: CGAffineTransform) -> CGRect {
        // Transform all four corners and compute bounding rect
        let p1 = CGPoint(x: minX, y: minY).applying(t)
        let p2 = CGPoint(x: maxX, y: minY).applying(t)
        let p3 = CGPoint(x: minX, y: maxY).applying(t)
        let p4 = CGPoint(x: maxX, y: maxY).applying(t)

        let xs = [p1.x, p2.x, p3.x, p4.x]
        let ys = [p1.y, p2.y, p3.y, p4.y]

        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 0
        let minY = ys.min() ?? 0
        let maxY = ys.max() ?? 0

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

#endif
