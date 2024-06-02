//
//  VariadicView_ImplicitRoot.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

/// A type that creates a `Tree`, managing content subtrees passed to a result builder.
///
/// - SeeAlso: _VariadicView.Root.
public protocol _VariadicView_Root {
    static var _viewListOptions: Int { get }
}

extension _VariadicView_Root {
    public static var _viewListOptions: Int {
        0
    }

    public static func _viewListCount(
        inputs _: _ViewListCountInputs,
        body _: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        nil
    }
}
