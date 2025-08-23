//
//  Rotation3DEffectHelper.swift
//  OpenSwiftUITestsSupport

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

    package static func ~= (lhs: _Rotation3DEffect.Data, rhs: _Rotation3DEffect.Data) -> Bool {
        lhs.angle.radians.isAlmostEqual(to: rhs.angle.radians) &&
        lhs.axis.x.isAlmostEqual(to: rhs.axis.x) &&
        lhs.axis.y.isAlmostEqual(to: rhs.axis.y) &&
        lhs.axis.z.isAlmostEqual(to: rhs.axis.z) &&
        lhs.anchor.x.isAlmostEqual(to: rhs.anchor.x) &&
        lhs.anchor.y.isAlmostEqual(to: rhs.anchor.y) &&
        lhs.anchor.z.isAlmostEqual(to: rhs.anchor.z) &&
        lhs.perspective.isAlmostEqual(to: rhs.perspective) &&
        (lhs.flipWidth.isNaN && rhs.flipWidth.isNaN || lhs.flipWidth.isAlmostEqual(to: rhs.flipWidth))
    }

    package func isAlmostEqual(to other: _Rotation3DEffect.Data) -> Bool {
        self ~= other
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
