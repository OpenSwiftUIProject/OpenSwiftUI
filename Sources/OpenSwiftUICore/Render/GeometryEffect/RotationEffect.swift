//
//  RotationEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import CoreGraphicsShims

// MARK: - RotationEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _RotationEffect: GeometryEffect, Equatable {

    public var angle: Angle

    public var anchor: UnitPoint

    @inlinable
    nonisolated public init(angle: Angle, anchor: UnitPoint = .center) {
        self.angle = angle
        self.anchor = anchor
    }

    package struct Data {
        package var angle: Angle

        package var anchor: CGPoint

        package init() {
            angle = .zero
            anchor = .zero
        }

        package init(_ effect: _RotationEffect, size: CGSize, layoutDirection: LayoutDirection = .leftToRight) {
            var s = effect.anchor.in(size)
            var a = effect.angle
            if layoutDirection == .rightToLeft {
                s.x = size.width - s.x
                a.negate()
            }
            angle = a
            anchor = s
        }

        package var transform: CGAffineTransform {
            CGAffineTransform(translationX: anchor.x, y: anchor.y)
                .rotated(by: angle)
                .translatedBy(x: -anchor.x, y: -anchor.y)
        }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let data = Data(self, size: size)
        return .init(data.transform)
    }

    public typealias AnimatableData = AnimatablePair<Angle.AnimatableData, UnitPoint.AnimatableData>

    public var animatableData: _RotationEffect.AnimatableData {
        get { .init(angle.animatableData, anchor.animatableData) }
        set {
            angle.animatableData = newValue.first
            anchor.animatableData = newValue.second
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Rotates a view's rendered output in two dimensions around the specified
    /// point.
    ///
    /// This modifier rotates the view's content around the axis that points
    /// out of the xy-plane. It has no effect on the view's frame.
    /// The following code rotates text by 22˚ and then draws a border around
    /// the modified view to show that the frame remains unchanged by the
    /// rotation modifier:
    ///
    ///     Text("Rotation by passing an angle in degrees")
    ///         .rotationEffect(.degrees(22))
    ///         .border(Color.gray)
    ///
    /// ![A screenshot of text and a wide grey box. The text says Rotation by passing an angle in degrees. The baseline of the text is rotated clockwise by 22 degrees relative to the box. The center of the box and the center of the text are aligned.](OpenSwiftUI-View-rotationEffect)
    ///
    /// - Parameters:
    ///   - angle: The angle by which to rotate the view.
    ///   - anchor: A unit point within the view about which to
    ///     perform the rotation. The default value is ``UnitPoint/center``.
    /// - Returns: A view with rotated content.
    @inlinable
    nonisolated public func rotationEffect(_ angle: Angle, anchor: UnitPoint = .center) -> some View {
        modifier(_RotationEffect(angle: angle, anchor: anchor))
    }
}

extension _RotationEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, angle.radians)
        try encoder.messageField(2, anchor, defaultValue: .center)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var effect = _RotationEffect(angle: .zero, anchor: .center)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: effect.angle = try .init(radians: decoder.doubleField(field))
            case 2: effect.anchor = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = effect
    }
}

extension _RotationEffect.Data: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, angle.radians)
        try encoder.messageField(2, anchor)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var data = _RotationEffect.Data()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: data.angle = try .init(radians: decoder.doubleField(field))
            case 2: data.anchor = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = data
    }
}
