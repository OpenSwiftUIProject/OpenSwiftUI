//
//  LengthUnitConvertible.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(visionOS)

package import CoreFoundation
public import Spatial
import simd

// MARK: - LengthUnitConvertible

package protocol LengthUnitConvertible: Equatable {
    mutating func scale(by factor: Double)
}

extension LengthUnitConvertible {
    @_disfavoredOverload
    package func scaled(by factor: Double) -> Self {
        var result = self
        result.scale(by: factor)
        return result
    }
}

extension CGFloat: LengthUnitConvertible {}

extension Double: LengthUnitConvertible {}

extension CGSize: LengthUnitConvertible {
    package mutating func scale(by factor: Double) {
        width *= factor
        height *= factor
    }
}

extension CGPoint: LengthUnitConvertible {
    package mutating func scale(by factor: Double) {
        x *= factor
        y *= factor
    }
}

extension CGRect: LengthUnitConvertible {
    package mutating func scale(by factor: Double) {
        origin.scale(by: factor)
        size.scale(by: factor)
    }
}

//extension Size3D: LengthUnitConvertible {}

//extension Point3D: LengthUnitConvertible {}

extension Rect3D: LengthUnitConvertible {
    package mutating func scale(by factor: Double) {
//        origin.scale(by: factor)
//        size.uniformlyScale(by: factor)
        _openSwiftUIUnimplementedWarning()
    }
}

@_spi(ForOpenSwiftUIOnly)
extension ViewTransform: LengthUnitConvertible {
    package mutating func scale(by factor: Double) {
//        guard factor != 1 else { return }
//        let size = Size3D.one.uniformlyScaled(by: factor)
//        appendAffineTransform3D(AffineTransform3D(scale: size), inverse: true)
        _openSwiftUIUnimplementedWarning()
    }
}

extension _ProposedSize: LengthUnitConvertible {
    package mutating func scale(by factor: Double) {
        width? *= factor
        height? *= factor
    }
}

#endif
