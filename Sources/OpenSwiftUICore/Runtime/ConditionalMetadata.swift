//
//  ConditionalMetadata.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 2319071E64CA2FA820BFB26F46C6ECC6 (SwiftUICore)

import OpenAttributeGraphShims

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
    fileprivate enum Storage {
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

    fileprivate init(storage: Storage, count: Int) {
        self.storage = storage
        self.count = count
    }

    init(_ type: any Any.Type) {
        let storage: Storage
        let count: Int

        let metadata = Metadata(type)
        let descriptor = metadata.nominalDescriptor

        if descriptor == conditionalTypeDescriptor {
            let falseDescriptor = Self.descriptor(type: metadata.genericType(at: 1))
            let trueDescriptor = Self.descriptor(type: metadata.genericType(at: 0))
            // FIXME: How to get _ConditionalContent.Storage type more easily
            typealias Accessor =  @convention(c) (UInt, Metadata, Metadata) -> Metadata
            let nominal = Metadata(_ConditionalContent<Void, Void>.Storage.self).nominalDescriptor!
            let accessorRelativePointer = nominal.advanced(by: 12)
            let accessor = unsafeBitCast(
                accessorRelativePointer.advanced(by:Int(accessorRelativePointer.assumingMemoryBound(to: Int32.self).pointee)),
                to: Accessor.self
            )
            let type = accessor(0, Metadata(metadata.genericType(at: 0)), Metadata(metadata.genericType(at: 1)))
            storage = .either(type.type, f: falseDescriptor, t: trueDescriptor)
            count = falseDescriptor.count + trueDescriptor.count
        } else if descriptor == optionalTypeDescriptor {
            let wrappedDescriptor = Self.descriptor(type: metadata.genericType(at: 0))
            storage = .optional(type, wrappedDescriptor)
            count = wrappedDescriptor.count + 1
        } else {
            storage = .atom(P.conformance(of: type)!)
            count = 1
        }

        self.init(storage: storage, count: count)
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

// MARK: - Optional + ConditionalMetadata

extension Optional {
    package static func makeConditionalMetadata<P>(_ protocolDescriptor: P.Type) -> ConditionalMetadata<P> where P: ConditionalProtocolDescriptor {
        let descriptor: ConditionalTypeDescriptor<P>
        if let result = P.fetchConditionalType(key: ObjectIdentifier(Self.self)) {
            descriptor = result
        } else {
            descriptor = {
                let wrappedDescriptor = ConditionalTypeDescriptor<P>.descriptor(type: Wrapped.self)
                return ConditionalTypeDescriptor(
                    storage: .optional(Self.self, wrappedDescriptor),
                    count: wrappedDescriptor.count + 1
                )
            }()
            P.insertConditionalType(key: ObjectIdentifier(Self.self), value: descriptor)
        }
        return ConditionalMetadata(descriptor)
    }
}

// MARK: - ConditionalContent + ConditionalMetadata

extension _ConditionalContent {
    static func makeConditionalMetadata<P>(_ protocolDescriptor: P.Type) -> ConditionalMetadata<P> where P: ConditionalProtocolDescriptor {
        let descriptor: ConditionalTypeDescriptor<P>
        if let result = P.fetchConditionalType(key: ObjectIdentifier(Self.self)) {
            descriptor = result
        } else {
            descriptor = {
                let falseDescriptor = ConditionalTypeDescriptor<P>.descriptor(type: FalseContent.self)
                let trueDescriptor = ConditionalTypeDescriptor<P>.descriptor(type: TrueContent.self)
                return ConditionalTypeDescriptor(
                    storage: .either(Storage.self, f: falseDescriptor, t: trueDescriptor),
                    count: falseDescriptor.count + trueDescriptor.count
                )

            }()
            P.insertConditionalType(key: ObjectIdentifier(Self.self), value: descriptor)
        }
        return ConditionalMetadata(descriptor)
    }
}

// MARK: ConditionalMetadata + ViewDescriptor

extension ConditionalMetadata where P == ViewDescriptor {
    func makeView<V>(ptr: UnsafePointer<V>, view: Attribute<V>, inputs: _ViewInputs) -> _ViewOutputs {
        var visitor = MakeView(desc: desc, view: view, inputs: inputs)
        desc.project(at: ptr, baseIndex: 0) { index, conformance, ptr in
            guard let conformance, let ptr else { return }
            visitor.index = index
            visitor.ptr = ptr
            conformance.visitType(visitor: &visitor)
        }
        return visitor.outputs ?? .init()
    }

    func makeViewList<V>(ptr: UnsafePointer<V>, view: Attribute<V>, inputs: _ViewListInputs) -> _ViewListOutputs {
        var visitor = MakeList(desc: desc, view: view, inputs: inputs)
        desc.project(at: ptr, baseIndex: 0) { index, conformance, ptr in
            guard let conformance, let ptr else { return }
            visitor.index = index
            visitor.ptr = ptr
            conformance.visitType(visitor: &visitor)
        }
        return visitor.outputs ?? .emptyViewList(inputs: inputs)
    }

    private struct MakeView<Source>: ViewTypeVisitor {
        var desc: ConditionalTypeDescriptor<ViewDescriptor>
        var view: Attribute<Source>
        var index: Int = 0
        var ptr: UnsafeRawPointer?
        var inputs: _ViewInputs
        var outputs: _ViewOutputs?

        mutating func visit<V>(type: V.Type) where V: View {
            inputs.base.pushStableID(index)
            let unwrapConditional = UnwrapConditional<P, Source, V>(source: view, desc: desc, index: index)
            let attribute = Attribute(unwrapConditional)
            attribute.value = ptr!.assumingMemoryBound(to: V.self).pointee
            outputs = V.makeDebuggableView(view: _GraphValue(attribute), inputs: inputs)
        }
    }


    private struct MakeList<Source>: ViewTypeVisitor {
        var desc: ConditionalTypeDescriptor<ViewDescriptor>
        var view: Attribute<Source>
        var index: Int = 0
        var ptr: UnsafeRawPointer?
        var inputs: _ViewListInputs
        var outputs: _ViewListOutputs?

        mutating func visit<V>(type: V.Type) where V: View {
            inputs.base.pushStableID(index)
            let unwrapConditional = UnwrapConditional<P, Source, V>(source: view, desc: desc, index: index)
            let attribute = Attribute(unwrapConditional)
            attribute.value = ptr!.assumingMemoryBound(to: V.self).pointee
            outputs = V.makeDebuggableViewList(view: _GraphValue(attribute), inputs: inputs)
        }
    }
}

// MARK: - UnwrapConditional

private struct UnwrapConditional<P, Source, Value>: StatefulRule, AsyncAttribute where P: ConditionalProtocolDescriptor {
    @Attribute var source: Source
    let desc: ConditionalTypeDescriptor<P>
    let index: Int

    func updateValue() {
        withUnsafePointer(to: source) { ptr in
            desc.project(at: ptr, baseIndex: 0) { index, conformance, ptr in
                guard self.index == index else { return }
                value = ptr!.assumingMemoryBound(to: Value.self).pointee
            }
        }
    }
}

