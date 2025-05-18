//
//  AnyAnimatableData.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 7ABB4C511D8E2C0F1768F58E8C14509E (SwiftUICore)

@frozen
public struct _AnyAnimatableData: VectorArithmetic {
    package var vtable: _AnyAnimatableDataVTable.Type
    package var value: Any
    
    @inline(__always)
    init(vtable: _AnyAnimatableDataVTable.Type, value: Any) {
        self.vtable = vtable
        self.value = value
    }
    
    package init<T>(_ container: T) where T: Animatable {
        vtable = VTable<T>.self
        value = container.animatableData
    }
    
    package func update<T>(_ container: inout T) where T: Animatable {
        guard vtable == VTable<T>.self else { return }
        container.animatableData = value as! T.AnimatableData
    }
    
    public static var zero: _AnyAnimatableData {
        _AnyAnimatableData(vtable: ZeroVTable.self, value: ZeroVTable.zero)
    }
    
    public static func == (lhs: _AnyAnimatableData, rhs: _AnyAnimatableData) -> Bool {
        if lhs.vtable == rhs.vtable {
            lhs.vtable.isEqual(lhs.value, rhs.value)
        } else {
            false
        }
    }
    
    public static func += (lhs: inout _AnyAnimatableData, rhs: _AnyAnimatableData) {
        if lhs.vtable == rhs.vtable {
            lhs.vtable.add(&lhs.value, rhs.value)
        } else if lhs.vtable == ZeroVTable.self {
            lhs = rhs
        }
    }
    
    public static func -= (lhs: inout _AnyAnimatableData, rhs: _AnyAnimatableData) {
        if lhs.vtable == rhs.vtable {
            lhs.vtable.subtract(&lhs.value, rhs.value)
        } else if lhs.vtable == ZeroVTable.self {
            lhs = rhs
            lhs.vtable.negate(&lhs.value)
        }
    }
    
    @_transparent
    public static func + (lhs: _AnyAnimatableData, rhs: _AnyAnimatableData) -> _AnyAnimatableData {
        var ret = lhs
        ret += rhs
        return ret
    }
    
    @_transparent
    public static func - (lhs: _AnyAnimatableData, rhs: _AnyAnimatableData) -> _AnyAnimatableData {
        var ret = lhs
        ret -= rhs
        return ret
    }
    
    public mutating func scale(by rhs: Double) {
        vtable.scale(&value, by: rhs)
    }
    
    public var magnitudeSquared: Double {
        vtable.magnitudeSquared(value)
    }
}

@available(*, unavailable)
extension _AnyAnimatableData: Sendable {}

@usableFromInline
package class _AnyAnimatableDataVTable {
    package class var zero: Any {
        preconditionFailure("")
    }
    
    package class func isEqual(_ lhs: Any, _ rhs: Any) -> Bool { false }
    package class func add(_ lhs: inout Any, _ rhs: Any) {}
    package class func subtract(_ lhs: inout Any, _ rhs: Any) {}
    package class func negate(_ lhs: inout Any) {}
    package class func scale(_ lhs: inout Any, by rhs: Double) {}
    package class func magnitudeSquared(_ lhs: Any) -> Double { .zero }
}

@available(*, unavailable)
extension _AnyAnimatableDataVTable: Sendable {}

private final class VTable<Value>: _AnyAnimatableDataVTable where Value: Animatable {
    override class var zero: Any {
        Value.AnimatableData.zero
    }
    
    override class func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        lhs as! Value.AnimatableData == rhs as! Value.AnimatableData
    }
    
    override class func add(_ lhs: inout Any, _ rhs: Any) {
        var value = lhs as! Value.AnimatableData
        value += rhs as! Value.AnimatableData
        lhs = value
    }
    
    override class func subtract(_ lhs: inout Any, _ rhs: Any) {
        var value = lhs as! Value.AnimatableData
        value -= rhs as! Value.AnimatableData
        lhs = value
    }
    
    override class func negate(_ lhs: inout Any) {
        var value = lhs as! Value.AnimatableData
        value = .zero - value
        lhs = value
    }
    
    override class func scale(_ lhs: inout Any, by rhs: Double) {
        var value = lhs as! Value.AnimatableData
        value.scale(by: rhs)
        lhs = value
    }
    
    override class func magnitudeSquared(_ lhs: Any) -> Double {
        (lhs as! Value.AnimatableData).magnitudeSquared
    }
}

private final class ZeroVTable: _AnyAnimatableDataVTable {
    override class var zero: Any { () }
}
