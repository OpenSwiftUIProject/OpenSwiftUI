//
//  GrayscaleEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _GrayscaleEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _GrayscaleEffect: RendererEffect, Equatable {
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
        .filter(.grayscale(amount))
    }
}

// MARK: - View + grayscale

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds a grayscale effect to this view.
    ///
    /// A grayscale effect reduces the intensity of colors in this view.
    ///
    /// The example below shows a series of red squares with their grayscale
    /// effect increasing from 0 (reddest) to 99% (fully desaturated) in
    /// approximate 20% increments:
    ///
    ///     struct Saturation: View {
    ///         var body: some View {
    ///             HStack {
    ///                 ForEach(0..<6) {
    ///                     Color.red.frame(width: 60, height: 60, alignment: .center)
    ///                         .grayscale(Double($0) * 0.1999)
    ///                         .overlay(Text("\(Double($0) * 0.1999 * 100, specifier: "%.4f")%"),
    ///                                  alignment: .bottom)
    ///                         .border(Color.gray)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![Rendering showing the effects of grayscale adjustments in
    /// approximately 20% increments from fully-red at 0% to fully desaturated
    /// at 99%.](OpenSwiftUI-View-grayscale)
    ///
    /// - Parameter amount: The intensity of grayscale to apply from 0.0 to less
    ///   than 1.0. Values closer to 0.0 are more colorful, and values closer to
    ///   1.0 are less colorful.
    ///
    /// - Returns: A view that adds a grayscale effect to this view.
    @inlinable
    nonisolated public func grayscale(_ amount: Double) -> some View {
        modifier(_GrayscaleEffect(amount: amount))
    }
}
