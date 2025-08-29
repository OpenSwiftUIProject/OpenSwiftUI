//
//  Rotation3DEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenQuartzCoreShims

// MARK: - RotationEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _Rotation3DEffect: GeometryEffect, Equatable {
    public var angle: Angle

    public var axis: (x: CGFloat, y: CGFloat, z: CGFloat)

    public var anchor: UnitPoint

    public var anchorZ: CGFloat

    public var perspective: CGFloat

    @_alwaysEmitIntoClient
    public init(
        angle: Angle,
        axis: (x: CGFloat, y: CGFloat, z: CGFloat),
        anchor: UnitPoint = .center,
        anchorZ: CGFloat = 0,
        perspective: CGFloat = 1
    ) {
        self.angle = angle
        self.axis = axis
        self.anchor = anchor
        self.anchorZ = anchorZ
        self.perspective = perspective
    }

    package struct Data {
        package var angle: Angle
        package var axis: (x: CGFloat, y: CGFloat, z: CGFloat)
        package var anchor: (x: CGFloat, y: CGFloat, z: CGFloat)
        package var perspective: CGFloat
        package var flipWidth: CGFloat

        package init() {
            angle = .zero
            axis = (.zero, .zero, .zero)
            anchor = (.zero, .zero, .zero)
            perspective = .zero
            flipWidth = .nan
        }

        package init(_ effect: _Rotation3DEffect, size: CGSize, layoutDirection: LayoutDirection = .leftToRight) {
            let m = max(size.width, size.height)
            angle = effect.angle
            axis = effect.axis
            let f = layoutDirection == .rightToLeft ? size.width : .nan
            let s = effect.anchor.in(size)
            anchor = (s.x, s.y, effect.anchorZ)
            perspective = m / effect.perspective
            flipWidth = f
        }

        package var transform: ProjectionTransform {
            let i = CATransform3DIdentity
            let t1 = CATransform3DTranslate(i, anchor.x, anchor.y, anchor.z)
            var p = i
            p.m34 = -1 / perspective
            let r = CATransform3DRotate(CATransform3DConcat(p, t1), angle.radians, axis.x, axis.y, axis.z)
            let t2 = CATransform3DTranslate(r, -anchor.x, -anchor.y, -anchor.z)
            var transform = ProjectionTransform(t2)
            if flipWidth.isFinite {
                let base = ProjectionTransform(
                    m11: -1, m12: 0, m13: 0,
                    m21: 0, m22: 1, m23: 0,
                    m31: flipWidth, m32: 0, m33: 1
                )
                transform = base.concatenating(transform).concatenating(base)
            }
            return transform
        }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let data = Data(self, size: size)
        return data.transform
    }

    public typealias AnimatableData = AnimatablePair<
        Angle.AnimatableData,
        AnimatablePair<
            CGFloat,
            AnimatablePair<
                CGFloat,
                AnimatablePair<
                    CGFloat,
                    AnimatablePair<
                        UnitPoint.AnimatableData,
                        AnimatablePair<
                            CGFloat,
                            CGFloat
                        >
                    >
                >
            >
        >
    >

    public var animatableData: _Rotation3DEffect.AnimatableData {
        get {
            .init(
                angle.animatableData,
                .init(
                    axis.x.animatableData,
                    .init(
                        axis.y.animatableData,
                        .init(
                            axis.z.animatableData,
                            .init(
                                anchor.animatableData,
                                .init(
                                    anchorZ.animatableData,
                                    perspective.animatableData
                                )
                            )
                        )
                    )
                )
            )
        }
        set {
            angle.animatableData = newValue.first
            axis.x.animatableData = newValue.second.first
            axis.y.animatableData = newValue.second.second.first
            axis.z.animatableData = newValue.second.second.second.first
            anchor.animatableData = newValue.second.second.second.second.first
            anchorZ.animatableData = newValue.second.second.second.second.second.first
            perspective.animatableData = newValue.second.second.second.second.second.second
        }
    }

    public static func == (lhs: _Rotation3DEffect, rhs: _Rotation3DEffect) -> Bool {
        lhs.angle == rhs.angle &&
        lhs.axis == rhs.axis &&
        lhs.anchor == rhs.anchor &&
        lhs.anchorZ == rhs.anchorZ &&
        lhs.perspective == rhs.perspective
    }
}

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

extension _Rotation3DEffect.Data: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, angle.radians)
        encoder.floatField(2, Float(axis.x))
        encoder.floatField(3, Float(axis.y))
        encoder.floatField(4, Float(axis.z))
        encoder.cgFloatField(5, anchor.x)
        encoder.cgFloatField(6, anchor.y)
        encoder.cgFloatField(7, anchor.z)
        encoder.cgFloatField(8, perspective)
        var flipWidth = flipWidth
        if flipWidth.isInfinite || flipWidth.isNaN {
            flipWidth = .zero
        }
        encoder.cgFloatField(9, flipWidth)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var data = _Rotation3DEffect.Data()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: data.angle = try .init(radians: decoder.doubleField(field))
            case 2: data.axis.x = try CGFloat(decoder.floatField(field))
            case 3: data.axis.y = try CGFloat(decoder.floatField(field))
            case 4: data.axis.z = try CGFloat(decoder.floatField(field))
            case 5: data.anchor.x = try decoder.cgFloatField(field)
            case 6: data.anchor.y = try decoder.cgFloatField(field)
            case 7: data.anchor.z = try decoder.cgFloatField(field)
            case 8: data.perspective = try decoder.cgFloatField(field)
            case 9: data.flipWidth = try decoder.cgFloatField(field)
            default: try decoder.skipField(field)
            }
        }
        self = data
    }
}
