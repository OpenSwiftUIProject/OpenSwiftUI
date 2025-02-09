//
//  DynamicView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 3FB6ABB0477B815AB3C89DD5EDC9F0F0 (SwiftUICore)

package import OpenGraphShims

package protocol DynamicView {
    static var canTransition: Bool { get }
    static var traitKeysDependOnView: Bool { get }
    associatedtype Metadata
    associatedtype ID : Hashable
    static func makeID() -> ID
    func childInfo(metadata: Metadata) -> (any Any.Type, ID?)
    func makeChildView(metadata: Metadata, view: Attribute<Self>, inputs: _ViewInputs) -> _ViewOutputs
    func makeChildViewList(metadata: Metadata, view: Attribute<Self>, inputs: _ViewListInputs) -> _ViewListOutputs
}

extension DynamicView {
    package static var traitKeysDependOnView: Bool { true }
}

extension DynamicView where ID == UniqueID {
    package static func makeID() -> UniqueID { UniqueID() }
}

extension DynamicView {
    package static func makeDynamicView(metadata: Metadata, view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        preconditionFailure("TODO")
    }

    package static func makeDynamicViewList(metadata: Metadata, view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }
}
