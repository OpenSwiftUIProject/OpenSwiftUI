//
//  ProjectionTransformHelper.swift
//  OpenSwiftUITestsSupport

#if OPENSWIFTUI
public import OpenSwiftUICore

extension ProjectionTransform: Hashable {
    public func hash(into hasher: inout Hasher) {
        m11.hash(into: &hasher)
        m12.hash(into: &hasher)
        m13.hash(into: &hasher)
        m21.hash(into: &hasher)
        m22.hash(into: &hasher)
        m23.hash(into: &hasher)
        m31.hash(into: &hasher)
        m32.hash(into: &hasher)
        m33.hash(into: &hasher)
    }

    package func isAlmostEqual(to other: ProjectionTransform) -> Bool {
        m11.isAlmostEqual(to: other.m11) &&
        m12.isAlmostEqual(to: other.m12) &&
        m13.isAlmostEqual(to: other.m13) &&
        m21.isAlmostEqual(to: other.m21) &&
        m22.isAlmostEqual(to: other.m22) &&
        m23.isAlmostEqual(to: other.m23) &&
        m31.isAlmostEqual(to: other.m31) &&
        m32.isAlmostEqual(to: other.m32) &&
        m33.isAlmostEqual(to: other.m33)
    }
}
#endif
