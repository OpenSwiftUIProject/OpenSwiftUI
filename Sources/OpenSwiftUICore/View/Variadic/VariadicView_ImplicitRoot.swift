//
//  VariadicView_ImplicitRoot.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

package protocol _VariadicView_AnyImplicitRoot {
    static func visitType<V>(visitor: inout V) where V: _VariadicView_ImplicitRootVisitor
}

package protocol _VariadicView_ImplicitRootVisitor {
    mutating func visit<R>(type: R.Type) where R: _VariadicView_ImplicitRoot
}

package protocol _VariadicView_ImplicitRoot: _VariadicView_AnyImplicitRoot, _VariadicView_ViewRoot {
    static var implicitRoot: Self { get }
}

extension _VariadicView_ImplicitRoot {
    package static func visitType<V>(visitor: inout V) where V: _VariadicView_ImplicitRootVisitor {
        visitor.visit(type: Self.self)
    }
}
