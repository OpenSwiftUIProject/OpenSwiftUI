//
//  ConditionalMetadata.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 2319071E64CA2FA820BFB26F46C6ECC6

import OpenGraphShims

public /*package*/ protocol ConditionalProtocolDescriptor: ProtocolDescriptor {
    static func fetchConditionalType(key: ObjectIdentifier) -> ConditionalTypeDescriptor<Self>?

    static func insertConditionalType(key: ObjectIdentifier, value: ConditionalTypeDescriptor<Self>)
}

package struct ConditionalMetadata<P> where P: ConditionalProtocolDescriptor {
    var desc: ConditionalTypeDescriptor<P>
    var ids: [UniqueID]

    init(_ desc: ConditionalTypeDescriptor<P>) {
        self.desc = desc
        self.ids = (0..<desc.count).map { _ in UniqueID() }
    }

    func childInfo<V>(ptr: UnsafePointer<V>, emptyType: any Any.Type) -> (any Any.Type, UniqueID?) {

        desc.project(at: UnsafeRawPointer(ptr), baseIndex: 0) { index, conformance, ptr in

        }
        fatalError("TODO")
    }
}

// WIP
public /*package*/ struct ConditionalTypeDescriptor<P> where P: ConditionalProtocolDescriptor {
    fileprivate enum Storage {
        case atom(TypeConformance<P>)
        indirect case optional(any Any.Type, ConditionalTypeDescriptor<P>)
        indirect case either(any Any.Type, f: ConditionalTypeDescriptor<P>, t: ConditionalTypeDescriptor<P>)
    }

    fileprivate var storage: Storage
    var count: Int

    public /*fileprivate*/ static func descriptor(type: any Any.Type) -> Self {
        let fetchResult = P.fetchConditionalType(key: ObjectIdentifier(type))
        if let fetchResult {
            return fetchResult
        } else {
            let descriptor = ConditionalTypeDescriptor(type)
            P.insertConditionalType(key: ObjectIdentifier(type), value: descriptor)
            return descriptor
        }
    }

    init(_ type: any Any.Type) {
        let metadata = Metadata(type)
        let descriptor = metadata.nominalDescriptor
        if descriptor == conditionalTypeDescriptor {
            let falseDescriptor = Self.descriptor(type: metadata.genericType(at: 1))
            let trueDescriptor = Self.descriptor(type: metadata.genericType(at: 0))
            storage = .either(type, f: falseDescriptor, t: trueDescriptor)
            count = falseDescriptor.count + trueDescriptor.count
        } else if descriptor == optionalTypeDescriptor {
            let wrappedDescriptor = Self.descriptor(type: metadata.genericType(at: 0))
            storage = .optional(type, wrappedDescriptor)
            count = wrappedDescriptor.count + 1
        } else {
            storage = .atom(P.conformance(of: type)!)
            count = 1
        }
    }

    fileprivate func project(at base: UnsafeRawPointer, baseIndex: Int, _ body: (Int, TypeConformance<P>?, UnsafeRawPointer?) -> ()) {
        preconditionFailure("TODO")
    }
}

private let optionalTypeDescriptor: UnsafeRawPointer = Metadata(Void?.self).nominalDescriptor!
private let conditionalTypeDescriptor: UnsafeRawPointer = Metadata(_ConditionalContent<Void, Void>.self).nominalDescriptor!

//extension Optional {
//    package static func makeConditionalMetadata<P>(_ protocolDescriptor: P.Type) -> ConditionalMetadata<P> where P: ConditionalProtocolDescriptor {
//        if let type = P.fetchConditionalType(key: ObjectIdentifier(P.self)) {
//
//        } else {
//
//        }
//        return ConditionalMetadata(<#T##desc: ConditionalTypeDescriptor<ConditionalProtocolDescriptor>##ConditionalTypeDescriptor<ConditionalProtocolDescriptor>#>)
//    }
//}
