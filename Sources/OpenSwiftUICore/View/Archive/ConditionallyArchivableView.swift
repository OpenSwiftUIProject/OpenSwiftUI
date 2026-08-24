//
//  ConditionallyArchivableView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F8DD13CD1E8AE0A4CA4BADC71F5C64DE (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - ConditionallyArchivableView

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public protocol ConditionallyArchivableView: View {
    associatedtype ArchivedBody: View

    @ViewBuilder
    var archivedBody: ArchivedBody { get }
}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension ConditionallyArchivableView {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var newInputs = inputs
        let (body, buffer) = makeBody(
            view: view,
            inputs: &newInputs.base,
            fields: fields
        )
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
        let (body, buffer) = makeBody(
            view: view,
            inputs: &newInputs.base,
            fields: fields
        )
        let outputs = body.makeViewList(inputs: newInputs)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        return outputs
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        if inputs.archivedView.isArchived {
            ArchivedBody._viewListCount(inputs: inputs)
        } else {
            Body._viewListCount(inputs: inputs)
        }
    }

    nonisolated private static func makeBody(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (
        ConditionalGraphValue<Body, ArchivedBody>,
        _DynamicPropertyBuffer?
    ) {
        precondition(
            Metadata(Self.self).isValueType,
            "views must be value types (either a struct or an enum); \(Self.self) is a class."
        )
        if inputs.archivedView.isArchived {
            let accessor = ArchivedViewBodyAccessor<Self>()
            let (body, buffer) = accessor.makeBody(
                container: view,
                inputs: &inputs,
                fields: fields
            )
            return (.second(body), buffer)
        } else {
            let accessor = ViewBodyAccessor<Self>()
            let (body, buffer) = accessor.makeBody(
                container: view,
                inputs: &inputs,
                fields: fields
            )
            return (.first(body), buffer)
        }
    }
}

// MARK: - ArchivedViewBodyAccessor

private struct ArchivedViewBodyAccessor<V>: BodyAccessor where V: ConditionallyArchivableView {
    typealias Container = V
    typealias Body = V.ArchivedBody

    func updateBody(of container: V, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.archivedBody
        }
    }
}
