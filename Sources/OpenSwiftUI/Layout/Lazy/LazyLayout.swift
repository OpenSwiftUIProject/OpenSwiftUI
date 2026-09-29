//
//  LazyLayout.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - _LazyLayout_PlacedSubview

struct _LazyLayout_PlacedSubview {
    var item: LazyLayoutCacheItem
    var placement: _Placement
    var index: Int
}

// MARK: - LazyLayoutCacheItem [TBA]

class LazyLayoutCacheItem {
    // TODO: Add the cache item storage and lifecycle.
    var id: _ViewList_ID {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    var section: LazyLayoutCacheSection {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }
}

// MARK: - LazyLayoutCacheSection

struct LazyLayoutCacheSection {
    var id: UInt32?
    var isHeader: Bool
    var isFooter: Bool
}
