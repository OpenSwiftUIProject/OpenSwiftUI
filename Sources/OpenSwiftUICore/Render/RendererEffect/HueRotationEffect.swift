//
//  HueRotationEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _HueRotationEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _HueRotationEffect: RendererEffect, Equatable {
    public var angle: Angle

    @inlinable
    nonisolated public init(angle: Angle) {
        self.angle = angle
    }

    public var animatableData: Angle.AnimatableData {
        get { angle.animatableData }
        set { angle.animatableData = newValue }
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .filter(.hueRotation(angle))
    }
}

// MARK: - View + hueRotation

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Applies a hue rotation effect to this view.
    ///
    /// Use hue rotation effect to shift all of the colors in a view according
    /// to the angle you specify.
    ///
    /// The example below shows a series of squares filled with a linear
    /// gradient. Each square shows the effect of a 36˚ hueRotation (a total of
    /// 180˚ across the 5 squares) on the gradient:
    ///
    ///     struct HueRotation: View {
    ///         var body: some View {
    ///             HStack {
    ///                 ForEach(0..<6) {
    ///                     Rectangle()
    ///                         .fill(.linearGradient(
    ///                             colors: [.blue, .red, .green],
    ///                             startPoint: .top, endPoint: .bottom))
    ///                         .hueRotation((.degrees(Double($0 * 36))))
    ///                         .frame(width: 60, height: 60, alignment: .center)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![Shows the effect of hueRotation on a linear
    /// gradient.](OpenSwiftUI-hueRotation)
    ///
    /// - Parameter angle: The hue rotation angle to apply to the colors in this
    ///   view.
    ///
    /// - Returns: A view that applies a hue rotation effect to this view.
    @inlinable
    nonisolated public func hueRotation(_ angle: Angle) -> some View {
        modifier(_HueRotationEffect(angle: angle))
    }
}
