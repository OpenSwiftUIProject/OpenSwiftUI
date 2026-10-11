//
//  HueRotationEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - VisualEffect + hueRotation

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Applies a hue rotation effect to the view.
    ///
    /// Use hue rotation effect to shift all of the colors in a view according
    /// to the angle you specify.
    ///
    /// - Parameter angle: The hue rotation angle to apply to the colors in the
    ///   view.
    ///
    /// - Returns: An effect that shifts all of the colors in the view.
    public func hueRotation(_ angle: Angle) -> some VisualEffect {
        rendererEffect(_HueRotationEffect(angle: angle))
    }
}
