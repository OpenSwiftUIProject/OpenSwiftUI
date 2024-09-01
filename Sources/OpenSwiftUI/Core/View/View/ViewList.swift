//
//  ViewList.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 70E71091E926A1B09B75AAEB38F5AA3F

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
        fatalError("TODO")
    }
}

extension _ViewListOutputs {
    @inline(__always)
    static func emptyParentViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        staticList(EmptyElements(), inputs: inputs, staticCount: 0)
    }
    
    package static func nonEmptyParentViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        fatalError("TODO")
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

struct _ViewList_ID {
    var _index: Int32
    var implicitID: Int32
    private var explicitIDs: [Explicit]
}

extension _ViewList_ID {
    private struct Explicit {
    }
}

// MARK: - IndirectMap

#if OPENSWIFTUI_RELEASE_2024
final package class IndirectAttributeMap {
    final package let subgraph: Subgraph
    final package var map: [AnyAttribute: AnyAttribute]
    
    package init(subgraph: Subgraph) {
        self.subgraph = subgraph
        self.map = [:]
    }
}
#elseif OPENSWIFTUI_RELEASE_2021
final package class _ViewList_IndirectMap {
    final package let subgraph: OGSubgraph
    
    #if canImport(Darwin)
    final package var map: [OGAttribute: OGAttribute]
    #endif
    
    init(subgraph: OGSubgraph) {
        self.subgraph = subgraph
        #if canImport(Darwin)
        self.map = [:]
        #endif
    }
}
#endif

// MARK: - _ViewList_Elements

package protocol _ViewList_Elements {
    typealias Body = (_ViewInputs, @escaping Self.MakeElement) -> (_ViewOutputs?, Swift.Bool)
    typealias MakeElement = (_ViewInputs) -> _ViewOutputs
    #if OPENSWIFTUI_RELEASE_2024
    typealias Release = _ViewList_ReleaseElements
    #elseif OPENSWIFTUI_RELEASE_2021
    typealias Release = () -> Void
    #endif
    
    var count: Int { get }
    
    #if OPENSWIFTUI_RELEASE_2024
    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool)
    
    func tryToReuseElement(
        at index: Int,
        by other: any  _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool
    #elseif OPENSWIFTUI_RELEASE_2021
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
    #endif
    
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
        fatalError("TODO")
    }
    
    func tryToReuseElement(
        at index: Int,
        by other: any  _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: _ViewList_IndirectMap,
        testOnly: Bool
    ) -> Bool {
        fatalError("TODO")
    }
}

// MARK: - _ViewList_Subgraph

class _ViewList_Subgraph {
    let subgraph: OGSubgraph
    private var refcount : UInt32
    
    init(subgraph: OGSubgraph) {
        self.subgraph = subgraph
        self.refcount = 1 // TODO
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
}

// MARK: - _ViewList_View

struct _ViewList_View {
    var elements: _ViewList_Elements
    var id: _ViewList_ID
    var index: Int
    var count: Int
    var contentSubgraph: OGSubgraph
}

// TODO
package protocol ViewList {
}
