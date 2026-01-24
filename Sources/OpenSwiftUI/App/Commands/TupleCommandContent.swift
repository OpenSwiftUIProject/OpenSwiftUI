//
//  TupleCommandContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9E9409CEF3AB3560A6C5DB8F4F5C04B8 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - TupleCommandContent

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@usableFromInline
@MainActor
@preconcurrency
struct TupleCommandContent<T>: PrimitiveCommands {
    @usableFromInline
    var value: T

    @usableFromInline
    init(_ value: T) {
        self.value = value
    }

    @usableFromInline
    var body: Never {
        _openSwiftUIUnreachableCode()
    }

    @usableFromInline
    nonisolated static func _makeCommands(
        content: _GraphValue<TupleCommandContent<T>>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        let tupleType = TupleType(T.self)
        let description = CommandsDescriptor.tupleDescription(tupleType)
        var makeList = MakeList(
            content: content,
            inputs: inputs,
            offset: 0,
            outputs: []
        )
        for (index, conformance) in description.contentTypes {
            makeList.offset = TupleType(T.self).elementOffset(at: index)
            conformance.visitType(visitor: &makeList)
        }
        var visitor = MultiPreferenceCombinerVisitor(
            outputs: makeList.outputs.map { $0.preferences },
            result: .init()
        )
        for key in inputs.preferences.keys {
            key.visitKey(&visitor)
        }
        return .init(preferences: visitor.result)
    }

    @usableFromInline
    func _resolve(into resolved: inout _ResolvedCommands) {
        let tupleType = TupleType(T.self)
        let description = CommandsDescriptor.tupleDescription(tupleType)
        var visitor = Visitor(content: value, resolved: resolved, offset: 0)
        for (index, conformance) in description.contentTypes {
            visitor.offset = TupleType(T.self).elementOffset(at: index)
            conformance.visitType(visitor: &visitor)
        }
        resolved = visitor.resolved
    }

    private struct Visitor: CommandsTypeVisitor {
        var content: T
        var resolved: _ResolvedCommands
        var offset: Int

        mutating func visit<Content>(type: Content.Type) where Content: Commands {
            withUnsafeBytes(of: &content) { buffer in
                buffer
                    .load(fromByteOffset: offset, as: Content.self)
                    ._resolve(into: &resolved)
            }
        }
    }

    private struct MakeList: CommandsTypeVisitor {
        var content: _GraphValue<TupleCommandContent>
        var inputs: _CommandsInputs
        var offset: Int
        var outputs: [_CommandsOutputs]

        init(
            content: _GraphValue<TupleCommandContent>,
            inputs: _CommandsInputs,
            offset: Int,
            outputs: [_CommandsOutputs]
        ) {
            self.content = content
            self.inputs = inputs
            self.offset = offset
            self.outputs = outputs
        }

        mutating func visit<Content>(type: Content.Type) where Content: Commands {
            let output = Content._makeCommands(
                content: .init(content.value.unsafeOffset(at: offset, as: Content.self)),
                inputs: inputs
            )
            outputs.append(output)
        }
    }
}

@available(*, unavailable)
extension TupleCommandContent: Sendable {}

// MARK: - Group + Commands

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Group: PrimitiveCommands, Commands where Content: Commands {

    @available(OpenSwiftUI_v3_0, *)
    nonisolated public static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        Content._makeCommands(
            content: content[offset: { .of(&$0.content) }],
            inputs: inputs
        )
    }
  
    @inlinable
    nonisolated public init(@CommandsBuilder content: () -> Content) {
        self = Self._make(content: content())
    }
    
    public func _resolve(into resolved: inout _ResolvedCommands) {
        content._resolve(into: &resolved)
    }
}

// MARK: - CommandBuilder + TupleCommandContent

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension CommandsBuilder {
    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> some Commands where C0: Commands, C1: Commands {
        TupleCommandContent((c0, c1))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> some Commands where C0: Commands, C1: Commands, C2: Commands {
        TupleCommandContent((c0, c1, c2))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands {
        TupleCommandContent((c0, c1, c2, c3))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands {
        TupleCommandContent((c0, c1, c2, c3, c4))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands {
        TupleCommandContent((c0, c1, c2, c3, c4, c5))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands {
        TupleCommandContent((c0, c1, c2, c3, c4, c5, c6))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands, C7: Commands {
        TupleCommandContent((c0, c1, c2, c3, c4, c5, c6, c7))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands, C7: Commands, C8: Commands {
        TupleCommandContent((c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }

    @_alwaysEmitIntoClient
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> some Commands where C0: Commands, C1: Commands, C2: Commands, C3: Commands, C4: Commands, C5: Commands, C6: Commands, C7: Commands, C8: Commands, C9: Commands {
        TupleCommandContent((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }
}
