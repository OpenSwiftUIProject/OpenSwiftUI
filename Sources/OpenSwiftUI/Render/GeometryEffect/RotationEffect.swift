//
//  RotationEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - View + repeatingRotationEffect

@available(OpenSwiftUI_v2_0, *)
extension View {
    @_spi(Private)
    nonisolated public func repeatingRotationEffect(
        anchor: UnitPoint = .center,
        duration: Double = 1.0
    ) -> some View {
        repeatingRotationEffect(
            from: .zero,
            to: .degrees(360),
            anchor: anchor,
            animation: .linear(duration: duration)
        )
    }

    @_spi(Private)
    nonisolated public func repeatingRotationEffect(
        from: Angle,
        to: Angle,
        anchor: UnitPoint = .center,
        animation: Animation = .linear(duration: 1.0)
    ) -> some View {
        appearanceAnimation(animation: animation.repeatForever(autoreverses: false)) { view, isActive in
            view.rotationEffect(isActive ? to : from, anchor: anchor)
        }
    }
}

// MARK: - VisualEffect + rotationEffect

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Rotates content in two dimensions around the specified point.
    ///
    /// This effect rotates the content around the axis that points
    /// out of the xy-plane. It has no effect on the content's frame.
    /// The following code rotates text by 22˚ and then draws a border around
    /// the modified view to show that the frame remains unchanged by the
    /// rotation:
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .visualEffect { content, geometryProxy in
    ///             content
    ///                 .rotationEffect(.degrees(22))
    ///         }
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of text and a wide grey box. The text says Rotation by passing an angle in degrees. The baseline of the text is rotated clockwise by 22 degrees relative to the box. The center of the box and the center of the text are aligned.](OpenSwiftUI-View-rotationEffect)
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the content.
    ///   - anchor: A unit point within the content about which to
    ///     perform the rotation. The default value is ``UnitPoint/center``.
    /// - Returns: A rotation effect.
    public func rotationEffect(_ angle: Angle, anchor: UnitPoint = .center) -> some VisualEffect {
        geometryEffect(_RotationEffect(angle: angle, anchor: anchor))
    }
}

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(*, deprecated, message: "Use rotationEffect instead")
extension VisualEffect {
    public func rotation(_ angle: Angle, anchor: UnitPoint = .center) -> some VisualEffect {
        rotationEffect(angle, anchor: anchor)
    }
}

// MARK: - HoverEffectContent + rotationEffect

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    /// Rotates content in two dimensions around the specified point.
    ///
    /// This effect rotates the content around the axis that points
    /// out of the xy-plane. It has no effect on the content's frame.
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the content.
    ///   - anchor: A unit point within the content about which to
    ///     perform the rotation. The default value is ``UnitPoint/center``.
    /// - Returns: A rotation effect.
    public func rotationEffect(_ angle: Angle, anchor: UnitPoint = .center) -> some HoverEffectContent {
        geometryEffect(_RotationEffect(angle: angle, anchor: anchor))
    }
}
