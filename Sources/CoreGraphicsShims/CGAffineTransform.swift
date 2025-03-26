//
//  CGAffineTransform.swift
//  CoreGraphicsShims

#if !canImport(CoreGraphics)
public import Foundation

public struct CGAffineTransform: Equatable {
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
    
    public func concatenating(_ transform: CGAffineTransform) -> CGAffineTransform {
        preconditionFailure("Unimplemented")
    }
    
    public func inverted() -> CGAffineTransform {
        preconditionFailure("Unimplemented")
    }
}

extension CGPoint {
    public func applying(_ t: CGAffineTransform) -> CGPoint {
        preconditionFailure("Unimplemented")
    }
}

extension CGSize {
    public func applying(_ t: CGAffineTransform) -> CGSize {
        preconditionFailure("Unimplemented")
    }
}

extension CGRect {
    public func applying(_ t: CGAffineTransform) -> CGRect {
        preconditionFailure("Unimplemented")
    }
}

#endif
