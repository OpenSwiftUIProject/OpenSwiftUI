//
//  ProjectionTransform.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

public import Foundation
#if canImport(QuartzCore)
public import QuartzCore
#endif

@frozen
public struct ProjectionTransform {
    public var m11: CGFloat = 1.0, m12: CGFloat = 0.0, m13: CGFloat = 0.0
    public var m21: CGFloat = 0.0, m22: CGFloat = 1.0, m23: CGFloat = 0.0
    public var m31: CGFloat = 0.0, m32: CGFloat = 0.0, m33: CGFloat = 1.0

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

    @inlinable public init(_ m: CATransform3D) {
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

    public mutating func invert() -> Bool {
        // TODO:
        false
    }

    public func inverted() -> ProjectionTransform {
        // TODO:
        self
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
    public func applying(_: ProjectionTransform) -> CGPoint {
        // TODO:
        self
    }
}

struct CodableProjectionTransform {
    var base: ProjectionTransform
}
