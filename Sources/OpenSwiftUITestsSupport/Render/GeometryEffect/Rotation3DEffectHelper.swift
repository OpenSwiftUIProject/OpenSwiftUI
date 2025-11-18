//
//  Rotation3DEffectHelper.swift
//  OpenSwiftUITestsSupport

#if OPENSWIFTUI
package import Foundation
package import OpenSwiftUICore

extension _Rotation3DEffect.Data: Hashable {
    package static func == (lhs: _Rotation3DEffect.Data, rhs: _Rotation3DEffect.Data) -> Bool {
        lhs.angle == rhs.angle &&
        lhs.axis == rhs.axis &&
        lhs.anchor == rhs.anchor &&
        lhs.perspective == rhs.perspective &&
        (lhs.flipWidth.isNaN && rhs.flipWidth.isNaN || lhs.flipWidth == rhs.flipWidth)
    }

    package func hash(into hasher: inout Hasher) {
        angle.hash(into: &hasher)
        axis.x.hash(into: &hasher)
        axis.y.hash(into: &hasher)
        axis.z.hash(into: &hasher)
        anchor.x.hash(into: &hasher)
        anchor.y.hash(into: &hasher)
        anchor.z.hash(into: &hasher)
        perspective.hash(into: &hasher)
        flipWidth.hash(into: &hasher)
    }

    package func isAlmostEqual(to other: _Rotation3DEffect.Data) -> Bool {
        angle.radians.isAlmostEqual(to: other.angle.radians) &&
        axis.x.isAlmostEqual(to: other.axis.x) &&
        axis.y.isAlmostEqual(to: other.axis.y) &&
        axis.z.isAlmostEqual(to: other.axis.z) &&
        anchor.x.isAlmostEqual(to: other.anchor.x) &&
        anchor.y.isAlmostEqual(to: other.anchor.y) &&
        anchor.z.isAlmostEqual(to: other.anchor.z) &&
        perspective.isAlmostEqual(to: other.perspective) &&
        (flipWidth.isNaN && other.flipWidth.isNaN || flipWidth.isAlmostEqual(to: other.flipWidth))
    }

    package init(
        angle: Angle = .zero,
        axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (.zero, .zero, .zero),
        anchor: (x: CGFloat, y: CGFloat, z: CGFloat) = (.zero, .zero, .zero),
        perspective: CGFloat = .zero,
        flipWidth: CGFloat
    ) {
        var data = _Rotation3DEffect.Data()
        data.angle = angle
        data.axis = axis
        data.anchor = anchor
        data.perspective = perspective
        data.flipWidth = flipWidth
        self = data
    }
}
#endif
