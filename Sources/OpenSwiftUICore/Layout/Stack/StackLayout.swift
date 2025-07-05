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
                    let spacing = subview.spacing
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

    func update(
        children: LayoutSubviews,
        majorAxis: Axis,
        minorAxisAlignment: AlignmentKey,
        uniformSpacing: CGFloat?
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    mutating func spacing() -> ViewSpacing {
        _openSwiftUIUnimplementedWarning()
        return .init(.zero)
    }

    mutating func sizeThatFits(_ proposedSize: ProposedViewSize) -> CGSize {
        withUnmanagedImplementation { impl in
            _openSwiftUIUnimplementedWarning()
            return CGSize(width: 50, height: 50)
        }
    }

    mutating func placeSubviews(in bounds: CGRect, proposedSize: ProposedViewSize) {
        withUnmanagedImplementation { impl in
            impl.commitPlacements(in: bounds, proposedSize: proposedSize)
        }
    }

    mutating func explicitAlignment(
        _ key: AlignmentKey,
        in bounds: CGRect,
        proposal: ProposedViewSize,
    ) -> CGFloat? {
        withUnmanagedImplementation { impl in
            impl.explicitAlignment(
                key,
                at: ViewSize(bounds.size, proposal: .init(proposal))
            )
        }
    }
}

extension StackLayout {
    @inline(__always)
    private mutating func withUnmanagedImplementation<V>(
        _ body: (UnmanagedImplementation) -> V
    ) -> V {
        withUnsafeMutablePointer(to: &header) { headerPtr in
            children.withUnsafeMutableBufferPointer { childPtr in
                body(UnmanagedImplementation(header: headerPtr, children: childPtr))
            }
        }
    }

    private struct UnmanagedImplementation {
        let header: UnsafeMutablePointer<Header>
        let children: UnsafeMutableBufferPointer<Child>

        func commitPlacements(
            in bounds: CGRect,
            proposedSize: ProposedViewSize
        ) {
            let proposal = proposalWhenPlacing(in: .init(bounds.size, proposal: .init(proposedSize)))
            placeChildren(in: proposedSize)

            // TODO: placeChildren1
            _openSwiftUIUnimplementedWarning()
        }

        func spacing() -> Spacing {
            _openSwiftUIUnimplementedWarning()
            return .zero
        }

        func explicitAlignment(
            _ key: AlignmentKey,
            at size: ViewSize
        ) -> CGFloat? {
            let proposal = proposalWhenPlacing(in: size)
            placeChildren(in: proposal)
            guard !children.isEmpty else {
                return nil
            }
            let alignments = children.map {
                $0.geometry.dimensions[explicit: key]
            }
            return key.id.combineExplicit(alignments)
        }

        // WIP
        func placeChildren(in proposedSize: ProposedViewSize) {
            guard header.pointee.lastProposedSize != proposedSize, !children.isEmpty else {
                return
            }
            placeChildren1(in: proposedSize) { child in
                proposedSize[header.pointee.majorAxis.otherAxis]
            }
            if header.pointee.resizeChildrenWithTrailingOverflow {
                resizeAnyChildrenWithTrailingOverflow(in: proposedSize)
            }
            header.pointee.lastProposedSize = proposedSize
        }

        func placeChildren1(
            in proposedSize: ProposedViewSize,
            minorProposalForChild: (Child) -> CGFloat?
        ) {
            if proposedSize[header.pointee.majorAxis] != nil {
                sizeChildrenGenerallyWithConcreteMajorProposal(
                    in: proposedSize,
                    minorProposalForChild: minorProposalForChild
                )
            } else {
                sizeChildrenIdeally(
                    in: proposedSize,
                    minorProposalForChild: minorProposalForChild
                )
            }
            var majorValue: CGFloat = 0.0
            var minorRange: ClosedRange<CGFloat> = 0.0 ... 0.0
            for child in children {
                let minorAxis = header.pointee.majorAxis.otherAxis
                let childRange = child.geometry.frame[minorAxis]
                minorRange = minorRange.union(childRange)
            }
            for (index, child) in children.enumerated() {
                let majorAxis = header.pointee.majorAxis
                let minorAxis = majorAxis.otherAxis
                let majorOrigin = majorValue + child.distanceToPrevious
                if !majorOrigin.isNaN {
                    children[index].geometry.origin[majorAxis] = majorOrigin
                }
                let minorOrigin = child.geometry.origin[minorAxis] - minorRange.lowerBound
                if !minorOrigin.isNaN {
                    children[index].geometry.origin[minorAxis] = minorOrigin
                }
                majorValue = majorOrigin + child.geometry.dimensions.size[majorAxis]
            }
            header.pointee.stackSize = CGSize(
                majorValue,
                in: header.pointee.majorAxis,
                by: minorRange.length
            )
        }

        func sizeChildrenGenerallyWithConcreteMajorProposal(
            in size: ProposedViewSize,
            minorProposalForChild: (Child) -> CGFloat?
        ) {

        }
        
        func sizeChildrenIdeally(
            in size: ProposedViewSize,
            minorProposalForChild: (Child) -> CGFloat?
        ) {
            guard !children.isEmpty else {
                return
            }
            let majorOrigin: CGFloat = 0.0
            let majorAxis = header.pointee.majorAxis
            for (index, child) in children.enumerated() {
                let proposal = ProposedViewSize(
                    nil,
                    in: majorAxis,
                    by: minorProposalForChild(child)
                )
                let dimensions = header.pointee.proxies[index].dimensions(in: proposal)
                let minorAlignment = dimensions[header.pointee.minorAxisAlignment]
                let origin = CGPoint(
                    majorOrigin,
                    in: majorAxis,
                    by: -minorAlignment.mappingNaN(to: .infinity)
                )
                children[index].geometry = ViewGeometry(
                    origin: origin,
                    dimensions: dimensions
                )
            }
        }

        func proposalWhenPlacing(in size: ViewSize) -> ProposedViewSize {
            let proposal = size.proposal
            let axis = header.pointee.majorAxis
            return if axis == .horizontal {
                ProposedViewSize(
                    width: proposal.width,
                    height: proposal.height ?? size.height
                )
            } else {
                ProposedViewSize(
                    width: proposal.width ?? size.width,
                    height: proposal.height
                )
            }
        }

        func prioritize(
            _ children: UnsafeMutableBufferPointer<Child>,
            proposedSize: ProposedViewSize
        ) {
            _openSwiftUIUnimplementedWarning()
        }

        func resizeAnyChildrenWithTrailingOverflow(in size: ProposedViewSize) {
            _openSwiftUIUnimplementedWarning()
        }
    }
}
