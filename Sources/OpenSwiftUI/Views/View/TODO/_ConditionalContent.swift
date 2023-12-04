//
//  _ConditionalContent.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/1.
//  Updated by Kyle on 2023/10/8.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 1A625ACC143FD8524C590782FD8F4F8C

#if OPENSWIFTUI_USE_AG
internal import AttributeGraph
#else
internal import OpenGraph
#endif

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
    //    public static func _makeView(view: _GraphValue<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewInputs) -> _ViewOutputs
    //    public static func _makeViewList(view: _GraphValue<_ConditionalContent<TrueContent, FalseContent>>, inputs: _ViewListInputs) -> _ViewListOutputs
    //    public static func _viewListCount(inputs: _ViewListCountInputs) -> Swift.Int?
    
    private struct ChildView {
        @Attribute
        var content: _ConditionalContent

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
