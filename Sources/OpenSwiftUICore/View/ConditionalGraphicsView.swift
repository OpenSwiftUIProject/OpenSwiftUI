//
//  ConditionalGraphicsView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EE189C0F837A6307D8FC8254E9B07A27 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - UsingGraphicsRenderer

package struct UsingGraphicsRenderer: ViewInput {
    package static let defaultValue: Bool = false
}

extension _GraphInputs {
    @inline(__always)
    var usingGraphicsRenderer: Bool {
        get { self[UsingGraphicsRenderer.self] }
        set { self[UsingGraphicsRenderer.self] = newValue }
    }
}

extension _ViewInputs {
    @inline(__always)
    var usingGraphicsRenderer: Bool {
        get { self[UsingGraphicsRenderer.self] }
        set { self[UsingGraphicsRenderer.self] = newValue }
    }
}

extension _ViewListInputs {
    @inline(__always)
    var usingGraphicsRenderer: Bool {
        get { self[UsingGraphicsRenderer.self] }
        set { self[UsingGraphicsRenderer.self] = newValue }
    }
}

extension _ViewListCountInputs {
    @inline(__always)
    var usingGraphicsRenderer: Bool {
        get { self[UsingGraphicsRenderer.self] }
        set { self[UsingGraphicsRenderer.self] = newValue }
    }
}

// MARK: - ConditionalGraphicsView

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
public protocol ConditionalGraphicsView: View {
    associatedtype GraphicsBody: View

    @ViewBuilder
    @MainActor
    @preconcurrency
    var graphicsBody: GraphicsBody { get }
}

@_spi(Private)
extension ConditionalGraphicsView {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var newInputs = inputs
        let (body, buffer) = makeBody(view: view, inputs: &newInputs.base, fields: fields)
        let outputs = body.makeView(inputs: newInputs)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        return outputs
    }
    
    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var newInputs = inputs
        let (body, buffer) = makeBody(view: view, inputs: &newInputs.base, fields: fields)
        let outputs = body.makeViewList(inputs: newInputs)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        return outputs
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        if inputs.usingGraphicsRenderer {
            return GraphicsBody._viewListCount(inputs: inputs)
        } else {
            return Body._viewListCount(inputs: inputs)
        }
    }

    nonisolated private static func makeBody(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (ConditionalGraphValue<Body, GraphicsBody>, _DynamicPropertyBuffer?) {
        precondition(
            Metadata(Self.self).isValueType,
            "views must be value types (either a struct or an enum); \(Self.self) is a class."
        )
        if inputs.usingGraphicsRenderer {
            let accessor = GraphicsViewBodyAccessor<Self>()
            let (body, buffer) = accessor.makeBody(container: view, inputs: &inputs, fields: fields)
            return (.second(body), buffer)
        } else {
            let accessor = ViewBodyAccessor<Self>()
            let (body, buffer) = accessor.makeBody(container: view, inputs: &inputs, fields: fields)
            return (.first(body), buffer)
        }
    }
}

// MARK: - ConditionalGraphValue

package enum ConditionalGraphValue<First, Second> {
    case first(_GraphValue<First>)
    case second(_GraphValue<Second>)
}

extension ConditionalGraphValue where First: View, Second: View {
    package func makeView(inputs: _ViewInputs) -> _ViewOutputs {
        switch self {
        case let .first(view): First.makeDebuggableView(view: view, inputs: inputs)
        case let .second(view): Second.makeDebuggableView(view: view, inputs: inputs)
        }
    }

    package func makeViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        switch self {
        case let .first(view): First.makeDebuggableViewList(view: view, inputs: inputs)
        case let .second(view): Second.makeDebuggableViewList(view: view, inputs: inputs)
        }
    }
}

// MARK: - GraphicsViewBodyAccessor

private struct GraphicsViewBodyAccessor<V>: BodyAccessor where V: ConditionalGraphicsView {
    typealias Container = V

    typealias Body = V.GraphicsBody

    func updateBody(of container: V, changed: Bool) {
        guard changed else { return }
        setBody {
            container.graphicsBody
        }
    }
}
