//
//  SectionAccumulator.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D22569EAA67164B36532D028EDA82857 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - SectionAccumulator

package struct SectionAccumulator {
    private var pendingChunks: [RowIDs.Chunk] = []
    private var pendingChunkIDCount: Int = 0
    private var lastExplicitSectionEnd: Int = 0
    private var list: (any ViewList)?
    private var contentSubgraph: Subgraph?
    package private(set) var items: [Item] = []
    package private(set) var viewCount: Int = 0
    private var pendingEmptySectionTraits: [ViewTraitCollection] = []

    package init(contentSubgraph: Subgraph?) {
        self.contentSubgraph = contentSubgraph
    }

    package static func processUnsectionedContent(
        list: any ViewList,
        contentSubgraph: Subgraph?
    ) -> [Item]? {
        guard let keys = list.traitKeys, !keys.contains(IsSectionedTraitKey.self) else {
            return nil
        }
        if let ids = list.viewIDs, ids.isEmpty {
            return []
        }
        return [.implicitSentinel(list, contentSubgraph: contentSubgraph)]
    }

    package mutating func formResult(from list: any ViewList, listAttribute: Attribute<any ViewList>?) {
        self.list = list
        Update.begin()
        var start = 0
        var transform = ViewList.SublistTransform()
        list.applyNodes(from: &start, style: .init(), list: listAttribute, transform: &transform) {
            apply(start: &$0, style: $1, node: $2, transform: &$3)
        }
        if lastExplicitSectionEnd < viewCount {
            appendImplicitSection()
        }
        if items.isEmpty {
            items = viewCount > 0 ? [.implicitSentinel(list, contentSubgraph: nil)] : []
        }
        Update.end()
        self.list = nil
    }

    private mutating func apply(
        start: inout Int,
        style: ViewList.IteratorStyle,
        node: ViewList.Node,
        transform: inout ViewList.SublistTransform
    ) -> Bool {
        switch node {
        case let .list(list, attribute):
            guard let keys = list.traitKeys, !keys.contains(IsSectionedTraitKey.self) else {
                return list.applyNodes(from: &start, style: style, list: attribute, transform: &transform) {
                    apply(start: &$0, style: $1, node: $2, transform: &$3)
                }
            }
            let count = list.count
            pendingChunks.append(RowIDs.Chunk(
                list: list,
                listAttribute: attribute,
                transform: transform,
                start: start,
                count: count,
                lowerBound: pendingChunkIDCount
            ))
            pendingChunkIDCount += count
            viewCount += count
        case var .sublist(sublist):
            transform.apply(sublist: &sublist)
            pendingChunks.append(RowIDs.Chunk(
                ids: .sublist(sublist.id.elementIDs(count: sublist.count)),
                count: sublist.count,
                lowerBound: pendingChunkIDCount
            ))
            pendingChunkIDCount += sublist.count
            viewCount += sublist.count
        case let .group(group):
            for (list, attribute) in group.lists {
                guard apply(start: &start, style: style, node: .list(list, attribute), transform: &transform) else {
                    return false
                }
            }
        case let .section(section):
            if lastExplicitSectionEnd < viewCount {
                appendImplicitSection()
            }
            let count = section.count
            if count > 0 {
                items.append(Item(
                    features: [],
                    list: section,
                    contentSubgraph: contentSubgraph,
                    sectionList: section,
                    transform: transform,
                    ids: RowIDs(
                        list: section.content.list,
                        listAttribute: section.content.attribute,
                        start: 0,
                        count: section.content.list.count
                    ),
                    headerCount: section.header.list.count,
                    footerCount: section.footer.list.count,
                    id: section.id,
                    start: 0,
                    traits: pendingEmptySectionTraits + [section.traits]
                ))
                pendingEmptySectionTraits.removeAll(keepingCapacity: true)
                viewCount += count
                lastExplicitSectionEnd = viewCount
            } else {
                lastExplicitSectionEnd = viewCount
                if items.isEmpty {
                    pendingEmptySectionTraits.append(section.traits)
                } else {
                    items[items.count - 1].traits.append(section.traits)
                }
            }
        }
        return true
    }

    private mutating func appendImplicitSection() {
        let list = list!
        items.append(Item(
            features: .implicit,
            list: list,
            contentSubgraph: contentSubgraph,
            sectionList: nil,
            transform: .init(),
            ids: RowIDs(chunks: pendingChunks),
            headerCount: 0,
            footerCount: 0,
            id: UInt32(items.count),
            start: lastExplicitSectionEnd,
            traits: [list.traits]
        ))
        pendingChunks.removeAll(keepingCapacity: true)
        pendingChunkIDCount = 0
    }
}

// MARK: - SectionAccumulator.Item

extension SectionAccumulator {
    package struct Item {
        package var features: Features
        package var list: any ViewList
        package var contentSubgraph: Subgraph?
        package var sectionList: ViewList.Section?
        package var transform: ViewList.SublistTransform
        package var ids: RowIDs
        package var headerCount: Int
        package var footerCount: Int
        package var id: UInt32
        package var start: Int
        package var traits: [ViewTraitCollection]

        package var count: Int { ids.count }

        package var hasRows: Bool { count > 0 }

        package struct Features: OptionSet {
            package let rawValue: UInt8

            package init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            package static let implicit = Features(rawValue: 1 << 0)
        }

        package static func implicitSentinel(_ list: any ViewList, contentSubgraph: Subgraph?) -> Item {
            let count = Update.ensure { list.count }
            return Item(
                features: .implicit,
                list: list,
                contentSubgraph: contentSubgraph,
                sectionList: nil,
                transform: .init(),
                ids: RowIDs(list: list, listAttribute: nil, start: 0, count: count),
                headerCount: 0,
                footerCount: 0,
                id: 0,
                start: 0,
                traits: [list.traits]
            )
        }
    }
}

// MARK: - SectionAccumulator.RowIDs

extension SectionAccumulator {
    package struct RowIDs: RandomAccessCollection {
        let chunks: [Chunk]

        package init(ids: [ViewList.ID]) {
            chunks = [Chunk(ids: .idArray(ids), count: ids.count, lowerBound: 0)]
        }

        package init(list: any ViewList, listAttribute: Attribute<any ViewList>?, start: Int, count: Int) {
            chunks = [Chunk(
                list: list,
                listAttribute: listAttribute,
                transform: .init(),
                start: start,
                count: count,
                lowerBound: 0
            )]
        }

        init(chunks: [Chunk]) {
            self.chunks = chunks
        }

        package var startIndex: Int { chunks.first?.lowerBound ?? 0 }

        package var endIndex: Int {
            guard let last = chunks.last else { return 0 }
            return last.lowerBound + last.count
        }

        package subscript(index: Int) -> ViewList.ID.Canonical {
            for chunk in chunks where index < chunk.lowerBound + chunk.count {
                let index = index - chunk.lowerBound
                return switch chunk.ids {
                case let .viewListIDs(ids): ids[index].canonicalID
                case let .idArray(ids): ids[index].canonicalID
                case let .sublist(ids): ids[index].canonicalID
                }
            }
            _openSwiftUIUnreachableCode()
        }

        enum IDs {
            case viewListIDs(ViewList.ID.Views)
            case idArray([ViewList.ID])
            case sublist(ViewList.ID.ElementCollection)
        }

        struct Chunk {
            var ids: IDs
            var count: Int
            var lowerBound: Int

            init(ids: IDs, count: Int, lowerBound: Int) {
                self.ids = ids
                self.count = count
                self.lowerBound = lowerBound
            }

            init(
                list: any ViewList,
                listAttribute: Attribute<any ViewList>?,
                transform: ViewList.SublistTransform,
                start: Int,
                count: Int,
                lowerBound: Int
            ) {
                if let viewIDs = list.viewIDs {
                    ids = .viewListIDs(transform.isEmpty ? viewIDs : ViewList.ID._Views(
                        TransformedIDs(base: viewIDs, transform: transform),
                        isDataDependent: true
                    ))
                } else {
                    var array: [ViewList.ID] = []
                    array.reserveCapacity(count)
                    var remaining = count
                    var start = start
                    _ = list.applyIDs(from: &start, listAttribute: listAttribute, transform: transform) { id in
                        array.append(id)
                        remaining -= 1
                        return remaining != 0
                    }
                    ids = .idArray(array)
                }
                self.count = count
                self.lowerBound = lowerBound
            }
        }
    }
}

// MARK: - SectionAccumulator.TransformedIDs

extension SectionAccumulator {
    struct TransformedIDs: RandomAccessCollection, Equatable {
        var base: ViewList.ID.Views
        var transform: ViewList.SublistTransform

        var startIndex: Int { base.startIndex }
        var endIndex: Int { base.endIndex }

        subscript(index: Int) -> ViewList.ID {
            var sublist = ViewList.Sublist(
                start: 0,
                count: 1,
                id: base[index],
                elements: EmptyViewListElements(),
                traits: .init(),
                list: nil
            )
            transform.apply(sublist: &sublist)
            return sublist.id
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.base === rhs.base
        }
    }
}
