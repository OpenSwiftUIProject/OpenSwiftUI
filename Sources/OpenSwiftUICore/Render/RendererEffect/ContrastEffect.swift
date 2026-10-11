//
//  ContrastEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - _ContrastEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _ContrastEffect: RendererEffect, Equatable {
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
        .filter(.contrast(amount))
    }
}

// MARK: - View + contrast

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Sets the contrast and separation between similar colors in this view.
    ///
    /// Apply contrast to a view to increase or decrease the separation between
    /// similar colors in the view.
    ///
    /// In the example below, the `contrast(_:)` modifier is applied to a set of
    /// red squares each containing a contrasting green inner circle. At each
    /// step in the loop, the `contrast(_:)` modifier changes the contrast of
    /// the circle/square view in 20% increments. This ranges from -20% contrast
    /// (yielding inverted colors — turning the red square to pale-green and the
    /// green circle to mauve), to neutral-gray at 0%, to 100% contrast
    /// (bright-red square / bright-green circle). Applying negative contrast
    /// values, as shown in the -20% square, will apply contrast in addition to
    /// inverting colors.
    ///
    ///     struct CircleView: View {
    ///         var body: some View {
    ///             Circle()
    ///                 .fill(Color.green)
    ///                 .frame(width: 25, height: 25, alignment: .center)
    ///         }
    ///     }
    ///
    ///     struct Contrast: View {
    ///         var body: some View {
    ///             HStack {
    ///                 ForEach(-1..<6) {
    ///                     Color.red.frame(width: 50, height: 50, alignment: .center)
    ///                         .overlay(CircleView(), alignment: .center)
    ///                         .contrast(Double($0) * 0.2)
    ///                         .overlay(Text("\(Double($0) * 0.2 * 100, specifier: "%.0f")%")
    ///                                      .font(.callout),
    ///                                  alignment: .bottom)
    ///                         .border(Color.gray)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![Demonstration of the effect of contrast on a view applying contrast
    /// values from -20% to 100% contrast.](OpenSwiftUI-View-contrast)
    ///
    /// - Parameter amount: The intensity of color contrast to apply. negative
    ///   values invert colors in addition to applying contrast.
    ///
    /// - Returns: A view that applies color contrast to this view.
    @inlinable
    nonisolated public func contrast(_ amount: Double) -> some View {
        modifier(_ContrastEffect(amount: amount))
    }
}
