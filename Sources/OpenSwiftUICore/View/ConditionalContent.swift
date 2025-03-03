//
//  ConditionalContent.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 1A625ACC143FD8524C590782FD8F4F8C (SwiftUI)

package import OpenGraphShims

// MARK: - ConditionalContent

/// View content that shows one of two possible children.
@frozen
public struct _ConditionalContent<TrueContent, FalseContent> {
    @frozen
    public enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }

    public let storage: Storage
}

@available(*, unavailable)
extension _ConditionalContent.Storage: Sendable {}

@available(*, unavailable)
extension _ConditionalContent: Sendable {}

extension _ConditionalContent {
    /// Creates a conditional content.
    ///
    /// You don't use this initializer directly. OpenSwiftUI creates a
    /// _ConditionalContent on your behalf when using conditional
    /// statements in a variety of result builders.
    @available(*, deprecated, message: "Do not use this.")
    @_alwaysEmitIntoClient
    public init(_storage: Storage) {
        self.storage = _storage
    }

    @_alwaysEmitIntoClient
    package init(__storage: Storage) {
        self.storage = __storage
    }
}

// MARK: - ConditionalContent + View

extension _ConditionalContent: View, PrimitiveView where TrueContent: View, FalseContent: View {
    @usableFromInline
    init(storage: Storage) {
        self.storage = storage
    }
    
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        if _SemanticFeature_v2.isEnabled {
            return makeImplicitRoot(view: view, inputs: inputs)
        } else {
            let metadata = makeConditionalMetadata(ViewDescriptor.self)
            return makeDynamicView(metadata: metadata, view: view, inputs: inputs)
        }
    }
    
    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        let metadata = makeConditionalMetadata(ViewDescriptor.self)
        return makeDynamicViewList(metadata: metadata, view: view, inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        guard let trueCount = TrueContent._viewListCount(inputs: inputs),
              trueCount == FalseContent._viewListCount(inputs: inputs) else {
            return nil
        }
        return trueCount
    }
}

// MARK: - ConditionalContent + DynamicView

extension _ConditionalContent: DynamicView where TrueContent: View, FalseContent: View {
    package static var canTransition: Bool {
        true
    }

    package func childInfo(metadata: Metadata) -> (any Any.Type, ID?) {
        withUnsafePointer(to: self) { ptr in
            metadata.childInfo(ptr: ptr, emptyType: EmptyView.self)
        }
    }

    package func makeChildView(metadata: Metadata, view: Attribute<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        withUnsafePointer(to: self) { ptr in
            metadata.makeView(ptr: ptr, view: view, inputs: inputs)
        }
    }

    package func makeChildViewList(metadata: Metadata, view: Attribute<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        withUnsafePointer(to: self) { ptr in
            metadata.makeViewList(ptr: ptr, view: view, inputs: inputs)
        }
    }

    package typealias ID = UniqueID

    package typealias Metadata = ConditionalMetadata<ViewDescriptor>
}

extension _ConditionalContent {
    // MARK: - ConditionalContent + Info

    package struct Info {
        var content: _ConditionalContent
        var subgraph: Subgraph

        init(content: _ConditionalContent, subgraph: Subgraph) {
            self.content = content
            self.subgraph = subgraph
        }

        func matches(_ other: _ConditionalContent) -> Bool {
            switch content.storage {
            case .trueContent:
                switch other.storage {
                case .trueContent: true
                case .falseContent: false
                }
            case .falseContent:
                switch other.storage {
                case .trueContent: false
                case .falseContent: true
                }
            }
        }
    }

    // MARK: - ConditionalContent + Container

    package struct Container<Provider>: StatefulRule, AsyncAttribute
        where TrueContent == Provider.TrueContent,
        FalseContent == Provider.FalseContent,
        Provider: ConditionalContentProvider {
        @Attribute var content: _ConditionalContent
        let provider: Provider
        let parentSubgraph: Subgraph

        package init(content: Attribute<_ConditionalContent<TrueContent, FalseContent>>, provider: Provider) {
            self._content = content
            self.provider = provider
            self.parentSubgraph = Subgraph.current!
        }

        package typealias Value = Info

        package mutating func updateValue() {
            let content = content
            guard hasValue, value.matches(content) else {
                if hasValue {
                    eraseInfo(value)
                }
                value = makeInfo(content)
                return
            }
            var info = value
            info.content = content
            value = info
        }

        func makeInfo(_ content: _ConditionalContent) -> Info {
            let current = AnyAttribute.current!
            let graph = parentSubgraph.graph
            let newSubgraph = Subgraph(graph: graph)
            parentSubgraph.addChild(newSubgraph)
            return newSubgraph.apply {
                let inputs = provider.makeChildInputs()
                let outputs: Provider.Outputs
                switch content.storage {
                case let .trueContent(trueContent):
                    let trueChild = TrueChild(info: .init(identifier: current))
                    let trueChildAttribute = Attribute(trueChild)
                    trueChildAttribute.value = trueContent
                    outputs = provider.makeTrueOutputs(child: trueChildAttribute, inputs: inputs)
                case let .falseContent(falseContent):
                    let falseChild = FalseChild(info: .init(identifier: current))
                    let falseChildAttribute = Attribute(falseChild)
                    falseChildAttribute.value = falseContent
                    outputs = provider.makeFalseOutputs(child: falseChildAttribute, inputs: inputs)
                }
                provider.attachOutputs(to: outputs)
                return Info(content: content, subgraph: newSubgraph)
            }
        }

        func eraseInfo(_ info: Info) {
            let subgraph = info.subgraph
            subgraph.willInvalidate(isInserted: true)
            subgraph.invalidate()
        }
    }

    // MARK: - ConditionalContent + TrueChild

    package struct TrueChild: StatefulRule, AsyncAttribute {
        @Attribute var info: Info

        package typealias Value = TrueContent

        package mutating func updateValue() {
            guard case let .trueContent(content) = info.content.storage else {
                return
            }
            value = content
        }
    }

    // MARK: - ConditionalContent + FalseChild

    package struct FalseChild: StatefulRule, AsyncAttribute {
        @Attribute var info: Info

        package typealias Value = FalseContent

        package mutating func updateValue() {
            guard case let .falseContent(content) = info.content.storage else {
                return
            }
            value = content
        }
    }
}

// MARK: - ConditionalContentProvider

package protocol ConditionalContentProvider {
    associatedtype TrueContent
    associatedtype FalseContent
    associatedtype Inputs
    associatedtype Outputs
    var inputs: Inputs { get }
    var outputs: Outputs { get }
    func detachOutputs()
    func attachOutputs(to: Outputs)
    func makeChildInputs() -> Inputs
    func makeTrueOutputs(child: Attribute<TrueContent>, inputs: Inputs) -> Outputs
    func makeFalseOutputs(child: Attribute<FalseContent>, inputs: Inputs) -> Outputs
}
