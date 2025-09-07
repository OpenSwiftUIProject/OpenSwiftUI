//
//  AnyTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 142ABD4E569D763299C4081019352BCD (SwiftUICore)

/// A type-erased transition.
///
/// - See Also: `Transition`
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct AnyTransition {
    fileprivate let box: AnyTransitionBox

    /// Create an instance that type-erases `transition`.
    @available(OpenSwiftUI_v5_0, *)
    public init<T>(_ transition: T) where T: Transition {
        self.box = TransitionBox(transition)
    }
    
    package func visitBase<V>(applying v: inout V) where V: TransitionVisitor {
        box.visitBase(applying: &v)
    }
    
    package func visitType<V>(applying v: inout V) where V: TransitionTypeVisitor {
        box.visitType(applying: &v)
    }
    
    package func base<T>(as _: T.Type) -> T? where T: Transition {
        guard let box = box as? TransitionBox<T> else {
            return nil
        }
        return box.base
    }
    
    package var isIdentity: Bool {
        box.isIdentity
    }
    
    package func adjustedForAccessibility(prefersCrossFade: Bool) -> AnyTransition {
        guard box.hasMotion, prefersCrossFade else {
            return self
        }
        return .opacity
    }
}

@available(*, unavailable)
extension AnyTransition: Sendable {}

package protocol TransitionVisitor {
    mutating func visit<T>(_ transition: T) where T: Transition
}

package protocol TransitionTypeVisitor {
    mutating func visit<T>(_ type: T.Type) where T: Transition
}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
class AnyTransitionBox {
    init() {}

    func visitBase<V>(applying v: inout V) where V: TransitionVisitor {
        _openSwiftUIBaseClassAbstractMethod()
    }
    
    func visitType<V>(applying v: inout V) where V: TransitionTypeVisitor {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var isIdentity: Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var hasMotion: Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension AnyTransitionBox: Sendable {}

@available(OpenSwiftUI_v5_0, *)
private final class TransitionBox<T>: AnyTransitionBox where T: Transition {
    let base: T

    init(_ base: T) {
        self.base = base
    }

    override func visitBase<V>(applying v: inout V) where V: TransitionVisitor {
        v.visit(base)
    }
    
    override func visitType<V>(applying v: inout V) where V: TransitionTypeVisitor {
        v.visit(T.self)
    }
    
    override var isIdentity: Bool {
        T.Body.self == PlaceholderContentView<T>.self
    }

    override var hasMotion: Bool {
        T.properties.hasMotion
    }
}
