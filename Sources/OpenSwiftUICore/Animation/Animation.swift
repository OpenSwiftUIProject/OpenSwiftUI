//
//  Animation.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 8F497279EF59809EEBBA826C6935F7DC (SwiftUI)
//  ID: 4FD7A1D5440B1394D12A74675615ED20 (SwiftUICore)

package import Foundation

@frozen
public struct Animation : Equatable, Sendable {
    public init<A>(_ base: A) where A: CustomAnimation {
        preconditionFailure("TODO")
    }
    
    package init<A>(_ base: A) where A : InternalCustomAnimation {
        preconditionFailure("TODO")
    }

    var box: AnimationBoxBase
    
    package var codableValue: any CustomAnimation {
        get {
            preconditionFailure("TODO")
        }
    }
    
    public static func == (lhs: Animation, rhs: Animation) -> Bool {
        preconditionFailure("TODO")
    }

    package func `as`<A>(_ type: A.Type) -> A? where A : CustomAnimation {
        preconditionFailure("TODO")
    }

    package enum Function {
        case linear(duration: Double)
        case circularEaseIn(duration: Double)
        case circularEaseOut(duration: Double)
        case circularEaseInOut(duration: Double)
        case bezier(duration: Double, cp1: CGPoint, cp2: CGPoint)
        case spring(duration: Double, mass: Double, stiffness: Double, damping: Double, initialVelocity: Double = 0)
        case customFunction((Double, inout AnimationContext<Double>) -> Double?)
        indirect case delay(Double, Animation.Function)
        indirect case speed(Double, Animation.Function)
        indirect case `repeat`(count: Double, autoreverses: Bool, Animation.Function)
        package static func custom<T>(_ anim: T) -> Animation.Function where T: CustomAnimation {
            preconditionFailure("TODO")
        }
    }

    package var function: Animation.Function {
        get {
            preconditionFailure("TODO")
        }
    }
}
// extension Animation.Function {
//   #if compiler(>=5.3) && $NoncopyableGenerics
//   package var bezierForm: (duration: Double, cp1: CGPoint, cp2: CGPoint)? {
//     get
//   }
//   #else
//   package var bezierForm: (duration: Double, cp1: CGPoint, cp2: CGPoint)? {
//     get
//   }
//   #endif
// }

// extension Animation : Hashable {
//   #if compiler(>=5.3) && $NoncopyableGenerics
//   @_specialize(exported: false, kind: partial, where V == Double)
//   @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
//   public func animate<V>(value: V, time: Foundation.TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic
//   #else
//   @_specialize(exported: false, kind: partial, where V == Double)
//   @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
//   public func animate<V>(value: V, time: Foundation.TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic
//   #endif
//   #if compiler(>=5.3) && $NoncopyableGenerics
//   public func velocity<V>(value: V, time: Foundation.TimeInterval, context: AnimationContext<V>) -> V? where V : VectorArithmetic
//   #else
//   public func velocity<V>(value: V, time: Foundation.TimeInterval, context: AnimationContext<V>) -> V? where V : VectorArithmetic
//   #endif
//   public func shouldMerge<V>(previous: Animation, value: V, time: Foundation.TimeInterval, context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic
//   public var base: any CustomAnimation {
//     get
//   }
//   public func hash(into hasher: inout Hasher)
//   public var hashValue: Int {
//     get
//   }
// }

// extension Animation : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
//   public var description: String {
//     get
//   }
//   public var debugDescription: String {
//     get
//   }
//   public var customMirror: Mirror {
//     get
//   }
// }

 @usableFromInline
class AnimationBoxBase: @unchecked Sendable {
//   @objc @usableFromInline
//   deinit
 }
