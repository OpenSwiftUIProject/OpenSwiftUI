//
//  SectionedIdentifierAccumulator.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct SectionedIdentifierAccumulator: ViewListVisitor {
    let needsIDs: Bool
    var sections: [Sections.Item] = []
    var sectionsWithFooters: Set<Int>?
    var ids: [ViewList.ID] = []
    var hasExplicitSections: Bool = false
    var compactSections: Set<Int> = []
    var inImplicitSection: Bool = false
    var viewCount: Int = 0

    mutating func visit(view: ViewList.View, traits: ViewTraitCollection) -> Bool {
        if traits.groupDepth == 0 {
            if traits.isSectioned {
                hasExplicitSections = true
                inImplicitSection = false
                sections.append(Sections.Item(
                    offset: viewCount,
                    implicit: false,
                    hasHeader: !traits.isEmptyView
                ))
            } else if !inImplicitSection {
                inImplicitSection = true
                sections.append(Sections.Item(
                    offset: viewCount,
                    implicit: true,
                    hasHeader: false
                ))
            }
            if traits[UseCompactSectionSpacingTraitKey.self] {
                compactSections.insert(sections.count - 1)
            }
        }
        if sectionsWithFooters != nil, traits.isSectionFooter {
            sectionsWithFooters?.insert(sections.count - 1)
        }
        if needsIDs {
            ids.append(view.elementID)
        }
        viewCount &+= 1
        return true
    }
}
