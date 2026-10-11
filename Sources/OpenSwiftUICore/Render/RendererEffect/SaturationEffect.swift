//
//  SaturationEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _SaturationEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _SaturationEffect: RendererEffect, Equatable {
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
        .filter(.saturation(amount))
    }
}

// MARK: - View + saturation

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adjusts the color saturation of this view.
    ///
    /// Use color saturation to increase or decrease the intensity of colors in
    /// a view.
    ///
    /// The example below shows a series of red squares with their saturation
    /// increasing from 0 (gray) to 100% (fully-red) in 20% increments:
    ///
    ///     struct Saturation: View {
    ///         var body: some View {
    ///             HStack {
    ///                 ForEach(0..<6) {
    ///                     Color.red.frame(width: 60, height: 60, alignment: .center)
    ///                         .saturation(Double($0) * 0.2)
    ///                         .overlay(Text("\(Double($0) * 0.2 * 100, specifier: "%.0f")%"),
    ///                                  alignment: .bottom)
    ///                         .border(Color.gray)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![Rendering showing the effects of saturation adjustments in 20%
    /// increments from gray at 0% to fully-red at
    /// 100%.](OpenSwiftUI-View-saturation)
    ///
    /// - SeeAlso: `contrast(_:)`
    /// - Parameter amount: The amount of saturation to apply to this view.
    ///
    /// - Returns: A view that adjusts the saturation of this view.
    @inlinable
    nonisolated public func saturation(_ amount: Double) -> some View {
        modifier(_SaturationEffect(amount: amount))
    }
}
