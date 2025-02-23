//
//  ConditionalContent.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 1A625ACC143FD8524C590782FD8F4F8C (SwiftUI)
//  ID: C (SwiftUICore)

package import OpenGraphShims

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
    @_alwaysEmitIntoClient
    public init(_storage: Storage) {
        self.storage = _storage
    }
}

extension _ConditionalContent: View, PrimitiveView where TrueContent: View, FalseContent: View {
    @usableFromInline
    init(storage: Storage) {
        self.storage = storage
    }
    
    public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        if _SemanticFeature_v2.isEnabled {
            makeImplicitRoot(view: view, inputs: inputs)
        } else {
            AnyView._makeView(
                view: _GraphValue(ChildView(content: view.value)),
                inputs: inputs
            )
        }
    }
    
    //    public static func _makeViewList(view: _GraphValue<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewListInputs) -> _ViewListOutputs
    //    public static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
    
    private struct ChildView: Rule, AsyncAttribute {
        @Attribute var content: _ConditionalContent

        let ids: (UniqueID, UniqueID)

        init(content: Attribute<_ConditionalContent>) {
            _content = content
            ids = (UniqueID(), UniqueID())
        }

        var value: AnyView {
            switch content.storage {
            case .trueContent(let view):
                AnyView(view)
            case .falseContent(let view):
                AnyView(view)
            }
        }
    }
}

//extension _ConditionalContent : DynamicView where TrueContent : View, FalseContent : View {
//  package static var canTransition: Bool {
//    get
//  }
//  package func childInfo(metadata: ConditionalMetadata<ViewDescriptor>) -> (any Any.Type, UniqueID?)
//  package func makeChildView(metadata: ConditionalMetadata<ViewDescriptor>, view: Attribute<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewInputs) -> _ViewOutputs
//  package func makeChildViewList(metadata: ConditionalMetadata<ViewDescriptor>, view: Attribute<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewListInputs) -> _ViewListOutputs
//  package typealias ID = UniqueID
//  package typealias Metadata = ConditionalMetadata<ViewDescriptor>
//}

extension _ConditionalContent {
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
            preconditionFailure("TODO")
        }

        func makeInfo(_ content: _ConditionalContent) -> Info {
            let graph = parentSubgraph.graph
            let child = Subgraph(graph: graph)
            preconditionFailure("TODO")
        }

        func eraseInfo(_ info: Info) {
            let subgraph = info.subgraph
            subgraph.willInvalidate(isInserted: true)
            subgraph.invalidate()
        }
    }

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
