//
//  BrightnessEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _BrightnessEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _BrightnessEffect: RendererEffect, Equatable {
    public var amount: Double

    @inlinable
    nonisolated public init(amount: Double) {
        self.amount = amount
    }

    public var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .filter(.brightness(amount))
    }
}

// MARK: - View + brightness

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Brightens this view by the specified amount.
    ///
    /// Use `brightness(_:)` to brighten the intensity of the colors in a view.
    /// The example below shows a series of red squares, with their brightness
    /// increasing from 0 (fully red) to 100% (white) in 20% increments.
    ///
    ///     struct Brightness: View {
    ///         var body: some View {
    ///             HStack {
    ///                 ForEach(0..<6) {
    ///                     Color.red.frame(width: 60, height: 60, alignment: .center)
    ///                         .brightness(Double($0) * 0.2)
    ///                         .overlay(Text("\(Double($0) * 0.2 * 100, specifier: "%.0f")%"),
    ///                                  alignment: .bottom)
    ///                         .border(Color.gray)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![Rendering showing the effects of brightness adjustments in 20%
    /// increments from fully-red to white.](OpenSwiftUI-View-brightness)
    ///
    /// - Parameter amount: A value between 0 (no effect) and 1 (full white
    ///   brightening) that represents the intensity of the brightness effect.
    ///
    /// - Returns: A view that brightens this view by the specified amount.
    @inlinable
    nonisolated public func brightness(_ amount: Double) -> some View {
        modifier(_BrightnessEffect(amount: amount))
    }
}
