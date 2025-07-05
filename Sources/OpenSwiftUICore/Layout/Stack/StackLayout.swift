//
//  StackLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 00690F480F8D293143B214DBE6D72CD0 (SwiftUICore)

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
        var internalSpacing: CGFloat = .zero
        var lastProposedSize: ProposedViewSize = .init(width: -.infinity, height: -.infinity)
        var stackSize: CGSize = .zero
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

    @inline(__always)
    init(
        minorAxisAlignment: AlignmentKey,
        uniformSpacing: CGFloat?,
        majorAxis: Axis,
        proxies: LayoutSubviews,
        resizeChildrenWithTrailingOverflow: Bool
    ) {
        self.header = Header(
            minorAxisAlignment: minorAxisAlignment,
            uniformSpacing: uniformSpacing,
            majorAxis: majorAxis,
            proxies: proxies,
            resizeChildrenWithTrailingOverflow: resizeChildrenWithTrailingOverflow
        )
        self.children = []
        makeChildren()
    }

    private mutating func makeChildren() {
        children.reserveCapacity(header.proxies.count)
        header.internalSpacing = .zero
        let proxies = header.proxies
        var internalSpacing: Double = .zero
        for (index, subview) in proxies.enumerated() {
            let distanceToPrevious: Double
            if index == 0 {
                distanceToPrevious = .zero
            } else {
                if let uniformSpacing = header.uniformSpacing {
                    distanceToPrevious = uniformSpacing
                } else {
                    let previousSpacing = proxies[index-1].spacing
                    let spacing = proxies[index].spacing
                    distanceToPrevious = previousSpacing.distance(to: spacing, along: header.majorAxis)
                }
                internalSpacing += distanceToPrevious
                header.internalSpacing = internalSpacing
            }
            children.append(
                Child(
                    layoutPriority: proxies[index].priority,
                    majorAxisRangeCache: .init(),
                    distanceToPrevious: distanceToPrevious,
                    fittingOrder: index,
                    geometry: .invalidValue
                )
            )
        }
    }

    func explicitAlignment(
        _ key: AlignmentKey,
        in bounds: CGRect,
        proposal: ProposedViewSize,
    ) -> CGFloat? {
        _openSwiftUIUnimplementedFailure()
    }
}

