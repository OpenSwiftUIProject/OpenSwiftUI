//
//  VariadicView_Children.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: TODO
//  ID: 52A2FFECFBCF37BFFEED558E33EBD1E3

import OpenGraphShims

/// An ad hoc collection of the children of a variadic view.
public struct _VariadicView_Children {
    var list: ViewList
    var contentSubgraph: OGSubgraph
}

extension _VariadicView_Children: RandomAccessCollection {
    public struct Element: PrimitiveView, UnaryView, Identifiable {
        
//        var view: _ViewList_View
        var traits: ViewTraitCollection
        
        public var id: AnyHashable {
//            view.viewID
            fatalError("TODO")

        }
        public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID : Hashable {
            fatalError("TODO")
        }
        
        public subscript<Trait: _ViewTraitKey>(key: Trait.Type) -> Trait.Value {
            get { traits[key] }
            set { traits[key] = newValue }
        }

        public static func _makeView(view: _GraphValue<_VariadicView_Children.Element>, inputs: _ViewInputs) -> _ViewOutputs {
            fatalError("TODO")
        }
    }
    
    public var startIndex: Int {
        fatalError("TODO")

//      get
    }
    public var endIndex: Int {
        fatalError("TODO")

//      get
    }
    public subscript(index: Int) -> _VariadicView_Children.Element {
        fatalError("TODO")

//      get
    }
}

extension _VariadicView_Children {
    private struct Child: Rule, AsyncAttribute {
        typealias Value = ForEach<_VariadicView_Children, AnyHashable, _VariadicView_Children.Element>
        
        @Attribute var children: _VariadicView_Children
        
        var value: Value {
            fatalError("TODO")
        }
    }
}
