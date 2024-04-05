//
//  ProtocolDescriptor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import COpenSwiftUI

// MARK: - ProtocolDescriptor

protocol ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer { get }
}

// MARK: - TupleDescriptor

protocol TupleDescriptor: ProtocolDescriptor {
    static var typeCache: [ObjectIdentifier: TupleTypeDescription<Self>] { get set }
}

extension TupleDescriptor where Self == ViewDescriptor {
//    static func tupleDescription(__C.AGTupleType) -> SwiftUI.TupleTypeDescription<A>
}

// MARK: - TupleTypeDescription

struct TupleTypeDescription<PD: ProtocolDescriptor> {
    let contentTypes: [(Int, TypeConformance<PD>)]
}

// MARK: - ViewDescriptor

struct ViewDescriptor: TupleDescriptor {
    static var descriptor: UnsafeRawPointer {
        _viewProtocolDescriptor()
    }
    
    // FIXME
    static var typeCache: [ObjectIdentifier : TupleTypeDescription<ViewDescriptor>] = [:]
}
