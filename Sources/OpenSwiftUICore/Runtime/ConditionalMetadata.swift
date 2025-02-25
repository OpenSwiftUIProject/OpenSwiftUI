//
//  ConditionalMetadata.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 2319071E64CA2FA820BFB26F46C6ECC6

import OpenGraphShims

// MARK: - ConditionalProtocolDescriptor

package protocol ConditionalProtocolDescriptor: ProtocolDescriptor {
    static func fetchConditionalType(key: ObjectIdentifier) -> ConditionalTypeDescriptor<Self>?

    static func insertConditionalType(key: ObjectIdentifier, value: ConditionalTypeDescriptor<Self>)
}

// MARK: - ConditionalMetadata

package struct ConditionalMetadata<P> where P: ConditionalProtocolDescriptor {
    var desc: ConditionalTypeDescriptor<P>
    var ids: [UniqueID]

    init(_ desc: ConditionalTypeDescriptor<P>) {
        self.desc = desc
        self.ids = (0..<desc.count).map { _ in UniqueID() }
    }

    func childInfo<V>(ptr: UnsafePointer<V>, emptyType: any Any.Type) -> (any Any.Type, UniqueID?) {
        var targetType: (any Any.Type)?
        var targetIndex = 0
        desc.project(at: UnsafeRawPointer(ptr), baseIndex: 0) { index, conformance, ptr in
            targetIndex = index
            targetType = conformance?.type
        }
        return (targetType ?? emptyType, ids[targetIndex])
    }
}

// MARK: - ConditionalTypeDescriptor

package struct ConditionalTypeDescriptor<P> where P: ConditionalProtocolDescriptor {
    private enum Storage {
        case atom(TypeConformance<P>)
        indirect case optional(any Any.Type, ConditionalTypeDescriptor<P>)
        indirect case either(any Any.Type, f: ConditionalTypeDescriptor<P>, t: ConditionalTypeDescriptor<P>)
    }

    private var storage: Storage

    var count: Int

    fileprivate static func descriptor(type: any Any.Type) -> Self {
        if let descriptor = P.fetchConditionalType(key: ObjectIdentifier(type)) {
            return descriptor
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
        #if OPENSWIFTUI_SUPPORT_2024_API
        switch storage {
        case let .atom(conformance):
            body(baseIndex, conformance, base)
        case let .optional(type, descriptor):
            let metadata = Metadata(type)
            let tag = Int(metadata.enumTag(base))
            if tag == 1 {
                body(baseIndex, nil, nil)
            } else {
                metadata.projectEnum(
                    at: base,
                    tag: tag
                ) { ptr in
                    descriptor.project(at: ptr, baseIndex: baseIndex &+ 1, body)
                }
            }
        case let .either(type, falseDescriptor, trueDescriptor):
            let metadata = Metadata(type)
            let tag = Int(metadata.enumTag(base))
            metadata.projectEnum(
                at: base,
                tag: tag
            ) { ptr in
                if tag == 1 {
                    falseDescriptor.project(at: ptr, baseIndex: baseIndex, body)
                } else {
                    trueDescriptor.project(at: ptr, baseIndex: baseIndex + falseDescriptor.count, body)
                }
            }
        }
        #endif
    }
}

private let optionalTypeDescriptor: UnsafeRawPointer = Metadata(Void?.self).nominalDescriptor!
private let conditionalTypeDescriptor: UnsafeRawPointer = Metadata(_ConditionalContent<Void, Void>.self).nominalDescriptor!

extension Optional {
    package static func makeConditionalMetadata<P>(_ protocolDescriptor: P.Type) -> ConditionalMetadata<P> where P: ConditionalProtocolDescriptor {
        let descriptor = P.fetchConditionalType(key: ObjectIdentifier(Self.self)) ?? {
            let descriptor = ConditionalTypeDescriptor<P>.descriptor(type: Wrapped.self)
            P.insertConditionalType(key: ObjectIdentifier(Self.self), value: descriptor)
            return descriptor
        }()
        return ConditionalMetadata(descriptor)
    }
}
