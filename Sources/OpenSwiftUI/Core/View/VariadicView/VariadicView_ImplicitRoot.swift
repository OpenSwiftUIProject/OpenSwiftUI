//
//  VariadicView_ImplicitRoot.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol _VariadicView_AnyImplicitRoot {
    static func visitType<Visitor: _VariadicView_ImplicitRootVisitor>(visitor: inout Visitor)
}

protocol _VariadicView_ImplicitRootVisitor {
    mutating func visit<Root: _VariadicView_ImplicitRoot>(type: Root.Type)
}

protocol _VariadicView_ImplicitRoot: _VariadicView_AnyImplicitRoot, _VariadicView_ViewRoot {
    static var implicitRoot: Self { get }
}

extension _VariadicView_ImplicitRoot {
    func visitType<Visitor: _VariadicView_ImplicitRootVisitor>(visitor: inout Visitor) {
        visitor.visit(type: Self.self)
    }
}
