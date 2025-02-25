//
//  TupleTypeDescription.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

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

package struct TupleTypeDescription<P> where P: ProtocolDescriptor {
    package let contentTypes: [(Int, TypeConformance<P>)]

    package init(_ type: TupleType) {
        var contentTypes: [(Int, TypeConformance<P>)] = []
        for index in type.indices {
            let type = type.type(at: index)
            guard let comformance = P.conformance(of: type) else {
                let message = "Ignoring invalid type at index \(index), type \(type)"
                #if OPENSWIFTUI_SWIFT_LOG
                Log.unlocatedIssuesLog.error("\(message)")
                #else
                Log.unlocatedIssuesLog.fault("\(message, privacy: .public)")
                #endif
                continue
            }
            contentTypes.append((index, comformance))
        }
        self.contentTypes = contentTypes
    }
}
