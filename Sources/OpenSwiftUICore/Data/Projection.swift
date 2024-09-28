//
//  Projection.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
public protocol Projection: Hashable {
    associatedtype Base
    associatedtype Projected
    func get(base: Base) -> Projected
    func set(base: inout Base, newValue: Projected)
}

@_spi(ForSwiftUIOnly)
extension Projection {
    package func composed<Tail>(with tail: Tail) -> ComposedProjection<Self, Tail> where Tail: Projection, Projected == Tail.Base {
        ComposedProjection(left: self, right: tail)
    }
}

package struct ComposedProjection<Left, Right>: Projection where Left: Projection, Right: Projection, Left.Projected == Right.Base {
    let left: Left
    let right: Right
    
    package typealias Base = Left.Base
    package typealias Projected = Right.Projected
    
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
extension WritableKeyPath: Projection {
    public typealias Base = Root
    public typealias Projected = Value
    public func get(base: Root) -> Value { base[keyPath: self] }
    public func set(base: inout Root, newValue: Value) { base[keyPath: self] = newValue }
}
