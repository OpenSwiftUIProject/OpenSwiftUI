//
//  LimitedAvailabilityCommandContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 345D0464CE5C92DE3AB73ADEFB278856 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - LimitedAvailabilityCommandContent

@available(OpenSwiftUI_v5_5, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@usableFromInline
@frozen
@MainActor
@preconcurrency
struct LimitedAvailabilityCommandContent: PrimitiveCommands, Commands {
    let storage: LimitedAvailabilityCommandContentStorageBase

    @usableFromInline
    init<A>(erasing content: A) where A: Commands {
        storage = LimitedAvailabilityCommandContentStorage(content)
    }

    public var body: Never {
        _openSwiftUIUnreachableCode()
    }

    nonisolated public static func _makeCommands(
        content: _GraphValue<LimitedAvailabilityCommandContent>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        var outputs = _CommandsOutputs(preferences: inputs.preferences.makeIndirectOutputs())
        let indirectOutputs = IndirectOutputs(
            content: content.value,
            parentGraph: Subgraph.current!,
            inputs: inputs,
            outputs: outputs,
            childSubgraph: nil
        )
        _ = Attribute(indirectOutputs)
        return outputs
    }

    private struct IndirectOutputs: StatefulRule {
        @Attribute var content: LimitedAvailabilityCommandContent
        var parentGraph: Subgraph
        var inputs: _CommandsInputs
        var outputs: _CommandsOutputs
        var childSubgraph: Subgraph?

        typealias Value = Void

        mutating func updateValue() {
            guard childSubgraph == nil else { return }
            let graph = parentGraph.graph
            let child = Subgraph(graph: graph)
            childSubgraph = child
            parentGraph.addChild(child)
            child.apply {
                var inputs = inputs
                inputs.copyCaches()
                let childOutputs = content.storage.makeCommands(
                    content: .init($content),
                    inputs: inputs
                )
                outputs.preferences.attachIndirectOutputs(to: childOutputs.preferences)
            }
        }
    }
}

@available(*, unavailable)
extension LimitedAvailabilityCommandContent: Sendable {}

// MARK: - LimitedAvailabilityCommandContentStorageBase

@available(OpenSwiftUI_v5_5, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@usableFromInline
class LimitedAvailabilityCommandContentStorageBase {
    func makeCommands(
        content: _GraphValue<LimitedAvailabilityCommandContent>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension LimitedAvailabilityCommandContentStorageBase: Sendable {}

// MARK: - LimitedAvailabilityCommandContentStorage

@available(OpenSwiftUI_v5_5, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private final class LimitedAvailabilityCommandContentStorage<Content>: LimitedAvailabilityCommandContentStorageBase where Content: Commands {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }

    override func makeCommands(
        content: _GraphValue<LimitedAvailabilityCommandContent>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        Content._makeCommands(
            content: .init(Attribute(Child(content: content.value))),
            inputs: inputs
        )
    }

    struct Child: Rule {
        @Attribute var content: LimitedAvailabilityCommandContent

        var value: Content {
            (content.storage as! LimitedAvailabilityCommandContentStorage).content
        }
    }
}
