//
//  PlatformGradient.swift
//  OpenSwiftUICore

#if UIKIT_CROSS_PLATFORM
package import Foundation

@_spi(DisplayList_ViewSystem)
public struct PlatformGradient: Equatable {
    package enum Geometry: Equatable {
        case linear(start: CGPoint, end: CGPoint)
        case radial(center: CGPoint, start: CGFloat, end: CGFloat)
        case elliptical(center: CGPoint, size: CGSize, start: CGFloat, end: CGFloat)
        case conic(center: CGPoint, angle: Angle)
    }

    package let gradient: ResolvedGradient
    package let geometry: Geometry

    init?(_ paint: AnyResolvedPaint, bounds: CGRect) {
        func unwrap<P: ResolvedPaint>(_ type: P.Type) -> (P, CGRect)? {
            if let anchored = paint.as(type: AnchoredResolvedPaint<P>.self) {
                return (anchored.paint, anchored.bounds)
            }
            return paint.as(type: type).map { ($0, bounds) }
        }

        if let (linear, rect) = unwrap(LinearGradient._Paint.self) {
            gradient = linear.gradient
            geometry = .linear(start: linear.startPoint.in(rect), end: linear.endPoint.in(rect))
        } else if let (radial, rect) = unwrap(RadialGradient._Paint.self) {
            gradient = radial.gradient
            geometry = .radial(center: radial.center.in(rect), start: radial.startRadius, end: radial.endRadius)
        } else if let (elliptical, rect) = unwrap(EllipticalGradient._Paint.self) {
            gradient = elliptical.gradient
            geometry = .elliptical(
                center: elliptical.center.in(rect), size: rect.size,
                start: elliptical.startRadiusFraction, end: elliptical.endRadiusFraction
            )
        } else if let (angular, rect) = unwrap(AngularGradient._Paint.self) {
            let conic = ConicGradient(angular: angular, bounds: rect)
            gradient = conic.gradient
            geometry = .conic(center: conic.center, angle: conic.angle)
        } else {
            return nil
        }
    }
}
#endif
