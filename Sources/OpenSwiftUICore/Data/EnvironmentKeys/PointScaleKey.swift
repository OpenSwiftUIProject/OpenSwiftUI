//
//  PointScaleKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(visionOS)
public import Foundation

@_spi(_)
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension EnvironmentValues {
    public var pointsPerMeter: CGFloat {
        get { pointScale.pointsPerMeter }
        set { pointScale.pointsPerMeter = newValue }
    }

    package var pointScale: PointScale {
        get { self[PointScaleKey.self] }
        set { self[PointScaleKey.self] = newValue }
    }
}

package struct PointScaleKey: BridgedEnvironmentKey {
    package static let defaultValue = PointScale(pointsPerMeter: 1360.0)
}
#endif
