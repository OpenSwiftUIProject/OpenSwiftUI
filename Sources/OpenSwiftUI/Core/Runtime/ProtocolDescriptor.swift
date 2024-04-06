//
//  ProtocolDescriptor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import COpenSwiftUI
internal import OpenGraphShims

// MARK: - ProtocolDescriptor

protocol ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer { get }
}

// MARK: - TupleDescriptor

protocol TupleDescriptor: ProtocolDescriptor {
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<Self>] { get set }
}

extension TupleDescriptor {
    static func tupleDescription(_ type: OGTupleType) -> TupleTypeDescription<Self> {
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

struct TupleTypeDescription<PD: ProtocolDescriptor> {
    let contentTypes: [(Int, TypeConformance<PD>)]
    
    init(_ tupleType: OGTupleType) {
        contentTypes = tupleType.indices.compactMap { index in
            let type = tupleType.type(at: index)
            guard let comformance = TypeConformance<PD>(type) else {
                print("Ignoring invalid type, type \(type) at index \(index)")
                return nil
            }
            return (index, comformance)
        }
    }
}

// MARK: - ViewDescriptor

struct ViewDescriptor: TupleDescriptor {
    static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_viewProtocolDescriptor()
    }
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<ViewDescriptor>] = [:]
}
