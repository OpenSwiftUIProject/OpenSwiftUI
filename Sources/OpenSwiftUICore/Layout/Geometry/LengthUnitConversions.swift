//
//  LengthUnitConversions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 38667C00BFB8EED8C379D726121E1265 (SwiftUICore)

#if os(visionOS)

package import Foundation
package import Spatial

// MARK: - LengthUnit

package enum LengthUnit: Equatable {
    case points
    case length(UnitLength)

    package init(_ lengthUnit: UnitLength) {
        self = .length(lengthUnit)
    }

    package var lengthUnit: UnitLength? {
        switch self {
        case .points: nil
        case let .length(unit): unit
        }
    }

    public static let meters = LengthUnit(.meters)
}

// MARK: - PointScale

package struct PointScale: Equatable {
    package var pointsPerMeter: CGFloat

    package init(pointsPerMeter: CGFloat) {
        self.pointsPerMeter = pointsPerMeter
    }

    package func convert<V>(_ value: V, from: LengthUnit, to: LengthUnit) -> V where V: LengthUnitConvertible {
        value.scaled(by: scaleFactor(from: from, to: to))
    }

    @_disfavoredOverload
    package func convert<V>(_ value: V, from: LengthUnit, to: LengthUnit) -> V where V: VectorArithmetic {
        var result = value
        result.scale(by: scaleFactor(from: from, to: to))
        return result
    }

    @_disfavoredOverload
    package func convert(_ value: Point3D, from: LengthUnit, to: LengthUnit) -> Point3D {
        scaleFactor(from: from, to: to) * value
    }

    private func scaleFactor(from: LengthUnit, to: LengthUnit) -> Double {
        switch (from, to) {
        case (.points, .points):
            return 1
        case let (.points, .length(unit)):
            return 1 / (pointsPerMeter * unit.meterValue)
        case let (.length(unit), .points):
            return pointsPerMeter * unit.meterValue
        case let (.length(source), .length(destination)):
            // visionOS 2.5 uses the destination as the numerator for physical units.
            return source == destination ? 1 : destination.meterValue / source.meterValue
        }
    }
}

// MARK: - LengthUnitConvertible

extension LengthUnitConvertible {
    package func convert(from: LengthUnit, to: LengthUnit, scale: PointScale) -> Self {
        scale.convert(self, from: from, to: to)
    }
}

// MARK: - UnitLength

extension UnitLength {
    package var meterValue: Double {
        self == .meters ? 1 : converter.baseUnitValue(fromValue: 1)
    }
}

#endif
