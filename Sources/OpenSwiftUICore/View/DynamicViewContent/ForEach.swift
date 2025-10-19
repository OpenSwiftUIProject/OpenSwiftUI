//
//  ForEach.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 1A3DD35AB7F6976908CD7AF959F34D1F (SwiftUICore)

import Foundation
package import OpenAttributeGraphShims

// MARK: - ForEach

/// A structure that computes views on demand from an underlying collection of
/// identified data.
///
/// Use `ForEach` to provide views based on a
/// [RandomAccessCollection](https://developer.apple.com/documentation/swift/randomaccesscollection)
/// of some data type. Either the collection's elements must conform to
/// [Identifiable](https://developer.apple.com/documentation/swift/identifiable) or you
/// need to provide an `id` parameter to the `ForEach` initializer.
///
/// The following example creates a `NamedFont` type that conforms to
/// [Identifiable](https://developer.apple.com/documentation/swift/identifiable), and an
/// array of this type called `namedFonts`. A `ForEach` instance iterates
/// over the array, producing new ``Text`` instances that display examples
/// of each OpenSwiftUI ``Font`` style provided in the array.
///
///     private struct NamedFont: Identifiable {
///         let name: String
///         let font: Font
///         var id: String { name }
///     }
///
///     private let namedFonts: [NamedFont] = [
///         NamedFont(name: "Large Title", font: .largeTitle),
///         NamedFont(name: "Title", font: .title),
///         NamedFont(name: "Headline", font: .headline),
///         NamedFont(name: "Body", font: .body),
///         NamedFont(name: "Caption", font: .caption)
///     ]
///
///     var body: some View {
///         ForEach(namedFonts) { namedFont in
///             Text(namedFont.name)
///                 .font(namedFont.font)
///         }
///     }
///
/// ![A vertically arranged stack of labels showing various standard fonts,
/// such as Large Title and Headline.](OpenSwiftUI-ForEach-fonts.png)
///
/// Some containers like ``List`` or ``LazyVStack`` will query the elements
/// within a for each lazily. To obtain maximal performance, ensure that
/// the view created from each element in the collection represents a
/// constant number of views.
///
/// For example, the following view uses an if statement which means each
/// element of the collection can represent either 1 or 0 views, a
/// non-constant number.
///
///     ForEach(namedFonts) { namedFont in
///         if namedFont.name.count != 2 {
///             Text(namedFont.name)
///         }
///     }
///
/// You can make the above view represent a constant number of views by
/// wrapping the condition in a ``VStack``, an ``HStack``, or a ``ZStack``.
///
///     ForEach(namedFonts) { namedFont in
///         VStack {
///             if namedFont.name.count != 2 {
///                 Text(namedFont.name)
///             }
///         }
///     }
///
/// When enabling the following launch argument, OpenSwiftUI will log when
/// it encounters a view that produces a non-constant number of views
/// in these containers:
///
///     -LogForEachSlowPath YES
///
@available(OpenSwiftUI_v1_0, *)
public struct ForEach<Data, ID, Content> where Data: RandomAccessCollection, ID: Hashable {

    /// The collection of underlying identified data that OpenSwiftUI uses to create
    /// views dynamically.
    public var data: Data

    /// A function to create content on demand using the underlying data.
    public var content: (Data.Element) -> Content

    package enum IDGenerator {
        case keyPath(KeyPath<Data.Element, ID>)
        case offset

        package var isConstant: Bool {
            switch self {
            case .keyPath: false
            case .offset: true
            }
        }

        package func makeID(data: Data, index: Data.Index, offset: Int) -> ID {
            switch self {
            case let .keyPath(keyPath): data[index][keyPath: keyPath]
            case .offset: unsafeBitCast(offset, to: ID.self)
            }
        }
    }

    package var idGenerator: IDGenerator

    package var reuseID: KeyPath<Data.Element, Int>?

    var obsoleteContentID: Int

    package init(
        _ data: Data,
        idGenerator: IDGenerator,
        content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.idGenerator = idGenerator
        self.content = content
        self.obsoleteContentID = isLinkedOnOrAfter(.v6) ? .zero : UniqueID().value
    }

    package init<T>(
        _ other: ForEach<Data, ID, T>,
        transform: @escaping (T) -> Content
    ) {
        self.data = other.data
        self.idGenerator = switch other.idGenerator {
        case let .keyPath(keyPath): .keyPath(keyPath)
        case .offset: .offset
        }
        self.content = { element in
            transform(other.content(element))
        }
        self.obsoleteContentID = other.obsoleteContentID
    }
}

@available(*, unavailable)
extension ForEach: Sendable {}

// MARK: - ForEach + View [WIP]

@available(OpenSwiftUI_v1_0, *)
extension ForEach: View, PrimitiveView where Content: View {
    public typealias Body = Never

    nonisolated public static func _makeView(
        view: _GraphValue<ForEach<Data, ID, Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<ForEach<Data, ID, Content>>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ForEachEvictionInput

package struct ForEachEvictionInput: GraphInput {
    package typealias Value = WeakAttribute<Bool>

    package static let defaultValue: WeakAttribute<Bool> = .init()

    package static let evictByDefault: Bool = isLinkedOnOrAfter(.v6)
}

// MARK: - LogForEachSlowPath

private struct LogForEachSlowPath: UserDefaultKeyedFeature {    
    static var key: String { "LogForEachSlowPath" }

    static var cachedValue: Bool?

    static var defaults: UserDefaults {
        UserDefaults.openSwiftUI ?? .standard
    }
}

// MARK: - ForEachState [WIP]

private class ForEachState<Data, ID, Content> where Data: RandomAccessCollection, ID: Hashable {
    let inputs: _ViewListInputs
    let parentSubgraph: Subgraph
    var info: Attribute<Info>?
    var list: Attribute<any ViewList>? = nil
    var view: ForEach<Data, ID, Content>? = nil
    var viewsPerElement: Int?? = nil
    var viewsCounts: [Int] = []
    var viewsCountStyle: ViewList.IteratorStyle = .init()
    var items: [ID: Item] = [:]
    var edits: [ID: ViewList.Edit] = [:]
    var lastTransaction: TransactionID = .init()
    var firstInsertionOffset: Int = -1
    var contentID: Int = 0
    var seed: UInt32 = 0
    var createdAllItems: Bool = false
    var evictionSeed: UInt32 = 0
    var pendingEviction: Bool = false
    var evictedIDs: Set<ID> = .init()
    var matchingStrategyCache: [ObjectIdentifier: IDTypeMatchingStrategy] = [:]

    init(inputs: _ViewListInputs) {
        self.inputs = inputs
        self.parentSubgraph = .current!
    }

    func invalidateViewCounts() {
        viewsCounts.removeAll(keepingCapacity: true)
    }

    func update(view: ForEach<Data, ID, Content>) {
        guard parentSubgraph.isValid else {
            return
        }
        invalidateViewCounts()
        _openSwiftUIUnimplementedFailure()
    }

    func item(at: Data.Index, offset: Int) -> Item {
        _openSwiftUIUnimplementedFailure()
    }

    func eraseItem(_ item: Item) {
        item.subgraph.willRemove()
        parentSubgraph.removeChild(item.subgraph)
        item.isRemoved = true
        item.timeToLive = 0
        item.invalidate(isInserted: true)
    }

    func uneraseItem(_ item: Item) {
        item.retain()
        item.isRemoved = false
        item.timeToLive = 8
        parentSubgraph.addChild(item.subgraph)
        item.subgraph.didReinsert()
    }

    func evictItems(seed: UInt32) {
        guard evictionSeed != seed, !pendingEviction else { return }
        evictionSeed = seed
        var evictItems: [Item] = []

        let startIndex = items.startIndex
        let endIndex = items.endIndex
        let pendingEviction: Bool
        if startIndex != endIndex {
            var index = startIndex
            var remainingEvictions = 64
            while true {
                let (id, item) = items[index]
                if !item.isRemoved {
                    let timeToLive = item.timeToLive - 1
                    if timeToLive == 0 {
                        if item.refcount == 1 {
                            evictItems.append(item)
                            evictedIDs.insert(id)
                            remainingEvictions &-= 1
                        }
                    } else {
                        item.timeToLive = timeToLive
                    }
                }
                items.formIndex(after: &index)
                guard remainingEvictions >= 1 else {
                    break
                }
                guard index != endIndex else {
                    remainingEvictions = 64
                    break
                }
            }
            pendingEviction = remainingEvictions == 0
        } else {
            pendingEviction = false
        }
        for evictItem in evictItems {
            eraseItem(evictItem)
        }
        self.pendingEviction = pendingEviction
    }

    func fetchViewsPerElement() -> Int? {
        if let viewsPerElement {
            return viewsPerElement
        } else {
            guard !view!.data.isEmpty else {
                return nil
            }
            _ = item(at: view!.data.startIndex, offset: 0)
            return viewsPerElement ?? nil
        }
    }

    @discardableResult
    func applyNodes(
        from start: inout Int,
        style: ViewList.IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout ViewList.SublistTransform,
        to body: ViewList.ApplyBody
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    @discardableResult
    func forEachItem(
        from start: inout Int,
        style: _ViewList_IteratorStyle,
        do body: (inout Int, ViewList.IteratorStyle, Item) -> Bool
    ) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    func count(style: ViewList.IteratorStyle) -> Int {
        _openSwiftUIUnimplementedFailure()
    }

    func estimatedCount(style: ViewList.IteratorStyle) -> Int {
        _openSwiftUIUnimplementedFailure()
    }

    func edit(forID: _ViewList_ID, since: TransactionID) -> Optional<_ViewList_Edit> {
        _openSwiftUIUnimplementedFailure()
    }

    func matchingStrategy<T>(for type: T.Type) -> IDTypeMatchingStrategy {
        let id = ObjectIdentifier(type)
        guard let strategy = matchingStrategyCache[id] else {
            _openSwiftUIUnimplementedFailure()
        }
        return strategy
    }

    func firstOffset<A1>(forID: A1, style: ViewList.IteratorStyle) -> Optional<Int> where A1: Hashable {
        _openSwiftUIUnimplementedFailure()
    }

    var traitKeys: ViewTraitKeys? {
        var traitKeys: ViewTraitKeys?
        var start = 0
        forEachItem(
            from: &start,
            style: .init()
        ) { _, _, item in
            switch item.views {
            case .staticList:
                traitKeys = .init()
            case let .dynamicList(attribute, _):
                let viewList = RuleContext(attribute: list!)[attribute]
                traitKeys = viewList.traitKeys
            }
            return false
        }
        guard let traitKeys else {
            return nil
        }
        return traitKeys.isDataDependent ? nil : traitKeys
    }

    var viewIDs: ViewList.ID.Views? {
        _openSwiftUIUnimplementedFailure()
    }

    // MARK: - ForEachState.Item

    class Item: ViewList.Subgraph {
        let id: ID
        let reuseID: Int
        let views: _ViewListOutputs.Views
        weak var state: ForEachState? = nil
        var index: Data.Index
        var offset: Int
        var contentID: Int
        var seed: UInt32
        var isConstant: Bool
        var timeToLive: Int8 = 8
        var isRemoved: Bool = false
        var hasWarned: Bool = false

        init(
            id: ID,
            reuseID: Int,
            views: _ViewListOutputs.Views,
            subgraph: Subgraph,
            index: Data.Index,
            offset: Int,
            contentID: Int,
            seed: UInt32,
            state: ForEachState?,
            isConstant: Bool
        ) {
            self.id = id
            self.reuseID = reuseID
            self.views = views
            self.state = state
            self.index = index
            self.offset = offset
            self.contentID = contentID
            self.seed = seed
            self.isConstant = isConstant
            super.init(subgraph: subgraph)
        }

        override func invalidate() {
            guard let state else {
                return
            }
            if let index = state.items.index(forKey: id) {
                state.items.remove(at: index)
            } else {
                state.items = state.items.filter { (key, value) in
                    value !== self
                }
            }
        }

        func applyTraits(to collection: inout ViewTraitCollection) {
            collection.setValueIfUnset(contentID, for: DynamicViewContentIDTraitKey.self)
            collection.setValueIfUnset(offset, for: DynamicViewContentOffsetTraitKey.self)
            if isConstant {
                collection.setTagIfUnset(for: Int.self, value: offset)
            } else {
                collection.setTagIfUnset(for: ID.self, value: id)
            }
        }
    }

    // MARK: - ForEachState.IDTypeMatchingStrategy

    enum IDTypeMatchingStrategy {
        case exact
        case anyHashable
        case customIDRepresentation
        case noMatch
    }

    // MARK: - Evictor

    struct Evictor: Rule, AsyncAttribute {
        var state: ForEachState
        @WeakAttribute var isEnabled: Bool?
        @Attribute var updateSeed: UInt32

        var value: Void {
            if isEnabled ?? ForEachEvictionInput.evictByDefault {
                state.evictItems(seed: updateSeed)
            }
        }
    }

    // MARK: - Info

    struct Info {
        var state: ForEachState
        var seed: UInt32

        struct Init: Rule, CustomStringConvertible {
            @Attribute var view: ForEach<Data, ID, Content>
            let state: ForEachState

            var value: Info {
                state.update(view: view)
                return Info(state: state, seed: state.seed)
            }

            var description: String {
                "Collection.Info"
            }
        }
    }

    // MARK: - StaticViewIDCollection

    struct StaticViewIDCollection: RandomAccessCollection, Equatable {
        var count: Int

        var startIndex: Int { 0 }

        var endIndex: Int { count }

        subscript(position: Int) -> ViewList.ID {
            _read {
                yield ViewList.ID().elementID(at: position)
            }
        }
    }

    // MARK: - ForEachViewIDCollection

    struct ForEachViewIDCollection: RandomAccessCollection, Equatable {
        var base: ViewList.ID.Views
        var data: Data
        var idGenerator: ForEach<Data, ID, Content>.IDGenerator
        var reuseID: KeyPath<Data.Element, Int>?
        var isUnary: Bool
        var owner: AnyAttribute
        var baseCount: Int
        var count: Int

        init(
            base: ViewList.ID.Views,
            data: Data,
            idGenerator: ForEach<Data, ID, Content>.IDGenerator,
            reuseID _: KeyPath<Data.Element, Int>?,
            isUnary: Bool,
            owner: AnyAttribute
        ) {
            self.base = base
            self.data = data
            self.idGenerator = idGenerator
            self.isUnary = isUnary
            self.owner = owner
            let endIndex = base.endIndex
            baseCount = endIndex
            count = data.count * endIndex
        }

        var startIndex: Int { 0 }

        var endIndex: Int { count }

        subscript(position: Int) -> ViewList.ID {
            _read {
                let dataOffset = position / baseCount
                let baseIndex = position - dataOffset * baseCount
                var id = base[baseIndex]
                let dataIndex = data.index(data.startIndex, offsetBy: dataOffset)
                let reuseID = reuseID.map { keyPath in
                    data[dataIndex][keyPath: keyPath]
                } ?? Int(bitPattern: ObjectIdentifier(Content.self))
                switch idGenerator {
                case .keyPath:
                    let explicitID = idGenerator.makeID(
                        data: data,
                        index: dataIndex,
                        offset: dataOffset
                    )
                    id.bind(
                        explicitID: explicitID,
                        owner: owner,
                        isUnary: isUnary,
                        reuseID: reuseID
                    )
                case .offset:
                    let explicitID = Pair(dataOffset, owner)
                    id.bind(
                        explicitID: explicitID,
                        owner: owner,
                        isUnary: isUnary,
                        reuseID: reuseID
                    )
                }
                yield id
            }
        }

        static func == (
            lhs: ForEachViewIDCollection,
            rhs: ForEachViewIDCollection
        ) -> Bool {
            lhs.base == rhs.base &&
            lhs.isUnary == rhs.isUnary &&
            lhs.owner == rhs.owner &&
            compareValues(lhs.data, rhs.data)
        }
    }

    // MARK: - Transform

    struct Transform: ViewList.SublistTransform.Item {
        var item: Item
        var bindID: Bool
        var isUnary: Bool
        var isConstant: Bool

        func apply(sublist: inout ViewList.Sublist) {
            bindID(&sublist.id)
            sublist.elements = item.wrapping(sublist.elements)
            item.applyTraits(to: &sublist.traits)
        }

        func bindID(_ id: inout ViewList.ID) {
            guard bindID,
                  let state = item.state,
                  let list = state.list
            else {
                return
            }
            if isConstant {
                let explicitID = Pair(item.offset, list.identifier)
                id.bind(
                    explicitID: explicitID,
                    owner: list.identifier,
                    isUnary: isUnary,
                    reuseID: item.reuseID
                )
            } else {
                id.bind(
                    explicitID: item.id,
                    owner: list.identifier,
                    isUnary: isUnary,
                    reuseID: item.reuseID
                )
            }
        }
    }

    // MARK: - ItemList

    struct ItemList: Rule {
        @Attribute var base: any ViewList
        var item: Item?

        var value: any ViewList {
            WrappedList(base: base, item: item)
        }

        struct WrappedList: ViewList {
            var base: any ViewList
            var item: Item?

            func count(style: IteratorStyle) -> Int {
                base.count(style: style)
            }

            func estimatedCount(style: IteratorStyle) -> Int {
                base.estimatedCount(style: style)
            }

            var traitKeys: ViewTraitKeys? {
                base.traitKeys
            }

            var viewIDs: ViewList.ID.Views? {
                base.viewIDs
            }

            var traits: ViewTraitCollection {
                var traits = base.traits
                if let item {
                    item.applyTraits(to: &traits)
                }
                return traits
            }

            @discardableResult
            func applyNodes(
                from start: inout Int,
                style: IteratorStyle,
                list: Attribute<any ViewList>?,
                transform: inout SublistTransform,
                to body: ApplyBody
            ) -> Bool {
                base.applyNodes(
                    from: &start,
                    style: style,
                    list: list,
                    transform: &transform,
                    to: body
                )
            }

            func edit(
                forID id: ViewList.ID,
                since transaction: TransactionID
            ) -> Edit? {
                base.edit(forID: id, since: transaction)
            }

            func firstOffset<OtherID>(
                forID id: OtherID,
                style: IteratorStyle
            ) -> Int? where OtherID: Hashable {
                base.firstOffset(forID: id, style: style)
            }
        }
    }
}

// MARK: - ForEachList

private struct ForEachList<Data, ID, Content>: ViewList where Data: RandomAccessCollection, ID: Hashable {
    var state: ForEachState<Data, ID, Content>
    var seed: UInt32

    func count(style: IteratorStyle) -> Int {
        state.count(style: style)
    }

    func estimatedCount(style: IteratorStyle) -> Int {
        state.estimatedCount(style: style)
    }

    var traitKeys: ViewTraitKeys? {
        state.traitKeys
    }

    var viewIDs: ViewList.ID.Views? {
        state.viewIDs
    }

    var traits: ViewTraitCollection {
        .init()
    }

    @discardableResult
    func applyNodes(
        from start: inout Int,
        style: IteratorStyle,
        list: Attribute<any ViewList>?,
        transform: inout SublistTransform,
        to body: ApplyBody
    ) -> Bool {
        state.applyNodes(
            from: &start,
            style: style,
            list: list,
            transform: &transform,
            to: body
        )
    }

    func edit(
        forID id: ViewList.ID,
        since transaction: TransactionID
    ) -> Edit? {
        state.edit(forID: id, since: transaction)
    }

    func firstOffset<OtherID>(
        forID id: OtherID,
        style: IteratorStyle
    ) -> Int? where OtherID: Hashable {
        state.firstOffset(forID: id, style: style)
    }

    struct Init: StatefulRule, AsyncAttribute, CustomStringConvertible {
        @Attribute var info: ForEachState<Data, ID, Content>.Info
        var seed: UInt32

        typealias Value = any ViewList

        mutating func updateValue() {
            info.state.invalidateViewCounts()
            seed &+= 1
            value = ForEachList(state: info.state, seed: seed)
        }

        var description: String {
            "Collection.List"
        }
    }
}

// MARK: - ForEach + id

@available(OpenSwiftUI_v1_0, *)
extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, idGenerator: .keyPath(\.id), content: content)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension ForEach where Content: View {

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the provided key path to the underlying data's
    /// identifier.
    ///
    /// It's important that the `id` of a data element doesn't change, unless
    /// SwiftUI considers the data element to have been replaced with a new data
    /// element that has a new identity. If the `id` of a data element changes,
    /// then the content view generated from that data element will lose any
    /// current state and animations.
    ///
    /// - Parameters:
    ///   - data: The data that the ``ForEach`` instance uses to create views
    ///     dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - content: The view builder that creates views dynamically.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            idGenerator: .keyPath(id),
            content: content
        )
    }
}

// MARK: - ForEach + binding

@available(OpenSwiftUI_v1_0, *)
extension ForEach where Content: View {

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public init<C>(
        _ data: Binding<C>,
        @ViewBuilder content: @escaping (Binding<C.Element>) -> Content
    ) where Data == LazyMapSequence<C.Indices, (C.Index, ID)>,
    ID == C.Element.ID,
    C: MutableCollection,
    C: RandomAccessCollection,
    C.Element: Identifiable,
    C.Index: Hashable {
        self.init(data, id: \.id, content: content)
    }

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - content: The view builder that creates views dynamically.
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public init<C>(
        _ data: Binding<C>,
        id: KeyPath<C.Element, ID>,
        @ViewBuilder content: @escaping (Binding<C.Element>) -> Content
    ) where Data == LazyMapSequence<C.Indices, (C.Index, ID)>,
    C: MutableCollection,
    C: RandomAccessCollection,
    C.Index: Hashable {
        let elementIDs = data.wrappedValue.indices.lazy.map { index in
            (index, data.wrappedValue[index][keyPath: id])
        }
        self.init(elementIDs, id: \.1) { (index, _) in
            let elementBinding = Binding {
                data.wrappedValue[index]
            } set: {
                data.wrappedValue[index] = $0
            }
            content(elementBinding)
        }
    }
}

// MARK: - ForEach + range

@available(OpenSwiftUI_v1_0, *)
extension ForEach where Data == Range<Int>, ID == Int, Content: View {

    /// Creates an instance that computes views on demand over a given constant
    /// range.
    ///
    /// The instance only reads the initial value of the provided `data` and
    /// doesn't need to identify views across updates. To compute views on
    /// demand over a dynamic range, use ``ForEach/init(_:id:content:)``.
    ///
    /// - Parameters:
    ///   - data: A constant range.
    ///   - content: The view builder that creates views dynamically.
    @_semantics("swiftui.requires_constant_range")
    public init(_ data: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.init(data, idGenerator: .offset, content: content)
    }
}
