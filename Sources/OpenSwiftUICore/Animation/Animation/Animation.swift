public import Foundation

@frozen
public struct Animation: Equatable {
//    var box: AnimationBoxBase
    public static func == (lhs: Animation, rhs: Animation) -> Bool {
        // TODO
        true
    }

    public static var `default` = Animation()

    func animate<V>(
        value: V,
        time: Double,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }

    public func shouldMerge<V>(
        previous: Animation,
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> Bool where V: VectorArithmetic {
        _openSwiftUIUnimplementedFailure()
    }
}
