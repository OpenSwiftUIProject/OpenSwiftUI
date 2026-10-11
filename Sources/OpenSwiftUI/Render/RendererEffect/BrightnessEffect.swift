//
//  BrightnessEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - VisualEffect + brightness

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Brightens the view by the specified amount.
    ///
    /// - Parameter amount: A value between 0 (no effect) and 1 (full white
    ///   brightening) that represents the intensity of the brightness effect.
    ///
    /// - Returns: An effect that brightens the view by the specified amount.
    public func brightness(_ amount: Double) -> some VisualEffect {
        rendererEffect(_BrightnessEffect(amount: amount))
    }
}
