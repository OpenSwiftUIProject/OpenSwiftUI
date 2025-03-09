//
//  VariadicView_Children.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 52A2FFECFBCF37BFFEED558E33EBD1E3 (?)
//  ID: 9B09D1820E97ECBB666F7560EA2A2D2C (?)


// FIXME: Confirm the ID

import OpenGraphShims

extension _VariadicView_Children: RandomAccessCollection {
    public struct Element: PrimitiveView, UnaryView, Identifiable {
        
//        var view: _ViewList_View
        var traits: ViewTraitCollection
        
        public var id: AnyHashable {
//            view.viewID
            preconditionFailure("TODO")

        }
        public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID : Hashable {
            preconditionFailure("TODO")
        }

        /// The value of each trait associated with the view. Changing
        /// the traits will not affect the view in any way.
        public subscript<Trait: _ViewTraitKey>(key: Trait.Type) -> Trait.Value {
            get { traits[key] }
            set { traits[key] = newValue }
        }

        public static func _makeView(view: _GraphValue<_VariadicView_Children.Element>, inputs: _ViewInputs) -> _ViewOutputs {
            preconditionFailure("TODO")
        }
    }
    
    public var startIndex: Int {
        preconditionFailure("TODO")

//      get
    }
    public var endIndex: Int {
        preconditionFailure("TODO")

//      get
    }
    public subscript(index: Int) -> _VariadicView_Children.Element {
        preconditionFailure("TODO")

//      get
    }
}

extension _VariadicView_Children {
    private struct Child: Rule, AsyncAttribute {
        typealias Value = ForEach<_VariadicView_Children, AnyHashable, _VariadicView_Children.Element>
        
        @Attribute var children: _VariadicView_Children
        
        var value: Value {
            preconditionFailure("TODO")
        }
    }
}

extension ViewList {
    package typealias Backing = _ViewList_Backing
}

package struct _ViewList_Backing {
    package var children: _VariadicView.Children
//    package var viewCount: Swift.Int {
//    get
//    }
    package init(_ children: _VariadicView.Children)  {
        self.children = children
    }
//    package func visitViews<V>(applying v: inout V, from start: inout Swift.Int) -> Swift.Bool where V : SwiftUICore.ViewListVisitor
}

// MARK: - _ViewList_View

package struct _ViewList_View {
    var elements: any ViewList.Elements
    var id: _ViewList_ID
    var index: Int
    var count: Int
    var contentSubgraph: Subgraph
}

// MARK: - ViewListVisitor

protocol ViewListVisitor {
    mutating func visit(view: _ViewList_View, traits: ViewTraitCollection) -> Bool
}
