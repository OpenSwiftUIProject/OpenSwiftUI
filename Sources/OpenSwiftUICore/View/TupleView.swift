//
//  TupleView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 79611CB2B7848ECB3D9EC1F26B13F28F (SwiftUI)
//  ID: DE681AB5F1A334FA14ECABDE70CB1955 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - TupleView

/// A View created from a swift tuple of View values.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct TupleView<T>: PrimitiveView, View {
    public var value: T

    @inlinable
    public init(_ value: T) { self.value = value }

    public static func _makeView(
        view: _GraphValue<TupleView<T>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let contentTypes = ViewDescriptor.tupleDescription(TupleType(T.self)).contentTypes
        if contentTypes.count == 1 {
            var makeUnary = MakeUnary(view: view, inputs: inputs, outputs: nil)
            contentTypes[0].1.visitType(visitor: &makeUnary)
            return makeUnary.outputs!
        } else {
            guard !contentTypes.isEmpty else {
                return _ViewOutputs()
            }
            return makeImplicitRoot(view: view, inputs: inputs)
        }
    }

    public static func _makeViewList(
        view: _GraphValue<TupleView<T>>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let tupleType = TupleType(T.self)
        let contentTypes = ViewDescriptor.tupleDescription(tupleType).contentTypes
        var makeList = MakeList(
            view: view,
            inputs: inputs,
            wrapChildren: inputs.options.contains(.tupleViewCreatesUnaryElements)
        )
        if inputs.options.contains(.tupleViewCreatesUnaryElements),
           makeList.inputs.options.contains(.tupleViewCreatesUnaryElements) {
            makeList.inputs.options.subtract([.requiresSections, .tupleViewCreatesUnaryElements])
        }
        guard !contentTypes.isEmpty else {
            return _ViewListOutputs.concat([], inputs: makeList.inputs)
        }
        for (index, conformance) in contentTypes {
            makeList.index = index
            makeList.offset = tupleType.elementOffset(at: index)
            conformance.visitType(visitor: &makeList)
        }
        return _ViewListOutputs.concat(makeList.outputs, inputs: makeList.inputs)
    }

    @available(OpenSwiftUI_v2_0, *)
    public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        let contentTypes = ViewDescriptor.tupleDescription(TupleType(T.self)).contentTypes
        if inputs.options.contains(.tupleViewCreatesUnaryElements) {
            return contentTypes.count
        } else {
            var countViews = CountViews(inputs: inputs)
            for contentType in contentTypes {
                contentType.1.visitType(visitor: &countViews)
            }
            return countViews.result
        }
    }

    private struct MakeUnary: ViewTypeVisitor {
        var view: _GraphValue<TupleView<T>>
        var inputs: _ViewInputs
        var outputs: _ViewOutputs?

        mutating func visit<V>(type: V.Type) where V: View {
            outputs = V.makeDebuggableView(
                view: view.unsafeBitCast(to: V.self),
                inputs: inputs
            )
        }
    }

    private struct MakeList: ViewTypeVisitor {
        var view: _GraphValue<TupleView<T>>
        var inputs: _ViewListInputs
        var index: Int = .zero
        var offset: Int = .zero
        let wrapChildren: Bool
        var outputs: [_ViewListOutputs] = []

        mutating func visit<V>(type: V.Type) where V : View {
            inputs.base.pushStableIndex(index)
            let view = view.value.unsafeOffset(at: offset, as: V.self)
            let output = if wrapChildren {
                _ViewListOutputs.unaryViewList(view: _GraphValue(view), inputs: inputs)
            } else {
                V.makeDebuggableViewList(view: _GraphValue(view), inputs: inputs)
            }
            outputs.append(output)
            inputs.implicitID = output.nextImplicitID
        }
    }

    private struct CountViews: ViewTypeVisitor {
        var inputs: _ViewListCountInputs
        var result: Int? = .zero

        mutating func visit<V>(type: V.Type) where V : View {
            guard let oldResult = result,
                  let count = V._viewListCount(inputs: inputs)
            else {
                result = nil
                return
            }
            result = oldResult + count
        }
    }
}

@available(*, unavailable)
extension TupleView: Sendable {}
