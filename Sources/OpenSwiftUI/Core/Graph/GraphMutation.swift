//
//  GraphMutation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import OpenGraphShims

protocol GraphMutation {
    func apply()
    mutating func combine<Mutation: GraphMutation>(with: Mutation) -> Bool
}

struct EmptyGraphMutation: GraphMutation {
    func apply() {}
    func combine<Mutation>(with _: Mutation) -> Bool where Mutation: GraphMutation {
        Mutation.self == EmptyGraphMutation.self
    }
}

struct InvalidatingGraphMutation: GraphMutation {
    let attribute: OGWeakAttribute
    
    func apply() {
        attribute.attribute?.invalidateValue()
    }
    
    func combine(with mutation: some GraphMutation) -> Bool {
        guard let mutation = mutation as? InvalidatingGraphMutation else {
            return false
        }
        return mutation.attribute == attribute
    }
}

struct CustomGraphMutation: GraphMutation {
    let body: () -> Void
    
    func apply() {
        body()
    }
    
    func combine(with _: some GraphMutation) -> Bool {
        false
    }
}
