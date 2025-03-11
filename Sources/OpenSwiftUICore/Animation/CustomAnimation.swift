//
//  CustomAnimation.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

public import Foundation

public protocol CustomAnimation: Hashable {
    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic
    func velocity<V>(value: V, time: TimeInterval, context: AnimationContext<V>) -> V? where V : VectorArithmetic
    func shouldMerge<V>(previous: Animation, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic
}
package protocol InternalCustomAnimation: CustomAnimation {
    var function: Animation.Function { get }
}

extension CustomAnimation {
//    public func velocity<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic
//    public func shouldMerge<V>(previous: Animation, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic
}
