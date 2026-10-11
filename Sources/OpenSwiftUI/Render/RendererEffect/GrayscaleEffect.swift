//
//  GrayscaleEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - VisualEffect + grayscale

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Adds a grayscale effect to the view.
    ///
    /// A grayscale effect reduces the intensity of colors in the view.
    ///
    /// - Parameter amount: The intensity of grayscale to apply from 0.0 to less
    ///   than 1.0. Values closer to 0.0 are more colorful, and values closer to
    ///   1.0 are less colorful.
    ///
    /// - Returns: An effect that reduces the intensity of colors in the view.
    public func grayscale(_ amount: Double) -> some VisualEffect {
        rendererEffect(_GrayscaleEffect(amount: amount))
    }
}
