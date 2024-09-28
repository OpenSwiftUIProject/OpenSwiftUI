//
//  GraphMutation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete
//  ID: F9F204BD2F8DB167A76F17F3FB1B3335

internal import OpenGraphShims

package protocol GraphMutation {
    typealias Style = _GraphMutation_Style
    func apply()
    mutating func combine<T>(with other: T) -> Bool where T: GraphMutation
}

package enum _GraphMutation_Style: Hashable {
    case immediate
    case deferred
}

/*private*/ package struct EmptyGraphMutation: GraphMutation {
    package init() {}
    package func apply() {}
    package func combine<T>(with other: T) -> Bool where T: GraphMutation {
        T.self == EmptyGraphMutation.self
    }
}

package struct CustomGraphMutation: GraphMutation {
    let body: () -> Void
    
    package init(_ body: @escaping () -> Void) {
        self.body = body
    }
    
    package func apply() {
        body()
    }
    
    package func combine<T>(with other: T) -> Bool where T : GraphMutation {
        false
    }
}

// FIXME: #39
#if canImport(Darwin)
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
#endif
