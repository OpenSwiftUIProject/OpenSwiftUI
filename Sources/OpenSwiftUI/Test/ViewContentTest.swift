//
//  ViewContentTest.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5AC2D91303C60C06D15F8A51A12C2AF4 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - View + withChildrenForTest

extension View {
    func withChildrenForTest<Result>(
        environment: EnvironmentValues = EnvironmentValues(),
        options: _ViewListInputs.Options = [],
        body: (_VariadicView.Children) -> Result
    ) -> Result {
        Update.ensure {
            let content = TestableViewContent(self, environment: environment, options: options)
            return body(content.children)
        }
    }
}

// MARK: - TestableSubgraph

private final class TestableSubgraph: ViewList.Subgraph {
    // Keep the host alive while extracted children retain this wrapper.
    let host: EmptyViewRendererHost

    init(host: EmptyViewRendererHost) {
        self.host = host
        super.init(subgraph: Subgraph(graph: host.viewGraph.graph))
    }
}

// MARK: - TransactionWrapper

private struct TransactionWrapper: StatefulRule {
    typealias Value = Any

    var body: ((TransactionID) -> Any)?

    mutating func updateValue() {
        value = body!(TransactionID(context: context))
        body = nil
    }
}

// MARK: - TestableViewContent

struct TestableViewContent<Content: View> {
    var _view: Attribute<Content>

    var _list: Attribute<any ViewList>

    var _transaction: Attribute<Any>?

    var host: EmptyViewRendererHost

    private var subgraph: TestableSubgraph

    var viewListCount: Int?

    init(
        _ view: Content,
        environment: EnvironmentValues,
        options: _ViewListInputs.Options
    ) {
        let host = EmptyViewRendererHost(environment: environment)
        let subgraph = TestableSubgraph(host: host)
        host.viewGraph.rootSubgraph.addChild(subgraph.subgraph)
        let (view, list, transaction, count) = subgraph.subgraph.apply {
            let view = Attribute(value: view)
            let inputs = _ViewListInputs(host.viewGraph.graphInputs, options: options)
            let outputs = Content.makeDebuggableViewList(view: _GraphValue(view), inputs: inputs)
            let transaction: Attribute<Any>? = Attribute(TransactionWrapper())
            let count = Content._viewListCount(inputs: _ViewListCountInputs(inputs))
            return (view, outputs.makeAttribute(inputs: inputs), transaction, count)
        }
        self._view = view
        self._list = list
        self._transaction = transaction
        self.host = host
        self.subgraph = subgraph
        self.viewListCount = count
    }

    var children: _VariadicView.Children {
        _VariadicView.Children(list, contentSubgraph: subgraph.subgraph)
    }

    var list: any ViewList {
        subgraph.wrapping(_list.wrappedValue)
    }
}
