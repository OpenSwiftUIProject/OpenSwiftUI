//
//  ConditionalContent.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 1A625ACC143FD8524C590782FD8F4F8C

import OpenGraphShims

/// View content that shows one of two possible children.
@frozen
public struct _ConditionalContent<TrueContent, FalseContent> {
    @usableFromInline
    @frozen
    enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }

    @usableFromInline
    let storage: _ConditionalContent<TrueContent, FalseContent>.Storage
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
    //    public static func _viewListCount(inputs: _ViewListCountInputs) -> Swift.Int?
    
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
                AnyView(view, id: ids.0)
            case .falseContent(let view):
                AnyView(view, id: ids.1)
            }
        }
    }
}
