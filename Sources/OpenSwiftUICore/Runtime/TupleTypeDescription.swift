//
//  TupleTypeDescription.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

import OpenSwiftUI_SPI
package import OpenGraphShims

// MARK: - TupleDescriptor

package protocol TupleDescriptor: ProtocolDescriptor {
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<Self>] { get set }
}

extension TupleDescriptor {
    package static func tupleDescription(_ type: TupleType) -> TupleTypeDescription<Self> {
        let id = ObjectIdentifier(type.type)
        if let cache = typeCache[id] {
            return cache
        } else {
            let description = TupleTypeDescription<Self>(type)
            typeCache[id] = description
            return description
        }
    }
}

// MARK: - TupleTypeDescription

//package struct TupleTypeDescription<P> where P : SwiftUICore.ProtocolDescriptor {
//  package let contentTypes: [(Swift.Int, SwiftUICore.TypeConformance<P>)]
//  package init(_ type: AttributeGraph.TupleType)
//}

package struct TupleTypeDescription<PD: ProtocolDescriptor> {
    let contentTypes: [(Int, TypeConformance<PD>)]

    init(_ tupleType: TupleType) {
//        contentTypes = tupleType.indices.compactMap { index in
//            let type = tupleType.type(at: index)
//            guard let comformance = TypeConformance<PD>(type) else {
//                print("Ignoring invalid type at index \(index), type \(type)")
//                return nil
//            }
//            return (index, comformance)
//        }
        preconditionFailure("TODO")
    }
}

// FIXME

// MARK: - ViewDescriptor

struct ViewDescriptor: TupleDescriptor {
    static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_viewProtocolDescriptor()
    }
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<ViewDescriptor>] = [:]
}
