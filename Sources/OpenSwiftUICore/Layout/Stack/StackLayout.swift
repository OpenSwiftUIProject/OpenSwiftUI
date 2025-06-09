//
//  StackLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: WIP
//  ID: 00690F480F8D293143B214DBE6D72CD0 (SwiftUICore?)

import Foundation

struct StackLayout {
    private struct MajorAxisRangeCache {
        var min: CGFloat?
        var max: CGFloat?
    }

    private struct Header {
        let minorAxisAlignment: AlignmentKey
        let uniformSpacing: CGFloat?
        let majorAxis: Axis
        var internalSpacing: CGFloat
        var lastProposedSize: ProposedViewSize
        var stackSize: CGSize
        let proxies: LayoutSubviews
        let resizeChildrenWithTrailingOverflow: Bool
    }

    private var header: Header

    private struct Child {
        var layoutPriority: Double
        var majorAxisRangeCache: StackLayout.MajorAxisRangeCache
        let distanceToPrevious: CGFloat
        var fittingOrder: Int
        var geometry: ViewGeometry
    }

    private var children: [Child]

    private func makeChildren() {
        // TODO
    }
}

