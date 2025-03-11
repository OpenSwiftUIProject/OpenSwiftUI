//
//  DefaultAnimation.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2025/3/11.
//


extension Animation {
    public static let `default`: Animation = {
        preconditionFailure("TODO")
    }()
//  package static let defaultCustomAnimation: SwiftUICore.DefaultAnimation
}
//package struct DefaultAnimation : SwiftUICore.InternalCustomAnimation {
//  package init()
//  #if compiler(>=5.3) && $NoncopyableGenerics
//  @_specialize(exported: false, kind: partial, where V == Swift.Double)
//  @_specialize(exported: false, kind: partial, where V == SwiftUICore.AnimatablePair<SwiftUICore.AnimatablePair<CoreFoundation.CGFloat, CoreFoundation.CGFloat>, SwiftUICore.AnimatablePair<CoreFoundation.CGFloat, CoreFoundation.CGFloat>>)
//  package func animate<V>(value: V, time: Foundation.TimeInterval, context: inout SwiftUICore.AnimationContext<V>) -> V? where V : SwiftUICore.VectorArithmetic
//  #else
//  @_specialize(exported: false, kind: partial, where V == Swift.Double)
//  @_specialize(exported: false, kind: partial, where V == SwiftUICore.AnimatablePair<SwiftUICore.AnimatablePair<CoreFoundation.CGFloat, CoreFoundation.CGFloat>, SwiftUICore.AnimatablePair<CoreFoundation.CGFloat, CoreFoundation.CGFloat>>)
//  package func animate<V>(value: V, time: Foundation.TimeInterval, context: inout SwiftUICore.AnimationContext<V>) -> V? where V : SwiftUICore.VectorArithmetic
//  #endif
//  #if compiler(>=5.3) && $NoncopyableGenerics
//  package func velocity<V>(value: V, time: Foundation.TimeInterval, context: SwiftUICore.AnimationContext<V>) -> V? where V : SwiftUICore.VectorArithmetic
//  #else
//  package func velocity<V>(value: V, time: Foundation.TimeInterval, context: SwiftUICore.AnimationContext<V>) -> V? where V : SwiftUICore.VectorArithmetic
//  #endif
//  package func shouldMerge<V>(previous: SwiftUICore.Animation, value: V, time: Foundation.TimeInterval, context: inout SwiftUICore.AnimationContext<V>) -> Swift.Bool where V : SwiftUICore.VectorArithmetic
//  package var function: SwiftUICore.Animation.Function {
//    get
//  }
//  package func hash(into hasher: inout Swift.Hasher)
//  package static func == (a: SwiftUICore.DefaultAnimation, b: SwiftUICore.DefaultAnimation) -> Swift.Bool
//  package var hashValue: Swift.Int {
//    get
//  }
//}
//extension SwiftUICore.DefaultAnimation : SwiftUICore.ProtobufMessage {
//  package func encode(to encoder: inout SwiftUICore.ProtobufEncoder) throws
//  package init(from decoder: inout SwiftUICore.ProtobufDecoder) throws
//}
