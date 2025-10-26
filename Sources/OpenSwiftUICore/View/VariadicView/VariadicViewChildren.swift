//
//  VariadicViewChildren.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

// MARK: - _VariadicView.Children + View

@available(OpenSwiftUI_v1_0, *)
extension _VariadicView.Children: View, MultiView, PrimitiveView {
    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let child = _GraphValue(Child(children: view.value))
        return ForEach._makeViewList(view: child, inputs: inputs)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        nil
    }

    private struct Child: Rule, AsyncAttribute {
        typealias Value = ForEach<_VariadicView.Children, AnyHashable, _VariadicView.Children.Element>

        @Attribute var children: _VariadicView.Children

        var value: Value {
            ForEach(children) { $0 }
        }
    }
}

// MARK: - _VariadicView.Children + RandomAccessCollection

@available(OpenSwiftUI_v1_0, *)
extension _VariadicView.Children: RandomAccessCollection {

    public struct Element: PrimitiveView, UnaryView, Identifiable {
        var view: ViewList.View
        var traits: ViewTraitCollection
        
        public var id: AnyHashable {
            view.viewID
        }

        public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID: Hashable {
            view.id.primaryExplicitID.flatMap{ $0.as(type: ID.self) }
        }

        /// The value of each trait associated with the view. Changing
        /// the traits will not affect the view in any way.
        public subscript<Trait: _ViewTraitKey>(key: Trait.Type) -> Trait.Value {
            get { traits[key] }
            set { traits[key] = newValue }
        }

        public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
            ViewList.View._makeView(
                view: view[\.view],
                inputs: inputs
            )
        }
    }
    
    public var startIndex: Int { .zero }

    public var endIndex: Int { Update.ensure { list.count } }

    public subscript(index: Int) -> Element {
        var element: Element?
        Update.ensure {
            var start = index
            var transform = transform
            list.applySublists(
                from: &start,
                list: nil,
                transform: &transform
            ) { sublist in
                let index = sublist.start
                let count = sublist.count
                if index < count {
                    element = Element(
                        view: .init(
                            elements: sublist.elements,
                            id: sublist.id,
                            index: index,
                            count: count,
                            contentSubgraph: contentSubgraph
                        ),
                        traits: sublist.traits
                    )
                }
                return index >= count
            }
        }
        guard let element else {
            Log.internalError("Accessing invalid variadic view child at index %d", index)
            return Element(
                view: .init(emptyViewID: index),
                traits: .init()
            )
        }
        return element
    }
}
