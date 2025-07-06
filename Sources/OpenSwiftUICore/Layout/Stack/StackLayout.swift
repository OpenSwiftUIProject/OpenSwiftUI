//
//  StackLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (update and resize is not implemented yet)
//  ID: 00690F480F8D293143B214DBE6D72CD0 (SwiftUICore)

import Foundation

/// A layout that arranges subviews in a linear sequence along a major axis.
///
/// `StackLayout` provides the core implementation for stack-based layouts like
/// `HStack` and `VStack`. It manages the sizing and positioning of child views
/// along a primary axis while aligning them on the secondary axis.
struct StackLayout {
    /// Cache for storing major axis range calculations.
    private struct MajorAxisRangeCache {
        var min: CGFloat?
        var max: CGFloat?

        @inline(__always)
        mutating func getMin(_ makeValue: () -> CGFloat) -> CGFloat {
            guard let min else {
                let min = makeValue()
                self.min = min
                return min
            }
            return min
        }

        @inline(__always)
        mutating func getMax(_ makeValue: () -> CGFloat) -> CGFloat {
            guard let max else {
                let max = makeValue()
                self.max = max
                return max
            }
            return max
        }
    }

    /// Header containing shared layout configuration and state.
    private struct Header {
        /// The alignment key for positioning along the minor axis
        let minorAxisAlignment: AlignmentKey

        /// Optional uniform spacing between children
        let uniformSpacing: CGFloat?

        /// The primary axis of the stack layout
        let majorAxis: Axis

        /// Total spacing between all children
        var internalSpacing: CGFloat = .zero

        /// The last proposed size used for layout
        var lastProposedSize: ProposedViewSize = .init(width: -.infinity, height: -.infinity)

        /// The calculated size of the entire stack
        var stackSize: CGSize = .zero

        /// The layout subviews being arranged
        let proxies: LayoutSubviews

        /// Whether to resize children when they overflow
        let resizeChildrenWithTrailingOverflow: Bool
    }

    private var header: Header

    /// Represents a single child view in the stack layout.
    private struct Child {
        /// The layout priority of this child
        var layoutPriority: Double

        /// Cached major axis range calculations
        var majorAxisRangeCache: MajorAxisRangeCache

        /// Distance from the previous child
        let distanceToPrevious: CGFloat

        /// Order for fitting calculations
        var fittingOrder: Int

        /// The calculated geometry of this child
        var geometry: ViewGeometry
    }

    private var children: [Child]

    /// Creates a new stack layout with the specified configuration.
    ///
    /// - Parameters:
    ///   - minorAxisAlignment: Alignment along the minor axis
    ///   - uniformSpacing: Optional uniform spacing between children
    ///   - majorAxis: The primary axis of the stack
    ///   - proxies: The subviews to be laid out
    ///   - resizeChildrenWithTrailingOverflow: Whether to resize overflowing children
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

    /// Initializes the child array with proper spacing calculations.
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

    /// Updates the layout configuration with new parameters.
    ///
    /// - Parameters:
    ///   - children: The new set of layout subviews
    ///   - majorAxis: The primary axis for the layout
    ///   - minorAxisAlignment: Alignment along the minor axis
    ///   - uniformSpacing: Optional uniform spacing between children
    func update(
        children: LayoutSubviews,
        majorAxis: Axis,
        minorAxisAlignment: AlignmentKey,
        uniformSpacing: CGFloat?
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    /// Calculates the spacing for this stack layout.
    ///
    /// - Returns: The computed view spacing
    mutating func spacing() -> ViewSpacing {
        withUnmanagedImplementation { impl in
            ViewSpacing(
                impl.spacing(),
                layoutDirection: impl.proxies.layoutDirection
            )
        }
    }

    /// Calculates the size that fits the given proposed size.
    ///
    /// - Parameter proposedSize: The proposed size constraints
    /// - Returns: The computed size that fits within the constraints
    mutating func sizeThatFits(_ proposedSize: ProposedViewSize) -> CGSize {
        withUnmanagedImplementation { impl in
            impl.placeChildren(in: proposedSize)
            return impl.stackSize
        }
    }

    /// Places subviews within the specified bounds.
    ///
    /// - Parameters:
    ///   - bounds: The bounds rectangle for placement
    ///   - proposedSize: The proposed size for layout
    mutating func placeSubviews(in bounds: CGRect, proposedSize: ProposedViewSize) {
        withUnmanagedImplementation { impl in
            impl.commitPlacements(in: bounds, proposedSize: proposedSize)
        }
    }

    /// Calculates explicit alignment for the given key.
    ///
    /// - Parameters:
    ///   - key: The alignment key to calculate
    ///   - bounds: The bounds rectangle
    ///   - proposal: The proposed size
    /// - Returns: The alignment value, or nil if not applicable
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
    /// Executes a closure with an unmanaged implementation pointer.
    ///
    /// - Parameter body: The closure to execute with the implementation
    /// - Returns: The result of the closure
    @inline(__always)
    private mutating func withUnmanagedImplementation<V>(
        _ body: (UnmanagedImplementation) -> V
    ) -> V {
        withUnsafeMutablePointer(to: &header) { headerPtr in
            children.withUnsafeMutableBufferPointer { childrenPtr in
                body(UnmanagedImplementation(headerPtr: headerPtr, childrenPtr: childrenPtr))
            }
        }
    }

    /// Unmanaged implementation providing direct pointer access for performance.
    private struct UnmanagedImplementation {
        let headerPtr: UnsafeMutablePointer<Header>

        let childrenPtr: UnsafeMutableBufferPointer<Child>

        @inline(__always)
        var count: Int {
            childrenPtr.count
        }

        @inline(__always)
        var minorAxisAlignment: AlignmentKey {
            headerPtr.pointee.minorAxisAlignment
        }

        @inline(__always)
        var uniformSpacing: CGFloat? {
            headerPtr.pointee.uniformSpacing
        }

        @inline(__always)
        var majorAxis: Axis {
            headerPtr.pointee.majorAxis
        }

        @inline(__always)
        var minorAxis: Axis {
            headerPtr.pointee.majorAxis.otherAxis
        }

        @inline(__always)
        var internalSpacing: CGFloat {
            get { headerPtr.pointee.internalSpacing }
            nonmutating set { headerPtr.pointee.internalSpacing = newValue }
        }

        @inline(__always)
        var lastProposedSize: ProposedViewSize {
            get { headerPtr.pointee.lastProposedSize }
            nonmutating set { headerPtr.pointee.lastProposedSize = newValue }
        }

        @inline(__always)
        var stackSize: CGSize {
            get { headerPtr.pointee.stackSize }
            nonmutating set { headerPtr.pointee.stackSize = newValue }
        }

        @inline(__always)
        var proxies: LayoutSubviews {
            headerPtr.pointee.proxies
        }

        @inline(__always)
        var resizeChildrenWithTrailingOverflow: Bool {
            headerPtr.pointee.resizeChildrenWithTrailingOverflow
        }

        // FIXME: [Copilot Generated]
        /// Commits the final placement of children within bounds.
        ///
        /// - Parameters:
        ///   - bounds: The target bounds rectangle
        ///   - proposedSize: The proposed size for layout
        func commitPlacements(
            in bounds: CGRect,
            proposedSize: ProposedViewSize
        ) {
            placeChildren(in: proposedSize)
            
            guard !childrenPtr.isEmpty else { return }

            // Calculate offsets to center the stack within bounds
            let majorOffset = bounds.origin[majorAxis] + 
                (bounds.size[majorAxis] - stackSize[majorAxis]) / 2
            let minorOffset = bounds.origin[minorAxis] + 
                (bounds.size[minorAxis] - stackSize[minorAxis]) / 2
            
            // Place each child view at its calculated position
            for (index, child) in childrenPtr.enumerated() {
                let finalOrigin = CGPoint(
                    child.geometry.origin[majorAxis] + majorOffset,
                    in: majorAxis,
                    by: child.geometry.origin[minorAxis] + minorOffset
                )
                
                let finalBounds = CGRect(
                    origin: finalOrigin,
                    size: child.geometry.dimensions.size.value
                )
                
                // Get the child-specific proposed size
                let childProposal = ProposedViewSize(
                    child.geometry.dimensions.size[majorAxis],
                    in: majorAxis,
                    by: child.geometry.dimensions.size[minorAxis]
                )
                
                proxies[index].place(
                    at: finalBounds.origin,
                    anchor: .topLeading,
                    proposal: childProposal
                )
            }
        }

        /// Calculates the spacing for the stack.
        ///
        /// - Returns: The computed spacing value
        func spacing() -> Spacing {
            var spacing = proxies.isEmpty ? Spacing.zero : Spacing(minima: [:])
            let proxiesCount = proxies.count
            guard proxiesCount != 0 else {
                return spacing
            }
            for (index, subview) in proxies.enumerated() {
                let startEdge: Edge.Set
                if index == 0 {
                    startEdge = majorAxis == .horizontal ? .leading : .top
                } else {
                    startEdge = []
                }
                let endEdge: Edge.Set
                if index == proxies.count - 1 {
                    endEdge = majorAxis == .horizontal ? .trailing : .bottom
                } else {
                    endEdge = []
                }
                var edgeSet: Edge.Set = majorAxis == .horizontal ? .vertical : .horizontal
                edgeSet.insert(startEdge)
                edgeSet.insert(endEdge)
                let absoluteEdgeSet = AbsoluteEdge.Set(edgeSet, layoutDirection: proxies.layoutDirection)
                let subviewSpacing = subview.proxy.spacing()
                spacing.incorporate(absoluteEdgeSet, of: subviewSpacing)
            }
            return spacing
        }

        /// Calculates explicit alignment for a given key.
        ///
        /// - Parameters:
        ///   - key: The alignment key
        ///   - size: The view size context
        /// - Returns: The alignment value, or nil if not applicable
        func explicitAlignment(
            _ key: AlignmentKey,
            at size: ViewSize
        ) -> CGFloat? {
            let proposal = proposalWhenPlacing(in: size)
            placeChildren(in: proposal)
            guard !childrenPtr.isEmpty else {
                return nil
            }
            let alignments = childrenPtr.map {
                $0.geometry.dimensions[explicit: key]
            }
            return key.id.combineExplicit(alignments)
        }

        /// Places children according to the proposed size.
        ///
        /// - Parameter proposedSize: The proposed size for layout
        func placeChildren(in proposedSize: ProposedViewSize) {
            guard lastProposedSize != proposedSize, !childrenPtr.isEmpty else {
                return
            }
            placeChildren1(in: proposedSize) { child in
                proposedSize[minorAxis]
            }
            if resizeChildrenWithTrailingOverflow {
                resizeAnyChildrenWithTrailingOverflow(in: proposedSize)
            }
            lastProposedSize = proposedSize
        }

        /// Primary child placement implementation.
        ///
        /// - Parameters:
        ///   - proposedSize: The proposed size for layout
        ///   - minorProposalForChild: Closure providing minor axis proposal for each child
        func placeChildren1(
            in proposedSize: ProposedViewSize,
            minorProposalForChild: (Child) -> CGFloat?
        ) {
            if proposedSize[majorAxis] != nil {
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
            for child in childrenPtr {
                let childRange = child.geometry.frame[minorAxis]
                minorRange = minorRange.union(childRange)
            }
            for (index, child) in childrenPtr.enumerated() {
                let majorOrigin = majorValue + child.distanceToPrevious
                if !majorOrigin.isNaN {
                    childrenPtr[index].geometry.origin[majorAxis] = majorOrigin
                }
                let minorOrigin = child.geometry.origin[minorAxis] - minorRange.lowerBound
                if !minorOrigin.isNaN {
                    childrenPtr[index].geometry.origin[minorAxis] = minorOrigin
                }
                majorValue = majorOrigin + child.geometry.dimensions.size[majorAxis]
            }
            stackSize = CGSize(
                majorValue,
                in: majorAxis,
                by: minorRange.length
            )
        }

        /// Sizes children when given a concrete major axis proposal.
        ///
        /// This method handles the complex case where the major axis has a specific
        /// size constraint, requiring distribution of available space among children
        /// based on their layout priorities and flexibility.
        ///
        /// - Parameters:
        ///   - size: The proposed size with concrete major axis
        ///   - minorProposalForChild: Closure providing minor axis proposal for each child
        func sizeChildrenGenerallyWithConcreteMajorProposal(
            in size: ProposedViewSize,
            minorProposalForChild: (Child) -> CGFloat?
        ) {
            Swift.assert(size[majorAxis] != nil)
            prioritize(childrenPtr, proposedSize: size)
            let priorityPtr = UnsafeMutableBufferProjectionPointer(childrenPtr, \.layoutPriority)
            let fittingOrderPtr = UnsafeMutableBufferProjectionPointer(childrenPtr, \.fittingOrder)
            guard !childrenPtr.isEmpty else { return }
            var availableSpace = size[majorAxis]! - internalSpacing
            let majorOrigin: CGFloat = 0.0
            var index = 0
            let count = childrenPtr.count
            while index != count {
                let fittingOrder = fittingOrderPtr[index]
                let fittingPriority = priorityPtr[fittingOrder]
                let targetIndex: Int
                if !fittingPriority.isNaN {
                    targetIndex = childrenPtr[index+1..<count].firstIndex { child in
                        priorityPtr[child.fittingOrder] != fittingPriority
                    } ?? childrenPtr.count
                    Swift.assert(targetIndex >= index)
                } else {
                    targetIndex = index
                }
                Swift.assert(targetIndex <= count)
                let majorAxisRangeCacheMinTotal: CGFloat
                if fittingOrder == childrenPtr[0].fittingOrder {
                    majorAxisRangeCacheMinTotal = childrenPtr[targetIndex ..< count].reduce(into: .zero) {
                        $0 += childrenPtr[$1.fittingOrder].majorAxisRangeCache.min!
                    }
                    availableSpace -= majorAxisRangeCacheMinTotal
                } else {
                    majorAxisRangeCacheMinTotal = childrenPtr[index ..< targetIndex].reduce(into: .zero) {
                        $0 += childrenPtr[$1.fittingOrder].majorAxisRangeCache.min!
                    }
                    availableSpace += majorAxisRangeCacheMinTotal
                }
                if targetIndex != index {
                    Swift.assert(targetIndex >= 0)
                    let currentPriorityChildCount = targetIndex - index
                    assert(currentPriorityChildCount > 0)
                    var remainingCount = currentPriorityChildCount
                    while currentPriorityChildCount != 0 {
                        let currentIndexFittingOrder = fittingOrderPtr[index]
                        let evenSplitAvailableSpace = max(availableSpace / CGFloat(remainingCount), majorOrigin)
                        let proposal = _ProposedSize(
                            evenSplitAvailableSpace,
                            in: majorAxis,
                            by: minorProposalForChild(childrenPtr[index])
                        )
                        let dimensions = proxies[currentIndexFittingOrder]
                            .proxy
                            .dimensions(in: proposal)
                        let minorAlignment = dimensions[minorAxisAlignment]
                        let origin = CGPoint(
                            majorOrigin,
                            in: majorAxis,
                            by: -minorAlignment.mappingNaN(to: .infinity)
                        )
                        childrenPtr[currentIndexFittingOrder].geometry = ViewGeometry(
                            origin: origin,
                            dimensions: dimensions
                        )
                        let takenSpace = dimensions.size[majorAxis]
                        availableSpace = (availableSpace - takenSpace).mappingNaN(to: availableSpace)
                        remainingCount &-= 1
                        if remainingCount == 0 { break }
                        index &+= 1
                    }
                }
                index = targetIndex
            }
        }
        
        /// Sizes children to their ideal sizes without major axis constraints.
        ///
        /// - Parameters:
        ///   - size: The proposed size
        ///   - minorProposalForChild: Closure providing minor axis proposal for each child
        func sizeChildrenIdeally(
            in size: ProposedViewSize,
            minorProposalForChild: (Child) -> CGFloat?
        ) {
            guard !childrenPtr.isEmpty else {
                return
            }
            let majorOrigin: CGFloat = 0.0
            for (index, child) in childrenPtr.enumerated() {
                let proposal = ProposedViewSize(
                    nil,
                    in: majorAxis,
                    by: minorProposalForChild(child)
                )
                let dimensions = proxies[index].dimensions(in: proposal)
                let minorAlignment = dimensions[minorAxisAlignment]
                let origin = CGPoint(
                    majorOrigin,
                    in: majorAxis,
                    by: -minorAlignment.mappingNaN(to: .infinity)
                )
                childrenPtr[index].geometry = ViewGeometry(
                    origin: origin,
                    dimensions: dimensions
                )
            }
        }

        /// Creates a proposal for placement within the given size.
        ///
        /// - Parameter size: The target view size
        /// - Returns: The proposed size for placement
        func proposalWhenPlacing(in size: ViewSize) -> ProposedViewSize {
            let proposal = size.proposal
            return if majorAxis == .horizontal {
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

        /// Prioritizes children for layout calculations.
        ///
        /// - Parameters:
        ///   - childrenPtr: The children to prioritize
        ///   - proposedSize: The proposed size context
        func prioritize(
            _ childrenPtr: UnsafeMutableBufferPointer<Child>,
            proposedSize: ProposedViewSize
        ) {
            guard (proposedSize[minorAxis] != lastProposedSize[minorAxis]) ||
                    (lastProposedSize[majorAxis] == nil) else {
                return
            }
            for index in childrenPtr.indices {
                childrenPtr[index].majorAxisRangeCache = .init()
            }
            let priorityPtr = UnsafeMutableBufferProjectionPointer(childrenPtr, \.layoutPriority)
            let majorAxisRangeCachePtr = UnsafeMutableBufferProjectionPointer(childrenPtr, \.majorAxisRangeCache)
            var fittingOrderPtr = UnsafeMutableBufferProjectionPointer(childrenPtr, \.fittingOrder)
            func areInDecreasingFittingPriority(i0: Int, i1: Int) -> Bool {
                let priority0 = priorityPtr[i0]
                let priority1 = priorityPtr[i1]
                guard priority0 == priority1 else {
                    return priority0 > priority1
                }
                let i0RangeMin = majorAxisRangeCachePtr[i0].getMin {
                    proxies[i0].lengthThatFits(
                        .init(0, in: majorAxis, by: proposedSize[minorAxis]),
                        in: majorAxis
                    )
                }
                let i0RangeMax = majorAxisRangeCachePtr[i0].getMax {
                    proxies[i0].lengthThatFits(
                        .init(.infinity, in: majorAxis, by: proposedSize[minorAxis]),
                        in: majorAxis
                    )
                }
                let i1RangeMin = majorAxisRangeCachePtr[i1].getMin {
                    proxies[i1].lengthThatFits(
                        .init(0, in: majorAxis, by: proposedSize[minorAxis]),
                        in: majorAxis
                    )
                }
                let i1RangeMax = majorAxisRangeCachePtr[i1].getMax {
                    proxies[i1].lengthThatFits(
                        .init(.infinity, in: majorAxis, by: proposedSize[minorAxis]),
                        in: majorAxis
                    )
                }
                let i0Estimate = _LayoutTraits.FlexibilityEstimate(minLength: i0RangeMin, maxLength: i0RangeMax)
                let i1Estimate = _LayoutTraits.FlexibilityEstimate(minLength: i1RangeMin, maxLength: i1RangeMax)
                return i0Estimate < i1Estimate
            }
            if count <= 32 {
                fittingOrderPtr.insertionSort(by: areInDecreasingFittingPriority(i0:i1:))
            } else {
                fittingOrderPtr.sort(by: areInDecreasingFittingPriority(i0:i1:))
            }
            let firstFittingOrder = fittingOrderPtr[0]
            let firstPriority = priorityPtr[firstFittingOrder]
            for index in childrenPtr.indices.reversed() {
                let fittingOrder = fittingOrderPtr[index]
                guard priorityPtr[fittingOrder] != firstPriority else {
                    continue
                }
                guard majorAxisRangeCachePtr[fittingOrder].min == nil else {
                    continue
                }
                majorAxisRangeCachePtr[fittingOrder].min = proxies[fittingOrder].lengthThatFits(
                    .init(0, in: majorAxis, by: proposedSize[minorAxis]),
                    in: majorAxis
                )
            }
        }

        /// Resizes children that have trailing overflow.
        ///
        /// - Parameter size: The proposed size constraint
        func resizeAnyChildrenWithTrailingOverflow(in size: ProposedViewSize) {
            _openSwiftUIUnimplementedWarning()
        }
    }
}
