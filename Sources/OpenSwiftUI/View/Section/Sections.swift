//
//  Sections.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct Sections {
    let children: _VariadicView.Children
    let items: [Item]
    let hasExplicitSections: Bool
    let sectionsWithFooters: Set<Int>?
    let compactSections: Set<Int>
    let ids: ViewList.ID.Views

    struct Item {
        var offset: Int
        var implicit: Bool
        var hasHeader: Bool
    }

    init(from children: _VariadicView.Children, useFooters: Bool) {
        self.children = children
        let ids = children.list.viewIDs
        if let traitKeys = children.list.traitKeys,
           !traitKeys.contains(IsSectionedTraitKey.self),
           let ids {
            items = ids.isEmpty ? [] : [Item(offset: 0, implicit: true, hasHeader: false)]
            hasExplicitSections = false
            sectionsWithFooters = nil
            compactSections = []
            self.ids = ids
        } else {
            var accumulator = SectionedIdentifierAccumulator(
                needsIDs: ids == nil,
                sectionsWithFooters: useFooters ? [] : nil
            )
            children.content.visitAll(applying: &accumulator)
            items = accumulator.sections
            hasExplicitSections = accumulator.hasExplicitSections
            sectionsWithFooters = accumulator.sectionsWithFooters
            compactSections = accumulator.compactSections
            self.ids = ids ?? ViewList.ID._Views(accumulator.ids, isDataDependent: true)
        }
    }

    var sectionIDs: LazyMapSequence<[Item], ViewList.ID.Canonical> {
        if hasExplicitSections {
            items.lazy.map { [ids] in ids[$0.offset].canonicalID }
        } else {
            items.lazy.map { ViewList.ID().elementID(at: $0.offset).canonicalID }
        }
    }

    func footerOffset(forSectionAt section: Int) -> Int {
        precondition(
            sectionsWithFooters?.contains(section) ?? false,
            "No footer for section \(section)"
        )
        return endOffset(forSectionAt: section) - 1
    }

    func rowIDs(forSectionAt section: Int) -> LazyMapSequence<Slice<ViewList.ID.Views>, ViewList.ID.Canonical> {
        let start = rowOffset(forSectionAt: section)
        var end = endOffset(forSectionAt: section)
        if sectionsWithFooters?.contains(section) == true {
            end -= 1
        }
        return ids[start..<end].lazy.map { $0.canonicalID }
    }

    func firstIndexPath<ID>(for id: ID) -> IndexPath? where ID: Hashable {
        guard let offset = children.list.firstOffset(forID: id, style: .init()) else {
            return nil
        }
        let section = sectionIDs.indices.lowerBound {
            endOffset(forSectionAt: $0) < offset
        }
        guard section < sectionIDs.count else {
            return nil
        }
        return indexPath(for: offset, section: section)
    }

    func firstIndexPath(of id: ViewList.ID.Canonical) -> IndexPath? {
        guard let offset = children.list.firstOffset(of: id) else {
            return nil
        }
        let section = sectionIDs.indices.lowerBound {
            endOffset(forSectionAt: $0) < offset
        }
        return indexPath(for: offset, section: section)
    }

    private func rowOffset(forSectionAt section: Int) -> Int {
        let item = items[section]
        return item.offset + (hasExplicitSections && !item.implicit ? 1 : 0)
    }

    private func endOffset(forSectionAt section: Int) -> Int {
        let next = section + 1
        return next < items.count ? items[next].offset : ids.endIndex
    }

    private func indexPath(for offset: Int, section: Int) -> IndexPath? {
        let relativeOffset = offset - rowOffset(forSectionAt: section)
        let count = endOffset(forSectionAt: section) - rowOffset(forSectionAt: section)
        var row = max(relativeOffset, 0)
        var section = section
        if row >= count {
            if relativeOffset <= 0, count == 0 {
                row = NSNotFound
            } else if section < sectionIDs.count - 1 {
                row -= count
                section += 1
            } else {
                return nil
            }
        }
        return IndexPath(indexes: [section, row])
    }
}
