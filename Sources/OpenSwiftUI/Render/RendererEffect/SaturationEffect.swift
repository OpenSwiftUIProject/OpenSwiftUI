//
//  SaturationEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - VisualEffect + saturation

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Adjusts the color saturation of the view.
    ///
    /// Use color saturation to increase or decrease the intensity of colors in
    /// a view.
    ///
    /// - SeeAlso: `contrast(_:)`
    /// - Parameter amount: The amount of saturation to apply to the view.
    ///
    /// - Returns: An effect that adjusts the saturation of the view.
    public func saturation(_ amount: Double) -> some VisualEffect {
        rendererEffect(_SaturationEffect(amount: amount))
    }
}
