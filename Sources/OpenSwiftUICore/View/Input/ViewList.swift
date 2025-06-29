//
//  ViewList.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 70E71091E926A1B09B75AAEB38F5AA3F (SwiftUI)
//  ID: E479C0E92CDD045BAF2EF653123E2E0B (SwiftUICore)

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

        package static let canTransition: Options = .init(rawValue: 1 << 0)
        package static let disableTransitions: Options = .init(rawValue: 1 << 1)
        package static let requiresDepthAndSections: Options = .init(rawValue: 1 << 2)
        package static let requiresNonEmptyGroupParent: Options = .init(rawValue: 1 << 3)
        package static let isNonEmptyParent: Options = .init(rawValue: 1 << 4)
        package static let resetHeaderStyleContext: Options = .init(rawValue: 1 << 5)
        package static let resetFooterStyleContext: Options = .init(rawValue: 1 << 6)
        package static let layoutPriorityIsTrait: Options = .init(rawValue: 1 << 7)
        package static let requiresSections: Options = .init(rawValue: 1 << 8)
        package static let tupleViewCreatesUnaryElements: Options = .init(rawValue: 1 << 9)
        package static let previewContext: Options = .init(rawValue: 1 << 10)
        package static let needsDynamicTraits: Options = .init(rawValue: 1 << 11)
        package static let allowsNestedSections: Options = .init(rawValue: 1 << 12)
        package static let sectionsConcatenateFooter: Options = .init(rawValue: 1 << 13)
        package static let needsArchivedAnimationTraits: Options = .init(rawValue: 1 << 14)
        package static let sectionsAreHierarchical: Options = .init(rawValue: 1 << 15)
    }

    package var options: _ViewListInputs.Options

    private var _traits: OptionalAttribute<ViewTraitCollection>

    package var traits: Attribute<ViewTraitCollection>? {
        get { _traits.attribute }
        set { _traits.attribute = newValue }
    }

    package var traitKeys: ViewTraitKeys?

    package init(_ base: _GraphInputs, implicitID: Int = 0, options: _ViewListInputs.Options = .init()) {
        self.base = base
        self.implicitID = implicitID
        self.options = options
        self._traits = .init()
        self.traitKeys = .init()
    }

    package init(_ base: _GraphInputs, implicitID: Int) {
        self.base = base
        self.implicitID = implicitID
        self.options = []
        self._traits = .init()
        self.traitKeys = .init()
    }

    package init(_ base: _GraphInputs, options: _ViewListInputs.Options) {
        self.base = base
        self.implicitID = 0
        self.options = options
        self._traits = .init()
        self.traitKeys = .init()
    }

    package init(_ base: _GraphInputs) {
        self.base = base
        self.implicitID = 0
        self.options = []
        self._traits = .init()
        self.traitKeys = .init()
    }

    package subscript<T>(input: T.Type) -> T.Value where T: ViewInput {
        get { base[input] }
        set { base[input] = newValue }
    }

    package subscript<T>(input: T.Type) -> T.Value where T: ViewInput, T.Value: GraphReusable {
        get { base[input] }
        set { base[input] = newValue }
    }

    package var canTransition: Bool {
        options.contains(.canTransition) && !options.contains(.disableTransitions)
    }

    package mutating func addTraitKey<K>(_ key: K.Type) where K: _ViewTraitKey {
        traitKeys?.insert(key)
    }
}

// MARK: - _ViewListCountInputs

/// Input values to `View._viewListCount()`.
public struct _ViewListCountInputs {
    package var customInputs: PropertyList
    package var options: _ViewListInputs.Options
    package var baseOptions: _GraphInputs.Options
    package var customModifierTypes: [ObjectIdentifier]

    package init(_ inputs: _ViewListInputs) {
        customInputs = inputs.base.customInputs
        options = inputs.options
        baseOptions = inputs.base.options
        customModifierTypes = []
    }

    package subscript<T>(input: T.Type) -> T.Value where T: GraphInput {
        get { customInputs[input] }
        set { customInputs[input] = newValue }
    }

    package mutating func append<T, U>(_ newValue: U, to key: T.Type) where T: GraphInput, T.Value == Stack<U> {
        var stack = self[key]
        defer { self[key] = stack }
        stack.push(newValue)
    }

    package mutating func popLast<T, U>(_ key: T.Type) -> U? where T: GraphInput, T.Value == Stack<U> {
        var stack = self[key]
        defer { self[key] = stack }
        return stack.pop()
    }

    package var base: _GraphInputs {
        var inputs = _GraphInputs.invalid
        inputs.customInputs = customInputs
        inputs.options = baseOptions
        return inputs
    }
}

@available(*, unavailable)
extension _ViewListCountInputs: Sendable {}

// MARK: - ViewListOutputs

/// Output values from `View._makeViewList()`.
public struct _ViewListOutputs {
    package enum Views {
        case staticList(any ViewList.Elements)
        case dynamicList(Attribute<any ViewList>, ListModifier?)
    }

    package var views: Views
    package var nextImplicitID: Int
    package var staticCount: Int?

    package init(_ views: _ViewListOutputs.Views, nextImplicitID: Int, staticCount: Int?) {
        self.views = views
        self.nextImplicitID = nextImplicitID
        self.staticCount = staticCount
    }

    package init(_ views: _ViewListOutputs.Views, nextImplicitID: Int) {
        self.views = views
        self.nextImplicitID = nextImplicitID
        self.staticCount = nil
    }

    package class ListModifier {
        init() {}

        package func apply(to list: inout ViewList) {}
    }
}

@available(*, unavailable)
extension _ViewListOutputs: Sendable {}

// MARK: - ViewList

package protocol ViewList {
    typealias ID = _ViewList_ID
    typealias Elements = _ViewList_Elements
    typealias Traits = ViewTraitCollection
    typealias Node = _ViewList_Node
    typealias Group = _ViewList_Group
    typealias IteratorStyle = _ViewList_IteratorStyle
    typealias Section = _ViewList_Section
    typealias Sublist = _ViewList_Sublist
    typealias SublistTransform = _ViewList_SublistTransform
    typealias Subgraph = _ViewList_Subgraph
    typealias Edit = _ViewList_Edit

    func count(style: IteratorStyle) -> Int
    func estimatedCount(style: IteratorStyle) -> Int
    var traitKeys: ViewTraitKeys? { get }
    var viewIDs: ID.Views? { get }
    var traits: ViewTraitCollection { get }

    typealias ApplyBody = (inout Int, IteratorStyle, Node, inout SublistTransform) -> Bool

    @discardableResult
    func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool
    func edit(forID id: ID, since transaction: TransactionID) -> Edit?
    func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable
}

// MARK: - ViewList.IteratorStyle

package struct _ViewList_IteratorStyle: Equatable {
    var value: UInt

    @inline(__always)
    static var applyGranularityBitCount: Int { 1 }
    @inline(__always)
    static var applyGranularityMask: UInt { (1 << applyGranularityBitCount) - 1 }
    @inline(__always)
    static var granularityMask: UInt { ~applyGranularityMask }

    package var applyGranularity: Bool {
        get { (value & Self.applyGranularityMask) != 0 }
        set { value = (newValue ? 1 : 0) | (value & Self.granularityMask) }
    }

    package var granularity: Int {
        get { Int(bitPattern: value >> Self.applyGranularityBitCount) }
        set { value = (UInt(bitPattern: newValue) << Self.applyGranularityBitCount) | (value & Self.applyGranularityMask) }
    }

    package init(granularity: Int) {
        value = UInt(bitPattern: granularity) << Self.applyGranularityBitCount
    }

    package init() {
        self.init(granularity: 1)
    }

    package func applyGranularity(to count: Int) -> Int {
        guard value != .zero else { return count }
        return granularity * count
    }

    package func alignToPreviousGranularityMultiple(_ value: inout Int) {
        guard value != .zero else { return }
        let granularity = granularity
        guard granularity != 1 else { return }
        let diff = value - value / granularity * granularity
        value -= diff
    }

    package func alignToNextGranularityMultiple(_ value: inout Int) {
        let granularity = granularity
        guard granularity != 1 else { return }
        let diff = value - value / granularity * granularity
        guard diff != .zero else { return }
        value += (granularity - diff)
    }
}

// MARK: - ViewList.Edit

package enum _ViewList_Edit {
    case inserted
    case removed
}

// MARK: - ViewList.Sublist

package struct _ViewList_Sublist {
    package var start: Int
    package var count: Int
    package var id: ViewList.ID
    package var elements: any ViewList.Elements
    package var traits: ViewTraitCollection
    package var list: Attribute<ViewList>?

    package init(start: Int, count: Int, id: _ViewList_ID, elements: any ViewList.Elements, traits: ViewList.Traits, list: Attribute<ViewList>?) {
        self.start = start
        self.count = count
        self.id = id
        self.elements = elements
        self.traits = traits
        self.list = list
    }
}

// MARK: - ViewList.SublistTransform

package struct _ViewList_SublistTransform {
    package typealias Item = _ViewList_SublistTransform_Item

    package var items: [any Item]

    package init() { items = [] }

    package var isEmpty: Bool { items.isEmpty }

    package mutating func push<T>(_ item: T) where T: Item {
        items.append(item)
    }

    package mutating func pop() {
        items.removeLast()
    }

    package func apply(sublist: inout ViewList.Sublist) {
        for item in items.reversed() {
            item.apply(sublist: &sublist)
        }
    }

    package func bindID(_ id: inout ViewList.ID) {
        for item in items.reversed() {
            item.bindID(&id)
        }
    }
}

// MARK: - ViewList.SublistTransform.Item

package protocol _ViewList_SublistTransform_Item {
    func apply(sublist: inout ViewList.Sublist)
    func bindID(_ id: inout ViewList.ID)
}

// MARK: - ViewList.Node

package enum _ViewList_Node {
    case list(any ViewList, Attribute<any ViewList>?)
    case sublist(ViewList.Sublist)
    case group(ViewList.Group)
    case section(ViewList.Section)

    package func count(style: ViewList.IteratorStyle) -> Int {
        switch self {
        case let .list(list, _):
            list.count(style: style)
        case let .sublist(sublist):
            style.applyGranularity(to: sublist.count)
        case let .group(group):
            group.count(style: style)
        case let .section(section):
            section.count(style: style)
        }
    }

    package func estimatedCount(style: ViewList.IteratorStyle) -> Int {
        switch self {
        case let .list(list, _):
            list.estimatedCount(style: style)
        case let .sublist(sublist):
            style.applyGranularity(to: sublist.count)
        case let .group(group):
            group.estimatedCount(style: style)
        case let .section(section):
            section.estimatedCount(style: style)
        }
    }

    @discardableResult
    package func applyNodes(
        from start: inout Int,
        style: ViewList.IteratorStyle,
        transform: inout ViewList.SublistTransform,
        to body: ViewList.ApplyBody
    ) -> Bool {
        switch self {
        case let .list(list, attribute):
            return list.applyNodes(
                from: &start,
                style: style,
                list: attribute,
                transform: &transform,
                to: body
            )
        case let .sublist(sublist):
            let count = style.applyGranularity(to: sublist.count)
            if start >= count {
                start &-= count
                return true
            } else {
                defer { start = 0 }
                return body(&start, style, self, &transform)
            }
        case let .group(group):
            return group.applyNodes(
                from: &start,
                style: style,
                transform: &transform,
                to: body
            )
        case let .section(section):
            if section.isHierarchical {
                let list = section.base.lists[0]
                return list.list.applyNodes(
                    from: &start,
                    style: style,
                    list: list.attribute,
                    transform: &transform,
                    to: body
                )
            } else {
                return section.base.applyNodes(
                    from: &start,
                    style: style,
                    transform: &transform,
                    to: body
                )
            }
        }
    }

    @discardableResult
    package func applyNodes(
        from start: inout Int,
        transform: inout _ViewList_SublistTransform,
        to body: ViewList.ApplyBody
    ) -> Bool {
        applyNodes(
            from: &start,
            style: .init(),
            transform: &transform,
            to: body
        )
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        style: ViewList.IteratorStyle,
        transform: inout ViewList.SublistTransform,
        to body: (ViewList.Sublist) -> Bool
    ) -> Bool {
        switch self {
        case let .list(list, attribute):
            return list.applySublists(
                from: &start,
                style: style,
                list: attribute,
                transform: &transform,
                to: body
            )
        case let .sublist(sublist):
            var sublist = sublist
            let count = style.applyGranularity(to: sublist.count)
            if start >= count {
                start &-= count
                return true
            } else {
                transform.apply(sublist: &sublist)
                defer { start = 0 }
                return body(sublist)
            }
        case let .group(group):
            return group.applyNodes(
                from: &start,
                style: style,
                transform: &transform
            ) { start, style, node, transform in
                node.applySublists(
                    from: &start,
                    style: style,
                    transform: &transform,
                    to: body
                )
            }
        case let .section(section):
            return section.applyNodes(
                from: &start,
                style: style,
                transform: &transform
            ) { start, style, node, info, transform in
                node.applySublists(
                    from: &start,
                    style: style,
                    transform: &transform,
                    to: body
                )
            }
        }
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        transform: inout ViewList.SublistTransform,
        to body: (ViewList.Sublist) -> Bool
    ) -> Bool {
        applySublists(
            from: &start,
            style: .init(),
            transform: &transform,
            to: body
        )
    }

    package func firstOffset<OtherID>(forID id: OtherID, style: ViewList.IteratorStyle) -> Int? where OtherID: Hashable {
        switch self {
        case let .list(list, _):
            list.firstOffset(forID: id, style: style)
        case .sublist:
            nil
        case let .group(group):
            group.firstOffset(forID: id, style: style)
        case let .section(section):
            section.firstOffset(forID: id, style: style)
        }
    }
}

// MARK: - ViewList + Extension [Blocked by ID.Views]

extension ViewList {
    package var isEmpty: Bool { count == 0 }

    package var count: Int {
        count(style: .init())
    }

    package var estimatedCount: Int {
        estimatedCount(style: .init())
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: (Sublist) -> Bool
    ) -> Bool {
        applyNodes(from: &start, style: style, list: list, transform: &transform) { start, style, node, transform in
            node.applySublists(from: &start, style: style, transform: &transform, to: body)
        }
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: (Sublist) -> Bool
    ) -> Bool {
        applySublists(from: &start, style: .init(), list: list, transform: &transform, to: body)
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        to body: (Sublist) -> Bool
    ) -> Bool {
        var transform = SublistTransform()
        return applySublists(from: &start, style: style, list: list, transform: &transform, to: body)
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        list: Attribute<any ViewList>?,
        to body: (Sublist) -> Bool
    ) -> Bool {
        applySublists(from: &start, style: .init(), list: list, to: body)
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        style: IteratorStyle,
        to body: (Sublist) -> Bool
    ) -> Bool {
        applySublists(from: &start, style: style, list: nil, to: body)
    }

    @discardableResult
    package func applySublists(
        from start: inout Int,
        to body: (Sublist) -> Bool
    ) -> Bool {
        applySublists(from: &start, style: .init(), list: nil, to: body)
    }

    package var allViewIDs: ID.Views {
        if let viewIDs {
            return viewIDs
        } else {
            var start = 0
            let result = applySublists(from: &start, style: .init(), list: nil) { sublist in
                // sublist.elements append
                true
            }
            openSwiftUIUnimplementedFailure()
        }
    }

    package func applyIDs(
        from start: inout Int,
        style: IteratorStyle,
        listAttribute: Attribute<any ViewList>?,
        transform: inout ViewList.SublistTransform,
        to body: (ViewList.ID) -> Bool
    ) -> Bool {
        openSwiftUIUnimplementedFailure()
    }

    package func applyIDs(
        from start: inout Int,
        listAttribute: Attribute<any ViewList>?,
        transform t: inout ViewList.SublistTransform,
        to body: (ViewList.ID) -> Bool
    ) -> Bool {
        openSwiftUIUnimplementedFailure()
    }

    package func applyIDs(
        from start: inout Int,
        listAttribute: Attribute<any ViewList>?,
        to body: (ViewList.ID) -> Bool
    ) -> Bool {
        openSwiftUIUnimplementedFailure()
    }

    package func applyIDs(
        from start: inout Int,
        transform t: inout ViewList.SublistTransform,
        to body: (ViewList.ID) -> Bool
    ) -> Bool {
        openSwiftUIUnimplementedFailure()
    }

    package func firstOffset(of id: ViewList.ID.Canonical, style: IteratorStyle) -> Int? {
        openSwiftUIUnimplementedFailure()
    }

    package func firstOffset(of id: ViewList.ID.Canonical) -> Int? {
        firstOffset(of: id, style: .init())
    }
}

// MARK: - ViewList.Elements

package protocol _ViewList_Elements {
    typealias Body = (_ViewInputs, @escaping MakeElement) -> (_ViewOutputs?, Bool)
    typealias MakeElement = (_ViewInputs) -> _ViewOutputs
    typealias Release = _ViewList_ReleaseElements

    var count: Int { get }

    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool)

    func tryToReuseElement(
        at index: Int,
        by other: any ViewList.Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool

    func retain() -> Release?
}

extension ViewList.Elements {
    @inline(__always)
    package func makeAllElements(
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: (_ViewInputs, @escaping MakeElement) -> _ViewOutputs?
    ) -> _ViewOutputs? {
        withoutActuallyEscaping(body) { escapingBody in
            let wrapper: Body = { inputs, makeElement in
                (escapingBody(inputs, makeElement), true)
            }
            var start = 0
            return makeElements(from: &start, inputs: inputs, indirectMap: indirectMap, body: wrapper).0
        }
    }

    @inline(__always)
    package func makeAllElements(
        inputs: _ViewInputs,
        body: (_ViewInputs, @escaping MakeElement) -> _ViewOutputs?
    ) -> _ViewOutputs? {
        makeAllElements(inputs: inputs, indirectMap: nil, body: body)
    }

    @inline(__always)
    package func makeOneElement(
        at index: Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: (_ViewInputs, @escaping MakeElement) -> _ViewOutputs?
    ) -> _ViewOutputs? {
        withoutActuallyEscaping(body) { escapingBody in
            let wrapper: Body = { inputs, makeElement in
                (escapingBody(inputs, makeElement), false)
            }
            var start = index
            return makeElements(from: &start, inputs: inputs, indirectMap: indirectMap, body: wrapper).0
        }
    }

    @inline(__always)
    package func makeOneElement(
        at index: Int,
        inputs: _ViewInputs,
        body: (_ViewInputs, @escaping MakeElement) -> _ViewOutputs?
    ) -> _ViewOutputs? {
        makeOneElement(at: index, inputs: inputs, indirectMap: nil, body: body)
    }

    package func retain() -> Release? {
        nil
    }
}

// MARK: - ViewList.ID

@_spi(ForOpenSwiftUIOnly)
public struct _ViewList_ID: Hashable {
    package typealias Views = _ViewList_ID_Views

    private var _index: Int32

    package var index: Int {
        get { Int(_index) }
        set { _index = Int32(newValue) }
    }

    private var implicitID: Int32

    private var explicitIDs: [Explicit]

    package init(implicitID: Int) {
        self._index = 0
        self.implicitID = Int32(implicitID)
        self.explicitIDs = []
    }

    package init() {
        self._index = 0
        self.implicitID = 0
        self.explicitIDs = []
    }

    private struct Explicit: Equatable {
        let id: AnyHashable2
        let reuseID: Int
        let owner: AnyAttribute
        let isUnary: Bool
    }

    package static func explicit<ID>(_ id: ID, owner: AnyAttribute) -> ViewList.ID where ID: Hashable {
        var viewListID = ViewList.ID()
        viewListID.bind(explicitID: id, owner: owner, isUnary: true, reuseID: .zero)
        return viewListID
    }

    package static func explicit<ID>(_ id: ID) -> ViewList.ID where ID: Hashable {
        explicit(id, owner: .nil)
    }

    package func elementID(at index: Int) -> ViewList.ID {
        var id = self
        id.index = index
        return id
    }

    package struct Canonical: Hashable, CustomStringConvertible {
        private var _index: Int32

        package var index: Int {
            get { Int(_index) }
            set { _index = Int32(newValue) }
        }

        private var implicitID: Int32

        package var explicitID: AnyHashable2?

        init(_index: Int32, implicitID: Int32, explicitID: AnyHashable2?) {
            self._index = _index
            self.implicitID = implicitID
            self.explicitID = explicitID
        }

        package var requiresImplicitID: Bool { implicitID >= 0 }

        package var description: String {
            if let explicitID {
                explicitID.description
            } else {
                "@\(_index)"
            }
        }
    }

    package var canonicalID: Canonical {
        guard let explicitID = explicitIDs.first else {
            return Canonical(_index: _index, implicitID: implicitID, explicitID: nil)
        }
        return Canonical(_index: _index, implicitID: explicitID.isUnary ? -1 : implicitID, explicitID: explicitID.id)
    }

    package struct ElementCollection: RandomAccessCollection, Equatable {
        package var id: ViewList.ID
        package var count: Int

        package init(id: ViewList.ID, count: Int) {
            self.id = id
            self.count = count
        }

        package var startIndex: Int { .zero }
        package var endIndex: Int { count }

        package subscript(index: Int) -> ViewList.ID {
            id.elementID(at: index)
        }
    }

    package func elementIDs(count: Int) -> ElementCollection {
        ElementCollection(id: self, count: count)
    }

    package mutating func bind<ID>(explicitID: ID, owner: AnyAttribute, isUnary: Bool, reuseID: Int) where ID: Hashable {
        explicitIDs.append(Explicit(id: AnyHashable2(explicitID), reuseID: reuseID, owner: owner, isUnary: isUnary))
    }

    package mutating func bind<ID>(explicitID: ID, owner: AnyAttribute, reuseID: Int) where ID: Hashable {
        bind(explicitID: explicitID, owner: owner, isUnary: false, reuseID: reuseID)
    }

    package mutating func bind<ID>(explicitID: ID, owner: AnyAttribute, isUnary: Bool) where ID: Hashable {
        bind(explicitID: explicitID, owner: owner, isUnary: isUnary, reuseID: .zero)
    }

    package mutating func bind<ID>(explicitID: ID, owner: AnyAttribute) where ID: Hashable {
        bind(explicitID: explicitID, owner: owner, isUnary: false, reuseID: .zero)
    }

    package var primaryExplicitID: AnyHashable2? { explicitIDs.first?.id }

    package var allExplicitIDs: [AnyHashable2] { explicitIDs.map(\.id) }

    package func explicitID<ID>(owner: AnyAttribute) -> ID? where ID: Hashable {
        for explicitID in explicitIDs {
            guard explicitID.owner == owner,
                  let id = explicitID.id.as(type: ID.self)
            else { continue }
            return id
        }
        return nil
    }

    package func explicitID<ID>(for idType: ID.Type) -> ID? where ID: Hashable {
        for explicitID in explicitIDs {
            guard let id = explicitID.id.as(type: ID.self)
            else { continue }
            return id
        }
        return nil
    }

    package func containsID<ID>(_ id: ID) -> Bool where ID: Hashable {
        for explicitID in explicitIDs {
            guard explicitID.id.as(type: ID.self) == id
            else { continue }
            return true
        }
        return false
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_index)
        hasher.combine(implicitID)
        for explicitID in explicitIDs {
            hasher.combine(explicitID.id)
            hasher.combine(explicitID.owner)
        }
    }

    package var reuseIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(_index)
        hasher.combine(implicitID)
        for explicitID in explicitIDs {
            hasher.combine(explicitID.reuseID)
        }
        return hasher.finalize()
    }

    final package class _Views<Base>: Views where Base: Equatable, Base: RandomAccessCollection, Base.Element == ViewList.ID, Base.Index == Int {
        package let base: Base

        package init(_ base: Base, isDataDependent: Bool) {
            self.base = base
            super.init(isDataDependent: isDataDependent)
        }

        override package var endIndex: Int {
            base.endIndex
        }

        override package subscript(index: Int) -> ViewList.ID {
            base[index]
        }

        override package func isEqual(to other: _ViewList_ID.Views) -> Bool {
            guard let other = other as? Self else { return false }
            return base == other.base
        }
    }

    final package class JoinedViews: Views {
        package let views: [(views: Views, endOffset: Int)]
        package let count: Int

        package init(_ views: [Views], isDataDependent: Bool) {
            var offset = 0
            var result: [(views: Views, endOffset: Int)] = []
            for view in views {
                offset += views.distance(from: 0, to: view.endIndex)
                result.append((view, offset))
            }
            self.views = result
            self.count = offset
            super.init(isDataDependent: isDataDependent)
        }

        override package var endIndex: Int { count }

        override package subscript(index: Int) -> ViewList.ID {
            var index = index
            // Copied from Swift Standard Library's _partitioningIndex(where:) implementation
            var n = views.count
            var l = 0
            while n > 0 {
                let half = n / 2
                let mid = l + half
                if views[mid].endOffset > index {
                    n = half
                } else {
                    l = mid + 1
                    n -= half + 1
                }
            }

            let targetIndex = l
            if targetIndex != 0 {
                index &-= views[targetIndex - 1].endOffset
            }

            let view = views[targetIndex]
            // Copied from Swift Standard Library's _checkIndex(_:) implementation
            Swift.precondition(index >= startIndex, "Negative Array index is out of range")
            Swift.precondition(index <= endIndex, "Array index is out of range")
            return view.views[index]
        }

        override package func isEqual(to other: ViewList.ID.Views) -> Bool {
            guard let other = other as? JoinedViews,
                  count == other.count
            else {
                return false
            }
            guard !views.isEmpty else {
                return true
            }
            for index in views.indices {
                guard views[index].views.isEqual(to: other.views[index].views) else {
                    return false
                }
            }
            return true
        }
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension _ViewList_ID: Sendable {}

// MARK: - ViewList.ID.Views

@_spi(ForOpenSwiftUIOnly)
open class _ViewList_ID_Views: RandomAccessCollection, Equatable {
    final public let isDataDependent: Bool

    final public var startIndex: Int { 0 }

    open var endIndex: Int { openSwiftUIBaseClassAbstractMethod() }

    open subscript(index: Int) -> _ViewList_ID { openSwiftUIBaseClassAbstractMethod() }

    open func isEqual(to other: _ViewList_ID_Views) -> Bool { openSwiftUIBaseClassAbstractMethod() }

    package init(isDataDependent: Bool) {
        self.isDataDependent = isDataDependent
    }

    package func withDataDependency() -> ViewList.ID.Views {
        if isDataDependent {
            self
        } else {
            ViewList.ID._Views(self, isDataDependent: true)
        }
    }

    public static func == (lhs: _ViewList_ID_Views, rhs: _ViewList_ID_Views) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewList.ID.Views: Sendable {}

// MARK: - UnaryViewGenerator

private protocol UnaryViewGenerator {
    func makeView(inputs: _ViewInputs, indirectMap: IndirectAttributeMap?) -> _ViewOutputs
    func tryToReuse(by other: Self, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool
}

private struct BodyUnaryViewGenerator<V>: UnaryViewGenerator {
    let body: ViewList.Elements.MakeElement

    public func makeView(inputs: _ViewInputs, indirectMap: IndirectAttributeMap?) -> _ViewOutputs {
        body(inputs)
    }

    public func tryToReuse(by other: BodyUnaryViewGenerator<V>, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        guard compareValues(body, other.body) else {
            ReuseTrace.traceReuseBodyMismatchedFailure()
            Log.graphReuse("Reuse failed: \(Self.self) failed comparison")
            return false
        }
        return true
    }
}

private struct TypedUnaryViewGenerator<V>: UnaryViewGenerator where V: View {
    let view: WeakAttribute<V>

    func makeView(inputs: _ViewInputs, indirectMap: IndirectAttributeMap?) -> _ViewOutputs {
        guard var view = view.attribute else {
            return .init()
        }
        if let indirectMap {
            view.makeReusable(indirectMap: indirectMap)
        }
        return V.makeDebuggableView(view: _GraphValue(view), inputs: inputs)
    }

    func tryToReuse(by other: TypedUnaryViewGenerator<V>, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        guard let view = view.attribute, let otherView = other.view.attribute else {
            Log.graphReuse("Reuse failed: missing attribute for \(V.self)")
            return false
        }
        return view.tryToReuse(by: otherView, indirectMap: indirectMap, testOnly: testOnly)
    }
}

// MARK: - MergedElements [6.4.41]

private struct MergedElements: ViewList.Elements {
    var outputs: ArraySlice<_ViewListOutputs>

    var count: Int {
        guard !outputs.isEmpty else {
            return 0
        }
        var count = 0
        for output in outputs {
            guard case let .staticList(elements) = output.views else {
                openSwiftUIBaseClassAbstractMethod()
            }
            count += elements.count
        }
        return count
    }

    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: (_ViewInputs, @escaping MakeElement) -> (_ViewOutputs?, Bool)
    ) -> (_ViewOutputs?, Bool) {
        var viewOutputs: [_ViewOutputs] = []
        var shouldContinue = true
        for output in outputs {
            guard case let .staticList(elements) = output.views else {
                openSwiftUIBaseClassAbstractMethod()
            }
            let (elementsOutputs, elementsShouldContinue) = elements.makeElements(
                from: &start,
                inputs: inputs,
                indirectMap: indirectMap,
                body: body
            )
            if let elementsOutputs {
                viewOutputs.append(elementsOutputs)
            }
            guard elementsShouldContinue else {
                shouldContinue = false
                break
            }
        }
        let viewOutput: _ViewOutputs?
        switch viewOutputs.count {
        case 1: viewOutput = viewOutputs[0]
        case 0: viewOutput = nil
        default:
            var preferencesOutputs: [PreferencesOutputs] = []
            preferencesOutputs.reserveCapacity(viewOutputs.count)
            for output in viewOutputs {
                preferencesOutputs.append(output.preferences)
            }
            var visitor = MultiPreferenceCombinerVisitor(
                outputs: preferencesOutputs,
                result: PreferencesOutputs()
            )
            for key in inputs.preferences.keys {
                key.visitKey(&visitor)
            }
            var result = _ViewOutputs()
            result.preferences = visitor.result
            viewOutput = result
        }
        return (viewOutput, shouldContinue)
    }

    func tryToReuseElement(
        at index: Int,
        by other: any _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool {
        guard let other = other as? MergedElements else {
            ReuseTrace.traceReuseViewInputsDifferentFailure()
            return false
        }
        guard let (elements, elementsIndex) = findElement(at: index),
              let (otherElements, otherElementsIndex) = other.findElement(at: otherIndex) else {
            ReuseTrace.traceReuseViewInputsDifferentFailure()
            return false
        }
        return elements.tryToReuseElement(
            at: elementsIndex,
            by: otherElements,
            at: otherElementsIndex,
            indirectMap: indirectMap,
            testOnly: testOnly
        )
    }

    func findElement(at index: Int) -> (any ViewList.Elements, Int)? {
        guard !outputs.isEmpty else {
            return nil
        }
        var lowerBound = 0
        for output in outputs {
            guard case let .staticList(elements) = output.views else {
                openSwiftUIBaseClassAbstractMethod()
            }
            let count = elements.count
            let upperBound = lowerBound + count
            let range = lowerBound..<upperBound
            if range.contains(index) {
                return (elements, index - lowerBound)
            }
            lowerBound = upperBound
        }
        return nil
    }
}


// MARK: - UnaryElements [6.4.41] [WIP]

private struct UnaryElements<Generator>: ViewList.Elements where Generator: UnaryViewGenerator {
    var body: Generator
    var baseInputs: _GraphInputs

    init(body: Generator, baseInputs: _GraphInputs) {
        self.body = body
        self.baseInputs = baseInputs
    }

    var count: Int { 1 }

    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool) {
        guard start == 0 else {
            start = max(start - 1, 0)
            return (nil, true)
        }
        let (outputs, shouldContinue) = body(inputs) { inputs in
            var baseInputs = baseInputs
            if let indirectMap {
                baseInputs.makeReusable(indirectMap: indirectMap)
            }
            var inputs = inputs
            inputs.base.merge(baseInputs, ignoringPhase: false)
            return self.body.makeView(inputs: inputs, indirectMap: indirectMap)
        }
        start = 0
        return (outputs, shouldContinue)
    }

    func tryToReuseElement(
        at index: Int,
        by other: any ViewList.Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool {
        guard let other = other as? UnaryElements else {
            Log.graphReuse("Reuse failed: other is not Unary")
            ReuseTrace.traceReuseUnaryElementExpectedFailure(type(of: other))
            return false
        }
        guard !baseInputs.containsNonEmptyBodyStack,
              !other.baseInputs.containsNonEmptyBodyStack else {
            return false
        }
        return body.tryToReuse(
            by: other.body,
            indirectMap: indirectMap,
            testOnly: testOnly
        ) && baseInputs.tryToReuse(
            by: other.baseInputs,
            indirectMap: indirectMap,
            testOnly: testOnly
        )
    }
}

// MARK: - ViewListOutputs + Extension [WIP]

extension _ViewListOutputs {
    private struct ApplyModifiers: Rule, AsyncAttribute {
        @Attribute var base: any ViewList
        let modifier: ListModifier

        var value: any ViewList {
            var value = base
            modifier.apply(to: &value)
            return value
        }
    }

    private static func staticList(
        _ elements: any ViewList.Elements,
        inputs: _ViewListInputs,
        staticCount: Int
    ) -> _ViewListOutputs {
        let implicitID = inputs.implicitID
        let scope = inputs.base.stableIDScope
        let traits = inputs.traits
        let canTransition = inputs.canTransition
        let views: Views
        if scope != nil || traits != nil || canTransition {
            views = .dynamicList(
                Attribute(BaseViewList.Init(
                    elements: elements,
                    implicitID: implicitID,
                    canTransition: canTransition,
                    stableIDScope: scope,
                    traitKeys: inputs.traitKeys,
                    traits: .init(traits)
                )),
                nil
            )
        } else {
            views = .staticList(elements)
        }
        return _ViewListOutputs(
            views,
            nextImplicitID: implicitID &+ staticCount,
            staticCount: staticCount
        )
    }

    // FIXME: Group
    package static func nonEmptyParentViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        openSwiftUIUnimplementedFailure()
    }

    package static func unaryViewList<V>(view: _GraphValue<V>, inputs: _ViewListInputs) -> _ViewListOutputs where V: View {
        let generator = TypedUnaryViewGenerator(view: .init(view.value))
        let elements = UnaryElements(body: generator, baseInputs: inputs.base)
        return staticList(elements, inputs: inputs, staticCount: 1)
    }

    package static func unaryViewList<T>(viewType: T.Type = T.self, inputs: _ViewListInputs, body: @escaping ViewList.Elements.MakeElement) -> _ViewListOutputs {
        let generator = BodyUnaryViewGenerator<T>(body: body)
        let elements = UnaryElements(body: generator, baseInputs: inputs.base)
        return staticList(elements, inputs: inputs, staticCount: 1)
    }

    package static func emptyViewList(inputs: _ViewListInputs) -> _ViewListOutputs {
        if inputs.options.contains(.isNonEmptyParent) {
            nonEmptyParentViewList(inputs: inputs)
        } else {
            staticList(EmptyViewListElements(), inputs: inputs, staticCount: 0)
        }
    }

    package func makeAttribute(inputs: _ViewListInputs) -> Attribute<any ViewList> {
        switch views {
        case let .staticList(elements):
            Attribute(value: BaseViewList(
                elements: elements,
                implicitID: nextImplicitID,
                canTransition: inputs.canTransition,
                stableIDScope: inputs.base.stableIDScope,
                traitKeys: .init(),
                traits: .init()
            ))
        case let .dynamicList(attribute, modifier):
            if let modifier {
                Attribute(ApplyModifiers(base: attribute, modifier: modifier))
            } else {
                attribute
            }
        }
    }

    package func makeAttribute(viewInputs: _ViewInputs) -> Attribute<any ViewList> {
        switch views {
        case let .staticList(elements):
            Attribute(value: BaseViewList(
                elements: elements,
                implicitID: nextImplicitID,
                canTransition: false,
                stableIDScope: viewInputs.base.stableIDScope,
                traitKeys: .init(),
                traits: .init()
            ))
        case let .dynamicList(attribute, modifier):
            if let modifier {
                Attribute(ApplyModifiers(base: attribute, modifier: modifier))
            } else {
                attribute
            }
        }
    }

    package static func makeModifiedList(list: Attribute<any ViewList>, modifier: ListModifier?) -> Attribute<any ViewList> {
        if let modifier {
            Attribute(ApplyModifiers(base: list, modifier: modifier))
        } else {
            list
        }
    }

    package mutating func multiModifier<T>(_ modifier: _GraphValue<T>, inputs: _ViewListInputs) where T: ViewModifier {
        switch views {
        case let .staticList(elements):
            views = .staticList(ModifiedElements(base: elements, modifier: WeakAttribute(modifier.value), baseInputs: inputs.base))
        case .dynamicList(_, _):
            openSwiftUIUnimplementedFailure()
        }
    }

    // MARK: - _ViewListOutputs.concat [6.4.41]

    package static func concat(_ outputs: [_ViewListOutputs], inputs: _ViewListInputs) -> _ViewListOutputs {
        func mergeStatic(from startIndex: Int, to endIndex: Int) -> _ViewListOutputs {
            let count = endIndex - startIndex
            let elements: any ViewList.Elements
            let staticCount: Int?
            switch count {
            case 1:
                let output = outputs[startIndex]
                guard case let .staticList(viewElements) = output.views else {
                    openSwiftUIBaseClassAbstractMethod()
                }
                elements = viewElements
                staticCount = output.staticCount
            case 0:
                elements = EmptyViewListElements()
                staticCount = 0
            default:
                elements = MergedElements(outputs: outputs[startIndex..<endIndex])
                var count: Int? = 0
                for output in outputs[startIndex..<endIndex] {
                    guard let oldCount = count, let staticCount = output.staticCount else {
                        count = nil
                        break
                    }
                    count = oldCount + staticCount
                }
                staticCount = count
            }
            let baseViewList = BaseViewList(
                elements: elements,
                implicitID: implicitID,
                canTransition: inputs.canTransition,
                stableIDScope: inputs.base.stableIDScope,
                traitKeys: ViewTraitKeys(),
                traits: ViewTraitCollection()
            )
            let baseViewListAttribute: Attribute<any ViewList> = Attribute(value: baseViewList)
            implicitID &+= 1
            return _ViewListOutputs(
                .dynamicList(baseViewListAttribute, nil),
                nextImplicitID: implicitID,
                staticCount: staticCount
            )
        }

        guard !outputs.isEmpty else {
            return .init(.staticList(EmptyViewListElements()), nextImplicitID: inputs.implicitID, staticCount: 0)
        }
        var implicitID = inputs.implicitID

        var dynamicListAttributes: [Attribute<any ViewList>] = []
        var fromIndex = 0
        var mergedStaticCount: Int? = 0
        for (index, output) in outputs.enumerated() {
            if let staticCount = output.staticCount {
                mergedStaticCount = (mergedStaticCount ?? 0) + staticCount
            } else {
                mergedStaticCount = nil
            }
            guard case .dynamicList = output.views else {
                continue
            }
            if fromIndex < index {
                let mergedOutput = mergeStatic(from: fromIndex, to: index)
                dynamicListAttributes.append(mergedOutput.makeAttribute(inputs: inputs))
            }
            dynamicListAttributes.append(output.makeAttribute(inputs: inputs))
            fromIndex = index &+ 1
        }
        if fromIndex < outputs.count {
            guard fromIndex != 0 else {
                return if outputs.count == 1 {
                    outputs[0]
                } else {
                    _ViewListOutputs(
                        .staticList(MergedElements(outputs: ArraySlice(outputs))),
                        nextImplicitID: implicitID,
                        staticCount: mergedStaticCount
                    )
                }
            }
            let mergedOutput = mergeStatic(from: fromIndex, to: outputs.count)
            dynamicListAttributes.append(mergedOutput.makeAttribute(inputs: inputs))
        }
        return switch dynamicListAttributes.count {
        case 1: _ViewListOutputs(
            .dynamicList(dynamicListAttributes[0], nil),
            nextImplicitID: implicitID,
            staticCount: mergedStaticCount
        )
        case 0: emptyViewList(inputs: inputs)
        default: _ViewListOutputs(
            .dynamicList(Attribute(ViewList.Group.Init(lists: dynamicListAttributes)), nil),
            nextImplicitID: implicitID,
            staticCount: mergedStaticCount
        )
        }
    }
}

// MARK: - ModifiedElements [6.4.41]

private struct ModifiedElements<Modifier>: ViewList.Elements where Modifier: ViewModifier {
    let base: any ViewList.Elements

    let modifier: WeakAttribute<Modifier>

    let baseInputs: _GraphInputs

    var count: Int {
        base.count
    }

    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: (_ViewInputs, @escaping MakeElement) -> (_ViewOutputs?, Bool)
    ) -> (_ViewOutputs?, Bool) {
        withoutActuallyEscaping(body) { escapingBody in
            base.makeElements(
                from: &start,
                inputs: inputs,
                indirectMap: indirectMap,
            ) {
                makeElementsInputs,
                makeElementsBody in
                escapingBody(makeElementsInputs) { bodyInputs in
                    var base = baseInputs
                    if let indirectMap {
                        base.makeReusable(indirectMap: indirectMap)
                    }
                    var inputs = bodyInputs
                    inputs.base.merge(base)
                    guard var modifier = modifier.attribute else {
                        return _ViewOutputs()
                    }
                    if let indirectMap {
                        modifier.makeReusable(indirectMap: indirectMap)
                    }
                    return Modifier.makeDebuggableView(
                        modifier: _GraphValue(modifier),
                        inputs: inputs
                    ) { _, modifierInputs in
                        makeElementsBody(modifierInputs)
                    }
                }
            }
        }
    }

    func tryToReuseElement(
        at index: Int,
        by other: any _ViewList_Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool {
        guard let other = other as? ModifiedElements,
              let modifier = modifier.attribute, let otherModifier = other.modifier.attribute,
              modifier.tryToReuse(by: otherModifier, indirectMap: indirectMap, testOnly: testOnly),
              baseInputs.tryToReuse(by: other.baseInputs, indirectMap: indirectMap, testOnly: testOnly)
        else {
            ReuseTrace.traceReuseIncompatibleListsFailure(ViewList.self, type(of: other))
            return false
        }
        return base.tryToReuseElement(at: index, by: other.base, at: otherIndex, indirectMap: indirectMap, testOnly: testOnly)
    }

    func retain() -> Release? {
        base.retain()
    }
}

// MARK: - BaseViewList [6.4.41]

private struct BaseViewList: ViewList {
    var elements: any Elements
    var implicitID: Int
    var traitKeys: ViewTraitKeys?
    var traits: ViewTraitCollection

    init(
        elements: any Elements,
        implicitID: Int,
        canTransition: Bool,
        stableIDScope: WeakAttribute<DisplayList.StableIdentityScope>?,
        traitKeys: ViewTraitKeys?,
        traits: ViewTraitCollection
    ) {
        self.elements = elements
        self.implicitID = implicitID
        self.traitKeys = traitKeys
        self.traits = traits
        if canTransition {
            self.traits.canTransition = true
        }
        if let stableIDScope {
            self.traits[DisplayList.StableIdentityScope.self] = stableIDScope
        }
    }

    func count(style: IteratorStyle) -> Int {
        style.applyGranularity(to: elements.count)
    }

    func estimatedCount(style: IteratorStyle) -> Int {
        style.applyGranularity(to: elements.count)
    }

    var viewIDs: ID.Views? {
        ID._Views(
            ID.ElementCollection(
                id: ID(implicitID: implicitID),
                count: elements.count
            ),
            isDataDependent: false
        )
    }

    func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        let count = count(style: style)
        guard start < count else {
            start -= count
            return true
        }
        let sublist = Sublist(
            start: start,
            count: count,
            id: ViewList.ID(implicitID: implicitID),
            elements: elements,
            traits: traits,
            list: list
        )
        defer { start = 0 }
        return body(&start, style, .sublist(sublist), &transform)
    }

    func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
        nil
    }

    func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
        nil
    }

    struct Init: Rule, AsyncAttribute, CustomStringConvertible {
        let elements: any Elements
        let implicitID: Int
        let canTransition: Bool
        let stableIDScope: WeakAttribute<DisplayList.StableIdentityScope>?
        let traitKeys: ViewTraitKeys?
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: any ViewList {
            BaseViewList(
                elements: elements,
                implicitID: implicitID,
                canTransition: canTransition,
                stableIDScope: stableIDScope,
                traitKeys: traitKeys,
                traits: traits ?? .init()
            )
        }

        var description: String {
            "Elements [\(elements.count)]"
        }
    }
}

// MARK: - EmptyViewList

package struct EmptyViewList: ViewList {
    package init() {}

    package func count(style: IteratorStyle) -> Int { .zero }

    package func estimatedCount(style: IteratorStyle) -> Int { .zero }

    package var traitKeys: ViewTraitKeys? { .init() }

    package var viewIDs: ID.Views? { .init(isDataDependent: false) }

    package var traits: Traits { .init() }

    package func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        true
    }

    package func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
        nil
    }

    package func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
        nil
    }
}

// MARK: - EmptyViewListElements

package struct EmptyViewListElements: ViewList.Elements {
    package init() {}

    package var count: Int { 0 }

    package func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool) {
        return (nil, true)
    }

    package func tryToReuseElement(
        at index: Int,
        by other: any ViewList.Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool {
        guard other is EmptyViewListElements else {
            Log.graphReuse("Reuse failed: other is not Empty")
            return false
        }
        return true
    }
}

// MARK: - ViewListSlice

package struct ViewListSlice: ViewList {
    let base: any ViewList
    let bounds: Range<Int>

    package var traitKeys: ViewTraitKeys? { nil }

    package var traits: Traits { .init() }

    final class ViewIDsSlice: ID.Views {
        let base: ID.Views
        let bounds: Range<Int>

        init?(base: ID.Views?, bounds: Range<Int>) {
            guard let base else {
                return nil
            }
            self.base = base
            self.bounds = bounds
            super.init(isDataDependent: base.isDataDependent)
        }

        override var endIndex: Int { bounds.count }

        override subscript(index: Int) -> ID {
            base[index + bounds.lowerBound]
        }
    }

    package var viewIDs: ID.Views? {
        ViewIDsSlice(base: base.viewIDs, bounds: bounds)
    }

    package init(base: any ViewList, bounds: Range<Int>) {
        self.base = base
        self.bounds = bounds
    }

    package func count(style: IteratorStyle) -> Int {
        bounds.count
    }

    package func estimatedCount(style: IteratorStyle) -> Int {
        bounds.count
    }

    package func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        var start = bounds.lowerBound + start
        return base.applyNodes(
            from: &start,
            style: style,
            list: list,
            transform: &transform
        ) { start, style, node, transform in
            guard start < bounds.upperBound else {
                return false
            }
            return body(&start, style, node, &transform)
        }
    }

    package func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
        base.edit(forID: id, since: transaction)
    }

    package func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
        guard let offset = base.firstOffset(forID: id, style: style) else {
            return nil
        }
        return offset - bounds.lowerBound
    }
}

// MARK: - ViewList.Group

package struct _ViewList_Group: ViewList {
    package typealias AttributedList = (list: any ViewList, attribute: Attribute<any ViewList>)

    package var lists: [AttributedList]

    package func count(style: IteratorStyle) -> Int {
        lists.reduce(0) { $0 + $1.list.count(style: style) }
    }

    package func estimatedCount(style: IteratorStyle) -> Int {
        lists.reduce(0) { $0 + $1.list.estimatedCount(style: style) }
    }

    package var traits: Traits { .init() }

    package var traitKeys: ViewTraitKeys? {
        var traitKeys = ViewTraitKeys()
        for (list, _) in lists {
            guard let keys = list.traitKeys else {
                return nil
            }
            traitKeys.formUnion(keys)
        }
        return traitKeys
    }

    package var viewIDs: ID.Views? {
        var views: [ID.Views] = []
        var isDataDependent = false
        for (list, _) in lists {
            guard let ids = list.viewIDs else {
                return nil
            }
            views.append(ids)
            isDataDependent = isDataDependent || ids.isDataDependent
        }
        return ViewList.ID.JoinedViews(views, isDataDependent: isDataDependent)
    }

    package func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        body(&start, style, .group(self), &transform)
    }

    package func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        for (list, attribute) in lists {
            guard list.applyNodes(
                from: &start,
                style: style,
                list: attribute,
                transform: &transform,
                to: body
            ) else {
                return false
            }
        }
        return true
    }

    package func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
        for (list, _) in lists {
            guard let edit = list.edit(forID: id, since: transaction) else {
                continue
            }
            return edit
        }
        return nil
    }

    package func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
        var previousCount = 0
        for (list, _) in lists {
            guard let offset = list.firstOffset(forID: id, style: style) else {
                previousCount += list.count(style: style)
                continue
            }
            return previousCount + offset
        }
        return nil
    }

    package struct Init: Rule, AsyncAttribute, CustomStringConvertible {
        var lists: [Attribute<any ViewList>]

        package var value: any ViewList {
            _ViewList_Group(lists: lists.map { ($0.value, $0) })
        }

        package var description: String { "∪" }
    }
}

// MARK: - ViewList.Section

package struct _ViewList_Section: ViewList {
    package var id: UInt32
    package var base: ViewList.Group
    package var traits: ViewList.Traits
    package var isHierarchical: Bool

    package var header: ViewList.Group.AttributedList {
        base.lists[0]
    }

    package var content: ViewList.Group.AttributedList {
        base.lists[1]
    }

    package var footer: ViewList.Group.AttributedList {
        base.lists[2]
    }

    package var traitKeys: ViewTraitKeys? {
        base.traitKeys
    }

    package var viewIDs: ID.Views? {
        if isHierarchical {
            header.list.viewIDs
        } else {
            base.viewIDs
        }
    }

    @inline(__always)
    package func headerFooterStyle(for style: IteratorStyle) -> IteratorStyle {
        var style = style
        style.applyGranularity = (style.granularity != 1)
        return style
    }

    package func count(style: IteratorStyle) -> Int {
        if isHierarchical {
            var style = style
            style.applyGranularity = (style.granularity != 1)
            return header.list.count(style: style)
        } else {
            var contentCount = content.list.count(style: style)
            style.alignToNextGranularityMultiple(&contentCount)
            let headerFooterStyle = headerFooterStyle(for: style)
            let headerCount = header.list.count(style: headerFooterStyle)
            let footerCount = footer.list.count(style: headerFooterStyle)
            return contentCount + headerCount + footerCount
        }
    }

    package func estimatedCount(style: IteratorStyle) -> Int {
        if isHierarchical {
            var style = style
            style.applyGranularity = (style.granularity != 1)
            return header.list.estimatedCount(style: style)
        } else {
            var contentEstimatedCount = content.list.estimatedCount(style: style)
            style.alignToNextGranularityMultiple(&contentEstimatedCount)
            let headerFooterStyle = headerFooterStyle(for: style)
            let headerEstimatedCount = header.list.estimatedCount(style: headerFooterStyle)
            let footerEstimatedCount = footer.list.estimatedCount(style: headerFooterStyle)
            return contentEstimatedCount + headerEstimatedCount + footerEstimatedCount
        }
    }

    package func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        body(&start, style, .section(self), &transform)
    }

    package struct Info {
        package var id: UInt32
        package var isHeader: Bool
        package var isFooter: Bool
    }

    package func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        transform: inout SublistTransform,
        to body: (inout Int, IteratorStyle, Node, Info, inout SublistTransform) -> Bool
    ) -> Bool {
        style.alignToPreviousGranularityMultiple(&start)
        let range = (0 ..< base.lists.count).prefix(isHierarchical ? 1 : .max)
        let headerFooterStyle = headerFooterStyle(for: style)
        for index in range {
            let (list, attribute) = base.lists[index]
            let result = list.applyNodes(
                from: &start,
                style: index == 1 ? style : headerFooterStyle,
                list: attribute,
                transform: &transform
            ) { start, style, node, transform in
                body(
                    &start,
                    style,
                    node,
                    Info(id: id, isHeader: index == 0, isFooter: index == 2),
                    &transform
                )
            }
            guard result else {
                return false
            }
            style.alignToNextGranularityMultiple(&start)
        }
        return true
    }

    package func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
        base.edit(forID: id, since: transaction)
    }

    package func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
        let range = (0 ..< base.lists.count).prefix(isHierarchical ? 1 : .max)
        let headerFooterStyle = headerFooterStyle(for: style)
        var previousCount = 0
        for index in range {
            let (list, _) = base.lists[index]
            let currentStyle = index == 1 ? style : headerFooterStyle
            guard let offset = list.firstOffset(
                forID: id,
                style: currentStyle
            ) else {
                var count = list.count(style: currentStyle)
                style.alignToNextGranularityMultiple(&count)
                previousCount += count
                continue
            }
            return previousCount + offset
        }
        return nil
    }
}

// MARK: - ViewList.Subgraph

@_spi(ForOpenSwiftUIOnly)
open class _ViewList_Subgraph {
    final package let subgraph: Subgraph
    private(set) final package var refcount: UInt32

    package init(subgraph: Subgraph) {
        self.subgraph = subgraph
        self.refcount = 1
    }

    final package func wrapping(_ base: any ViewList.Elements) -> any ViewList.Elements {
        SubgraphElements(base: base, subgraph: self)
    }

    final package func wrapping(_ list: any ViewList) -> any ViewList {
        SubgraphList(base: list, subgraph: self)
    }

    open func invalidate() {}

    @inline(__always)
    final var isValid: Bool {
        guard refcount != 0 else {
            return false
        }
        return subgraph.isValid
    }

    @inline(__always)
    final func retain() {
        refcount &+= 1
    }

    @inline(__always)
    final func invalidate(isInserted: Bool) {
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

    @inline(__always)
    final func remove(from parent: Subgraph) {
        if isValid {
            subgraph.willRemove()
            parent.removeChild(subgraph)
        }
        invalidate(isInserted: false)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewList.Subgraph: Sendable {}

private struct SubgraphElements: ViewList.Elements {
    let base: any ViewList.Elements
    let subgraph: ViewList.Subgraph

    var count: Int { base.count }

    func makeElements(
        from start: inout Int,
        inputs: _ViewInputs,
        indirectMap: IndirectAttributeMap?,
        body: Body
    ) -> (_ViewOutputs?, Bool) {
        guard subgraph.isValid else {
            return (nil, true)
        }
        return base.makeElements(from: &start, inputs: inputs, indirectMap: indirectMap, body: body)
    }

    func tryToReuseElement(
        at index: Int,
        by other: any ViewList.Elements,
        at otherIndex: Int,
        indirectMap: IndirectAttributeMap,
        testOnly: Bool
    ) -> Bool {
        guard let otherSubgraphElement = other as? SubgraphElements,
              otherSubgraphElement.subgraph.isValid
        else {
            ReuseTrace.traceReuseInvalidSubgraphFailure(type(of: other))
            return false
        }
        return base.tryToReuseElement(
            at: index,
            by: otherSubgraphElement.base,
            at: otherIndex,
            indirectMap: indirectMap,
            testOnly: testOnly
        )
    }

    func retain() -> Release? {
        guard subgraph.isValid else {
            return nil
        }
        return Release(base: base.retain(), subgraph: subgraph)
    }
}

private struct SubgraphList: ViewList {
    var base: any ViewList
    var subgraph: ViewList.Subgraph

    func count(style: IteratorStyle) -> Int {
        base.count(style: style)
    }

    func estimatedCount(style: IteratorStyle) -> Int {
        base.estimatedCount(style: style)
    }

    var traitKeys: ViewTraitKeys? {
        base.traitKeys
    }

    var viewIDs: ID.Views? {
        base.viewIDs
    }

    var traits: ViewTraitCollection {
        base.traits
    }

    func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        transform.push(Transform(subgraph: subgraph))
        defer { transform.pop() }
        return base.applyNodes(from: &start, style: style, list: list, transform: &transform, to: body)
    }

    func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
        base.edit(forID: id, since: transaction)
    }

    func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
        base.firstOffset(forID: id, style: style)
    }

    struct Transform: ViewList.SublistTransform.Item {
        var subgraph: ViewList.Subgraph

        func apply(sublist: inout ViewList.Sublist) {
            sublist.elements = SubgraphElements(base: sublist.elements, subgraph: subgraph)
        }

        func bindID(_ id: inout ViewList.ID) {}
    }
}

// MARK: - ViewList.Elements.Release

final package class _ViewList_ReleaseElements: Equatable {
    var base: ViewList.Elements.Release?
    var subgraph: ViewList.Subgraph

    init(base: ViewList.Elements.Release?, subgraph: ViewList.Subgraph) {
        self.base = base
        self.subgraph = subgraph
    }

    deinit {
        Update.ensure {
            subgraph.invalidate(isInserted: true)
        }
    }

    package static func == (lhs: ViewList.Elements.Release, rhs: ViewList.Elements.Release) -> Bool {
        guard lhs.subgraph === rhs.subgraph else {
            return false
        }
        guard let lhsBase = lhs.base, let rhsBase = rhs.base else {
            return lhs.base == nil && rhs.base == nil
        }
        return lhsBase == rhsBase
    }
}
