//
//  ViewList.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 70E71091E926A1B09B75AAEB38F5AA3F

import Foundation
package import OpenGraphShims

// MARK: - _ViewListInputs

/// Input values to `View._makeViewList()`.
public struct _ViewListInputs {
    package var base: _GraphInputs
    package var implicitID: Int
    
    package struct Options: OptionSet {
        package let rawValue: Int

        package init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        package static let canTransition: Options = Options(rawValue: 1 << 0)
        package static let disableTransitions: Options = Options(rawValue: 1 << 1)
        package static let requiresDepthAndSections: Options = Options(rawValue: 1 << 2)
        package static let requiresNonEmptyGroupParent: Options = Options(rawValue: 1 << 3)
        package static let isNonEmptyParent: Options = Options(rawValue: 1 << 4)
        package static let resetHeaderStyleContext: Options = Options(rawValue: 1 << 5)
        package static let resetFooterStyleContext: Options = Options(rawValue: 1 << 6)
        package static let layoutPriorityIsTrait: Options = Options(rawValue: 1 << 7)
        package static let requiresSections: Options = Options(rawValue: 1 << 8)
        package static let tupleViewCreatesUnaryElements: Options = Options(rawValue: 1 << 9)
        package static let previewContext: Options = Options(rawValue: 1 << 10)
        package static let needsDynamicTraits: Options = Options(rawValue: 1 << 11)
        package static let allowsNestedSections: Options = Options(rawValue: 1 << 12)
        package static let sectionsConcatenateFooter: Options = Options(rawValue: 1 << 13)
        package static let needsArchivedAnimationTraits: Options = Options(rawValue: 1 << 14)
        package static let sectionsAreHierarchical: Options = Options(rawValue: 1 << 15)
    }
    
    package var options: _ViewListInputs.Options
    @OptionalAttribute var traits: ViewTraitCollection?
    package var traitKeys: ViewTraitKeys?

    
    // MARK: - base
    
    @inline(__always)
    mutating func withMutateGraphInputs<R>(_ body: (inout _GraphInputs) -> R) -> R {
        body(&base)
    }
}

// MARK: - ViewListOutputs

/// Output values from `View._makeViewList()`.
public struct _ViewListOutputs {
    var views: Views
    var nextImplicitID: Int
    var staticCount: Int?
    
    enum Views {
        case staticList(_ViewList_Elements)
        case dynamicList(Attribute<ViewList>, ListModifier?)
    }
    
    class ListModifier {
        init() {}
        
        func apply(to: inout ViewList)  {
            // TODO
        }
    }
    
    private static func staticList(_ elements: _ViewList_Elements, inputs: _ViewListInputs, staticCount: Int) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }
}

extension _ViewListOutputs {
    @inline(__always)
    static func emptyParentViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        staticList(EmptyElements(), inputs: inputs, staticCount: 0)
    }
    
    package static func nonEmptyParentViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }
}

// MARK: - _ViewListCountInputs

/// Input values to `View._viewListCount()`.
public struct _ViewListCountInputs {
    var customInputs: PropertyList
    var options: _ViewListInputs.Options
    var baseOptions: _GraphInputs.Options
    
    subscript<Input: GraphInput>(_ type: Input.Type) -> Input.Value {
        get { customInputs[type] }
        set { customInputs[type] = newValue }
    }
    
    mutating func append<Input: GraphInput, Value>(_ value: Value, to type: Input.Type) where Input.Value == [Value]  {
        var values = self[type]
        values.append(value)
        self[type] = values
    }
    
    mutating func popLast<Input: GraphInput, Value>(_ type: Input.Type) -> Value? where Input.Value == [Value]  {
        var values = self[type]
        guard let value = values.popLast() else {
            return nil
        }
        self[type] = values
        return value
    }
}

// MARK: - _ViewList_ID

package struct _ViewList_ID {
    var _index: Int32
    var implicitID: Int32
    private var explicitIDs: [Explicit]
    
    package class Views {
        let isDataDependent: Bool
        var endIndex: Int { preconditionFailure("") }
        subscript(index: Int) -> _ViewList_ID { preconditionFailure("") }
        func isEqual(to other: Views) -> Bool { preconditionFailure("") }
        init(isDataDependent: Bool) {
            self.isDataDependent = isDataDependent
        }
        // func withDataDependency() -> Views {}
    }
    
    final class _Views<Base>: Views where Base: Equatable, Base: RandomAccessCollection, Base.Element == _ViewList_ID, Base.Index == Int {
        let base: Base
        
        init(_ base: Base, isDataDependent: Bool) {
            self.base = base
            super.init(isDataDependent: isDataDependent)
        }
        override var endIndex: Int {
            base.endIndex
        }
        
        override subscript(index: Int) -> _ViewList_ID {
            base[index]
        }
        
        override func isEqual(to other: _ViewList_ID.Views) -> Bool {
            guard let other = other as? Self else { return false }
            return base == other.base
        }
    }
    
    final class JoinedViews: Views {
        let views: [(views: Views, endOffset: Int)]
        let count: Int
        
        init(_ views: [Views], isDataDependent: Bool) {
            var offset = 0
            var result: [(views: Views, endOffset: Int)] = []
            for view in views {
                offset += views.distance(from: 0, to: view.endIndex)
                result.append((view, offset))
            }
            self.views = result
            count = offset
            super.init(isDataDependent: isDataDependent)
        }
        
        override var endIndex: Int {
            views.endIndex
        }
        
        override subscript(index: Int) -> _ViewList_ID {
            preconditionFailure("TODO")
        }
        
        override func isEqual(to other: _ViewList_ID.Views) -> Bool {
            preconditionFailure("TODO")
        }
    }
    
    private struct Explicit: Equatable {
        let id: AnyHashable
        #if canImport(Darwin)
        let owner: AnyAttribute
        #endif
        let isUnary: Bool
    }
    
    struct Canonical {
        var _index: Int32
        var implicitID: Int32
        var explicitID: AnyHashable?
    }
    
    #if canImport(Darwin)
    mutating func bind(explicitID: AnyHashable, owner: AnyAttribute, isUnary: Bool) {
        explicitIDs.append(.init(id: explicitID, owner: owner, isUnary: isUnary))
    }
    #endif
}

// MARK: - IndirectMap

//#if OPENSWIFTUI_RELEASE_2024
//final package class IndirectAttributeMap {
//    final package let subgraph: OGSubgraph
//    // final package var map: [AnyAttribute: AnyAttribute]
//    
//    package init(subgraph: OGSubgraph) {
//        self.subgraph = subgraph
//        // self.map = [:]
//    }
//}
//#elseif OPENSWIFTUI_RELEASE_2021
final package class _ViewList_IndirectMap {
    final package let subgraph: OGSubgraph
    
    #if canImport(Darwin)
    final package var map: [AnyAttribute: AnyAttribute]
    #endif
    
    init(subgraph: OGSubgraph) {
        self.subgraph = subgraph
        #if canImport(Darwin)
        self.map = [:]
        #endif
    }
}
//#endif

// MARK: - _ViewList_Elements

package protocol _ViewList_Elements {
    typealias Body = (_ViewInputs, @escaping Self.MakeElement) -> (_ViewOutputs?, Swift.Bool)
    typealias MakeElement = (_ViewInputs) -> _ViewOutputs
//    #if OPENSWIFTUI_RELEASE_2024
//    typealias Release = _ViewList_ReleaseElements
//    #elseif OPENSWIFTUI_RELEASE_2021
    typealias Release = () -> Void
//    #endif
    
    var count: Int { get }
    
//    #if OPENSWIFTUI_RELEASE_2024
//    func makeElements(
//        from start: inout Int,
//        inputs: _ViewInputs,
//        indirectMap: IndirectAttributeMap?,
//        body: Body
//    ) -> (_ViewOutputs?, Bool)
//    
//    func tryToReuseElement(
//        at index: Int,
//        by other: any  _ViewList_Elements,
//        at otherIndex: Int,
//        indirectMap: IndirectAttributeMap,
//        testOnly: Bool
//    ) -> Bool
//    #elseif OPENSWIFTUI_RELEASE_2021
    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: _ViewList_IndirectMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool)
    
    func tryToReuseElement(
        at index: Int,
        by other: any  _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: _ViewList_IndirectMap,
        testOnly: Bool
    ) -> Bool
//    #endif
    
    func retain() -> Release
}

extension _ViewList_Elements {
    func retain() -> Release {
        {}
    }
}

private struct EmptyElements: _ViewList_Elements {
    var count: Int { 0 }

    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: _ViewList_IndirectMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool) {
        return (nil, true)
    }
    
    func tryToReuseElement(
        at index: Int,
        by other: any  _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: _ViewList_IndirectMap,
        testOnly: Bool
    ) -> Bool {
        other is EmptyElements
    }
}

// TODO
private struct UnaryElements<Value>: _ViewList_Elements {
    var body: Value
    var baseInputs: _GraphInputs
    
    init(body: Value, baseInputs: _GraphInputs) {
        self.body = body
        self.baseInputs = baseInputs
    }
    
    var count: Int { 1 }
    
    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: _ViewList_IndirectMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool) {
        preconditionFailure("TODO")
    }
    
    func tryToReuseElement(
        at index: Int,
        by other: any  _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: _ViewList_IndirectMap,
        testOnly: Bool
    ) -> Bool {
        preconditionFailure("TODO")
    }
}

// MARK: - _ViewList_Subgraph

class _ViewList_Subgraph {
    let subgraph: OGSubgraph
    private var refcount : UInt32
    
    init(subgraph: OGSubgraph) {
        self.subgraph = subgraph
        self.refcount = 1
    }
    
    func invalidate() {}
}

extension _ViewList_Subgraph {
    var isValid: Bool {
        guard refcount > 0 else {
            return false
        }
        return subgraph.isValid
    }
    
    func retain() {
        refcount &+= 1
    }
    
    func release(isInserted: Bool) {
        refcount &-= 1
        guard refcount == 0 else {
            return
        }
        invalidate()
        guard subgraph.isValid else {
            return
        }
        subgraph.willInvalidate(isInserted: isInserted)
        subgraph.invalidate()
    }
    
    @inlinable
    func wrapping(_ elements: _ViewList_Elements) -> _ViewList_Elements {
        SubgraphElements(base: elements, subgraph: self)
    }
}

// TODO
private struct SubgraphElements: _ViewList_Elements {
    let base: _ViewList_Elements
    let subgraph: _ViewList_Subgraph
    
    var count: Int {
        preconditionFailure("TODO")
    }
    
    func makeElements(from start: inout Int, inputs: _ViewInputs, indirectMap: _ViewList_IndirectMap?, body: (_ViewInputs, @escaping MakeElement) -> (_ViewOutputs?, Bool)) -> (_ViewOutputs?, Bool) {
        preconditionFailure("TODO")
    }
    
    func tryToReuseElement(at index: Int, by other: any _ViewList_Elements, at otherIndex: Int, indirectMap: _ViewList_IndirectMap, testOnly: Bool) -> Bool {
        preconditionFailure("TODO")
    }
}

// MARK: - _ViewList_View

package struct _ViewList_View {
    var elements: _ViewList_Elements
    var id: _ViewList_ID
    var index: Int
    var count: Int
    var contentSubgraph: OGSubgraph
}

// MARK: - _ViewList_Sublist

struct _ViewList_Sublist {
    var start: Int
    var count: Int
    var id: _ViewList_ID
    var elements: _ViewList_Elements
    var traits: ViewTraitCollection
    var list: Attribute<ViewList>?
}

struct _ViewList_SublistTransform {
    var items: [any _ViewList_SublistTransform_Item]
}


protocol _ViewList_SublistTransform_Item {
    func apply(sublist: inout _ViewList_Sublist)
}

// MARK: - ViewList

protocol ViewList {
    func count(style: _ViewList_IteratorStyle) -> Int
    func estimatedCount(style: _ViewList_IteratorStyle) -> Int
    var traitKeys: ViewTraitKeys? { get }
    var viewIDs: _ViewList_ID.Views? { get }
    var traits: ViewTraitCollection { get }
    func applyNodes(from index: inout Int, style: _ViewList_IteratorStyle, list: _GraphValue<ViewList>?, transform: inout _ViewList_SublistTransform, to body: (inout Int, _ViewList_IteratorStyle, _ViewList_Node, inout _ViewList_SublistTransform) -> Bool) -> Bool
    func edit(forID id: _ViewList_ID, since transaction: TransactionID) -> _ViewList_Edit?
    func firstOffset<OtherID>(forID id: OtherID, style: _ViewList_IteratorStyle) -> Int? where OtherID: Hashable
}

// MARK: - ViewListVisitor

protocol ViewListVisitor {
    mutating func visit(view: _ViewList_View, traits: ViewTraitCollection) -> Bool
}

// MARK: - _ViewList_IteratorStyle

// TODO
struct _ViewList_IteratorStyle: Equatable {
    var value: UInt
    
    func alignToPreviousGranularityMultiple(_ value: inout Int) {
        preconditionFailure("TODO")
    }
}

enum _ViewList_Edit: Equatable {
    case inserted
    case removed
}

enum _ViewList_Node {
    case list(any ViewList, Attribute<any ViewList>?)
    case sublist(_ViewList_Sublist)
    //  case group(_ViewList_Group)
    //  case section(_ViewList_Section)
}
