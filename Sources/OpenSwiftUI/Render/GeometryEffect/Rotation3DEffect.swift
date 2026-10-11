//
//  Rotation3DEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims
public import OpenSwiftUICore

// MARK: - View + rotation3DEffect

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Renders a view's content as if it's rotated in three dimensions around
    /// the specified axis.
    ///
    /// Use this method to create the effect of rotating a view in three
    /// dimensions around a specified axis of rotation. The modifier projects
    /// the rotated content onto the original view's plane. Use the
    /// `perspective` value to control the renderer's vanishing point. The
    /// following example creates the appearance of rotating text 45˚ about
    /// the y-axis:
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .rotation3DEffect(
    ///             .degrees(45),
    ///             axis: (x: 0.0, y: 1.0, z: 0.0),
    ///             anchor: .center,
    ///             anchorZ: 0,
    ///             perspective: 1)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of text in a grey box. The text says Rotation by passing an angle in degrees. The text is rendered in a way that makes it appear farther from the viewer on the right side and closer on the left, as if the text is angled to face someone sitting on the viewer's right.](OpenSwiftUI-View-rotation3DEffect)
    ///
    /// > Important: In visionOS, create this effect with
    ///   ``perspectiveRotationEffect(_:axis:anchor:anchorZ:perspective:)``
    ///   instead. To truly rotate a view in three dimensions,
    ///   use a 3D rotation modifier without a perspective input like
    ///   ``rotation3DEffect(_:axis:anchor:)``.
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the view's content.
    ///   - axis: The axis of rotation, specified as a tuple with named
    ///     elements for each of the three spatial dimensions.
    ///   - anchor: A two dimensional unit point within the view about which to
    ///     perform the rotation. The default value is ``UnitPoint/center``.
    ///   - anchorZ: The location on the z-axis around which to rotate the
    ///     content. The default is `0`.
    ///   - perspective: The relative vanishing point for the rotation. The
    ///     default is `1`.
    /// - Returns: A view with rotated content.
    @inlinable
    nonisolated public func rotation3DEffect(
        _ angle: Angle,
        axis: (x: CGFloat, y: CGFloat, z: CGFloat),
        anchor: UnitPoint = .center,
        anchorZ: CGFloat = 0,
        perspective: CGFloat = 1
    ) -> some View {
        modifier(
            _Rotation3DEffect(
                angle: angle, axis: axis, anchor: anchor, anchorZ: anchorZ,
                perspective: perspective
            )
        )
    }
}

// MARK: - VisualEffect + rotation3DEffect

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Renders content as if it's rotated in three dimensions around
    /// the specified axis.
    ///
    /// Use this method to create the effect of rotating a two dimensional view
    /// in three dimensions around a specified axis of rotation. The effect
    /// projects the rotated content onto the original content's plane. Use the
    /// `perspective` input to control the renderer's vanishing point.
    /// The following example creates the appearance of rotating
    /// text 45˚ about the y-axis:
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .visualEffect { content, geometryProxy in
    ///             content
    ///                 .rotation3DEffect(
    ///                     .degrees(45),
    ///                     axis: (x: 0.0, y: 1.0, z: 0.0),
    ///                     anchor: .center,
    ///                     anchorZ: 0,
    ///                     perspective: 1)
    ///             }
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of text in a grey box. The text says Rotation by passing an angle in degrees. The text is rendered in a way that makes it appear farther from the viewer on the right side and closer on the left, as if the text is angled to face someone sitting on the viewer's right.](OpenSwiftUI-View-rotation3DEffect)
    ///
    /// > Important: In visionOS, create this effect with
    ///   ``perspectiveRotationEffect(_:axis:anchor:perspective:)``
    ///   instead. To truly rotate a view in three dimensions,
    ///   use a 3D rotation effect without a perspective input like
    ///   ``rotation3DEffect(_:axis:anchor:)``.
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the content.
    ///   - axis: The axis of rotation, specified as a tuple with named
    ///     elements for each of the three spatial dimensions.
    ///   - anchor: A two dimensional unit point within the content about which
    ///     to perform the rotation. The default value is ``UnitPoint/center``.
    ///   - anchorZ: The location on the z-axis around which to rotate the
    ///     content. The default is `0`.
    ///   - perspective: The relative vanishing point for the rotation. The
    ///     default is `1`.
    /// - Returns: A rotation effect.
    public func rotation3DEffect(
        _ angle: Angle,
        axis: (x: CGFloat, y: CGFloat, z: CGFloat),
        anchor: UnitPoint = .center,
        anchorZ: CGFloat = 0,
        perspective: CGFloat = 1
    ) -> some VisualEffect {
        geometryEffect(_Rotation3DEffect(
            angle: angle,
            axis: axis,
            anchor: anchor,
            anchorZ: anchorZ,
            perspective: perspective
        ))
    }
}

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(*, deprecated, message: "Use rotation3DEffect instead")
extension VisualEffect {
    public func rotation3D(
        _ angle: Angle,
        axis: (x: CGFloat, y: CGFloat, z: CGFloat),
        anchor: UnitPoint = .center,
        anchorZ: CGFloat = 0,
        perspective: CGFloat = 1
    ) -> some VisualEffect {
        rotation3DEffect(
            angle,
            axis: axis,
            anchor: anchor,
            anchorZ: anchorZ,
            perspective: perspective
        )
    }
}
