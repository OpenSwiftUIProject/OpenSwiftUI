//
//  ContrastEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - VisualEffect + contrast

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Sets the contrast and separation between similar colors in the view.
    ///
    /// Apply contrast to a view to increase or decrease the separation between
    /// similar colors in the view.
    ///
    /// - Parameter amount: The intensity of color contrast to apply. negative
    ///   values invert colors in addition to applying contrast.
    ///
    /// - Returns: An effect that applies color contrast to the view.
    public func contrast(_ amount: Double) -> some VisualEffect {
        rendererEffect(_ContrastEffect(amount: amount))
    }
}
