//
//  Projection.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - Projection

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public protocol Projection: Hashable {
    associatedtype Base
    associatedtype Projected
    func get(base: Base) -> Projected
    func set(base: inout Base, newValue: Projected)
}

@_spi(ForOpenSwiftUIOnly)
extension Projection {
    package func composed<Tail>(with tail: Tail) -> ComposedProjection<Self, Tail> where Tail: Projection, Projected == Tail.Base {
        ComposedProjection(left: self, right: tail)
    }
}

// MARK: - ComposedProjection

package struct ComposedProjection<Left, Right>: Projection where Left: Projection, Right: Projection, Left.Projected == Right.Base {
    let left: Left

    let right: Right

    package func get(base: Left.Base) -> Right.Projected {
        right.get(base: left.get(base: base))
    }
    
    package func set(base: inout Left.Base, newValue: Right.Projected) {
        var value = left.get(base: base)
        right.set(base: &value, newValue: newValue)
        left.set(base: &base, newValue: value)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
extension WritableKeyPath: Projection {
    public func get(base: Root) -> Value { base[keyPath: self] }

    public func set(base: inout Root, newValue: Value) { base[keyPath: self] = newValue }
}
