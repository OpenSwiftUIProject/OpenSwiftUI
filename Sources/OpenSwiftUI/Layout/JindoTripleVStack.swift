//
//  JindoTripleVStack.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 92DCAEF653F89C7A009F5FFAA858DAF3 (SwiftUI)

//  NOTE: This API's actual availability is between OpenSwiftUI v4.0 and v4.1:
//  @available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
//  @available(macOS, unavailable)

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore

// MARK: - JindoTripleVStack

/// A layout that arranges views in leading, center, trailing, bottom, and
/// notch regions.
///
/// Assign each subview a ``JindoTripleVStack/Position`` with the
/// `jindoPosition(_:)` modifier. The layout uses a
/// ``JindoTripleVStack/Configuration`` to reserve space for the notch and to
/// control how the horizontal regions share the available width.
@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
public struct JindoTripleVStack: Layout {

    // MARK: - JindoTripleVStack.Configuration

    /// The values that configure a Jindo triple vertical stack.
    public struct Configuration {
        /// The size of the region reserved for notch content.
        public var notchSize: CGSize

        var horizontalSizing: HorizontalSizing

        var layoutMargins: EdgeInsets

        var sizing: Sizing

        /// The legacy strategy for distributing horizontal space.
        ///
        /// Use ``JindoTripleVStack/HorizontalSizing`` when creating a
        /// configuration instead.
        @available(*, deprecated, message: "Use horizontalSizing")
        public var mode: HorizontalMode {
            get { .leading }
            set {}
        }

        /// The legacy default insets for the layout.
        ///
        /// Use the `layoutMargins` argument when creating a configuration
        /// instead.
        @available(*, deprecated, message: "Use layoutMargins")
        public var defaultInsets: EdgeInsets {
            get { EdgeInsets() }
            set {}
        }

        /// The horizontal alignment of views in the center region.
        public var centerAlignment: TextAlignment

        /// The horizontal alignment of views in the bottom region.
        public var bottomAlignment: TextAlignment

        /// A fixed vertical distance between adjacent views, or `nil` to
        /// choose spacing automatically.
        public var uniformSpacing: CGFloat?

        /// Creates a configuration with the legacy horizontal layout mode.
        ///
        /// - Parameters:
        ///   - notchSize: The size of the region reserved for notch content.
        ///   - mode: The strategy for distributing horizontal space.
        ///   - defaultInsets: The default edge insets for the layout.
        @available(*, deprecated, renamed: "init(notchSize:mode:layoutMargins:)")
        public init(
            notchSize: CGSize,
            mode: HorizontalMode,
            defaultInsets: EdgeInsets
        ) {
            self.notchSize = notchSize
            horizontalSizing = .leading
            layoutMargins = defaultInsets
            sizing = .v1
            centerAlignment = .center
            bottomAlignment = .leading
            uniformSpacing = nil
        }

        /// Creates a configuration for a Jindo triple vertical stack.
        ///
        /// - Parameters:
        ///   - notchSize: The size of the region reserved for notch content.
        ///   - horizontalSizing: The strategy for distributing space between
        ///     the leading and trailing regions.
        ///   - layoutMargins: The margins surrounding the layout's content.
        public init(
            notchSize: CGSize,
            horizontalSizing: HorizontalSizing,
            layoutMargins: EdgeInsets
        ) {
            self.notchSize = notchSize
            self.horizontalSizing = horizontalSizing
            self.layoutMargins = layoutMargins
            sizing = .v2
            centerAlignment = .center
            bottomAlignment = .leading
            uniformSpacing = nil
        }

        enum Sizing {
            case v1
            case v2
        }
    }

    private let configuration: Configuration

    /// Creates a Jindo triple vertical stack with the specified configuration.
    ///
    /// - Parameter configuration: The values that control the layout.
    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - JindoTripleVStack.Position

    /// A value that assigns a subview to one of the layout's regions.
    public struct Position: Equatable {
        fileprivate enum Region: Hashable {
            case leading
            case trailing
            case center
            case bottom
            case notch
        }

        fileprivate var region: Region

        var leadingInset: CGFloat? = nil

        var trailingInset: CGFloat? = nil
    }

    // MARK: - JindoTripleVStack.VerticalPlacement

    /// A strategy for vertically placing a view relative to the notch.
    public struct VerticalPlacement: Equatable {
        private var rawValue: UInt8

        private init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// The standard vertical placement for the view's assigned region.
        public static let `default` = VerticalPlacement(rawValue: 0)

        /// Places a view below the notch when it is too wide to fit beside it.
        public static let belowNotchIfTooWide = VerticalPlacement(rawValue: 1)
    }

    // MARK: - JindoTripleVStack.HorizontalMode

    /// A legacy strategy for distributing horizontal space.
    ///
    /// Use ``JindoTripleVStack/HorizontalSizing`` instead.
    @available(*, deprecated, message: "Use HorizontalSizing")
    public enum HorizontalMode {
        /// Divides the available horizontal space between both side regions.
        case split

        /// Gives preference to the leading region.
        case leading

        /// Gives preference to the trailing region.
        case trailing
    }

    // MARK: - JindoTripleVStack.HorizontalSizing

    /// A strategy for distributing horizontal space between the leading and
    /// trailing regions.
    public struct HorizontalSizing: Equatable {
        private var rawValue: UInt8

        private init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Lets the layout choose a sizing strategy automatically.
        public static let automatic = HorizontalSizing(rawValue: 0)

        /// Gives preference to the leading region.
        public static let leading = HorizontalSizing(rawValue: 1)

        /// Gives preference to the trailing region.
        public static let trailing = HorizontalSizing(rawValue: 2)

        /// Divides the available horizontal space between both side regions.
        public static let split = HorizontalSizing(rawValue: 3)
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        var implementation = Implementation(configuration: configuration, proxies: subviews)
        let proposal = adjusted(proposal)
        return implementation.sizeThatFits(
            in: FixedProposal(width: proposal.width ?? 0, height: proposal.height)
        )
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var implementation = Implementation(configuration: configuration, proxies: subviews)
        let bounds = adjusted(bounds)
        let proposal = adjusted(proposal)
        implementation.placeSubviews(
            in: bounds,
            proposal: FixedProposal(width: proposal.width ?? 0, height: proposal.height)
        )
    }

    public typealias AnimatableData = EmptyAnimatableData

    public typealias Cache = ()

    private func adjusted(_ proposal: ProposedViewSize) -> ProposedViewSize {
        guard configuration.sizing == .v1 else {
            return proposal
        }
        let margins = configuration.layoutMargins
        return ProposedViewSize(
            width: proposal.width.map { $0 - margins.horizontal },
            height: proposal.height.map { $0 - margins.vertical }
        )
    }

    private func adjusted(_ bounds: CGRect) -> CGRect {
        guard configuration.sizing == .v1 else {
            return bounds
        }
        return bounds.inset(by: configuration.layoutMargins)
    }
}

// MARK: - Public conformances

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack: Sendable {}

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack.VerticalPlacement: Sendable {}

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack.Configuration: Sendable {}

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack.HorizontalMode: Sendable {}

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack.HorizontalSizing: Sendable {}

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack.Position: Sendable {}

// MARK: - JindoTripleVStack.Position extension

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
extension JindoTripleVStack.Position {

    /// The leading region of the layout.
    public static let leading = JindoTripleVStack.Position(region: .leading)

    /// Creates a position in the leading region with an optional inset.
    ///
    /// - Parameter inset: An optional inset from the leading edge.
    /// - Returns: A position in the leading region.
    public static func leading(inset: CGFloat? = nil) -> JindoTripleVStack.Position {
        JindoTripleVStack.Position(region: .leading, leadingInset: inset)
    }

    /// The trailing region of the layout.
    public static let trailing = JindoTripleVStack.Position(region: .trailing)

    /// Creates a position in the trailing region with an optional inset.
    ///
    /// - Parameter inset: An optional inset from the trailing edge.
    /// - Returns: A position in the trailing region.
    public static func trailing(inset: CGFloat? = nil) -> JindoTripleVStack.Position {
        JindoTripleVStack.Position(region: .trailing, trailingInset: inset)
    }

    /// The center region of the layout.
    public static let center = JindoTripleVStack.Position(region: .center)

    /// The region below the leading, center, and trailing regions.
    public static let bottom = JindoTripleVStack.Position(region: .bottom)

    /// Creates a position in the bottom region with optional horizontal
    /// insets.
    ///
    /// - Parameters:
    ///   - leadingInset: An optional inset from the leading edge.
    ///   - trailingInset: An optional inset from the trailing edge.
    /// - Returns: A position in the bottom region.
    public static func bottom(
        leadingInset: CGFloat? = nil,
        trailingInset: CGFloat? = nil
    ) -> JindoTripleVStack.Position {
        JindoTripleVStack.Position(region: .bottom, leadingInset: leadingInset, trailingInset: trailingInset)
    }

    /// The region reserved for notch content.
    public static let notch = JindoTripleVStack.Position(region: .notch)
}

// MARK: - JindoTripleVStack.ContentMargins

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
extension JindoTripleVStack {

    /// Optional per-edge margin overrides for a subview in the layout.
    public struct ContentMargins {
        var top: CGFloat?

        var leading: CGFloat?

        var bottom: CGFloat?

        var trailing: CGFloat?

        /// Creates a set of optional content-margin overrides.
        ///
        /// An edge whose value is `nil` has no explicit override.
        ///
        /// - Parameters:
        ///   - top: An optional override for the top margin.
        ///   - leading: An optional override for the leading margin.
        ///   - bottom: An optional override for the bottom margin.
        ///   - trailing: An optional override for the trailing margin.
        public init(
            top: CGFloat? = nil,
            leading: CGFloat? = nil,
            bottom: CGFloat? = nil,
            trailing: CGFloat? = nil
        ) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
        }
    }
}

@_spi(Jindo)
@available(*, unavailable)
extension JindoTripleVStack.ContentMargins: Sendable {}

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
@available(*, deprecated, message: "Use HorizontalSizing")
extension JindoTripleVStack.HorizontalMode: Equatable {}

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
@available(*, deprecated, message: "Use HorizontalSizing")
extension JindoTripleVStack.HorizontalMode: Hashable {}

// MARK: - Layout values

@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
private struct ContentMarginsKey: LayoutValueKey {
    static let defaultValue: JindoTripleVStack.ContentMargins? = nil
}

@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
private struct PriorityKey: LayoutValueKey {
    static let defaultValue: Double? = nil
}

@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
private struct VerticalPlacementKey: LayoutValueKey {
    static let defaultValue = JindoTripleVStack.VerticalPlacement.default
}

@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
private struct PositionKey: LayoutValueKey {
    static let defaultValue = JindoTripleVStack.Position.bottom
}

extension View {
    /// Assigns this view to a region of a Jindo triple vertical stack.
    ///
    /// Views without this modifier use the bottom position.
    ///
    /// - Parameter position: The region in which the layout places this view.
    /// - Returns: A view with the position value attached.
    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoPosition(
        _ position: JindoTripleVStack.Position
    ) -> some View {
        layoutValue(key: PositionKey.self, value: position)
    }

    /// Sets how a Jindo triple vertical stack vertically places this view.
    ///
    /// - Parameter verticalPlacement: The vertical placement strategy to use.
    /// - Returns: A view with the vertical placement value attached.
    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoVerticalPlacement(
        _ verticalPlacement: JindoTripleVStack.VerticalPlacement
    ) -> some View {
        layoutValue(key: VerticalPlacementKey.self, value: verticalPlacement)
    }

    /// Sets a priority that a Jindo triple vertical stack can use when
    /// resolving its arrangement.
    ///
    /// - Parameter priority: The priority value, or `nil` to remove an
    ///   explicit priority.
    /// - Returns: A view with the priority value attached.
    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoPriority(_ priority: Double?) -> some View {
        layoutValue(key: PriorityKey.self, value: priority)
    }

    /// Sets per-edge content-margin overrides for this view in a Jindo triple
    /// vertical stack.
    ///
    /// - Parameter contentMargins: The margin overrides, or `nil` to clear
    ///   explicit overrides.
    /// - Returns: A view with the content-margin value attached.
    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoContentMargins(
        _ contentMargins: JindoTripleVStack.ContentMargins?
    ) -> some View {
        layoutValue(key: ContentMarginsKey.self, value: contentMargins)
    }
}

// MARK: - Layout implementation [TBA]

@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
extension JindoTripleVStack {
    private struct Header {
        let configuration: Configuration

        let notchIndex: Int?

        let proxies: LayoutSubviews

        var lastProposedSize: FixedProposal

        var stackSize: CGSize

        var stacks: StackIndexedStorage<StackHeader>

        var horizontalSizing: HorizontalSizing

        var horizontalFullWidth: Bool
    }

    private struct MajorAxisGroupState {
        let stack: Stack

        let range: Range<Int>

        var unsizedCount: Int

        var totalAvailable: CGFloat?

        var minHeight: CGFloat?

        var layoutHeight: CGFloat

        var currentMajorAxisPosition: CGFloat

        mutating func consume(_ amount: CGFloat) {
            totalAvailable = totalAvailable.map { $0 - amount }
            unsizedCount -= 1
        }
    }

    struct MajorAxisGroup {
        struct Group {
            let count: Int

            let proposed: CGFloat?
        }

        let count: Int

        var reserved: (before: CGFloat, after: CGFloat)

        var groups: [Group]

        var allGroups: [Group] {
            [Group(count: 0, proposed: reserved.before)]
                + groups
                + [Group(count: 0, proposed: reserved.after)]
        }

        mutating func updateWithSplit(at index: Int, before: CGFloat) {
            if index == 0 {
                reserved.before = max(reserved.before, before)
                let group = groups[0]
                groups[0] = Group(
                    count: group.count,
                    proposed: group.proposed.map { max($0 - before, 0) }
                )
                return
            }

            if index == count {
                let group = groups[0]
                groups[0] = Group(
                    count: group.count,
                    proposed: before - reserved.before
                )
                return
            }

            var remainingCount = index
            var remainingBefore = before - reserved.before
            for groupIndex in groups.indices {
                let group = groups[groupIndex]
                if remainingCount > group.count {
                    remainingCount -= group.count
                    remainingBefore -= group.proposed ?? 0
                    continue
                }

                if remainingCount == group.count {
                    groups[groupIndex] = Group(
                        count: group.count,
                        proposed: group.proposed.map { max(remainingBefore, $0) }
                    )
                    return
                }

                groups[groupIndex] = Group(
                    count: remainingCount,
                    proposed: remainingBefore
                )
                groups.insert(
                    Group(
                        count: group.count - remainingCount,
                        proposed: group.proposed.map {
                            max($0 - remainingBefore, 0)
                        }
                    ),
                    at: groupIndex + 1
                )
                return
            }
        }
    }

    private struct StackHeader {
        let indices: [Int]

        let topPrefix: Int

        let reservedSpacing: (top: CGFloat, bottom: CGFloat)

        var uniformSpacing: CGFloat?

        var accumulatedInternalSpacing: [CGFloat]

        var totalInternalSpacing: CGFloat

        mutating func computeSpacingAndPadding(
            stack: Stack,
            layoutMargins: EdgeInsets,
            horizontalFullWidth: Bool,
            proxies: LayoutSubviews,
            children: inout [Child]
        ) {
            accumulatedInternalSpacing.reserveCapacity(indices.count)

            let baseEdges: Edge.Set
            if horizontalFullWidth {
                baseEdges = .horizontal
            } else if stack == .leading {
                baseEdges = .leading
            } else if stack == .trailing {
                baseEdges = .trailing
            } else {
                baseEdges = []
            }

            var previousIndex = 0
            for (offset, index) in indices.enumerated() {
                let distance: CGFloat
                if offset == 0 {
                    distance = 0
                } else {
                    distance = uniformSpacing ?? proxies[previousIndex].spacing.distance(
                        to: proxies[index].spacing,
                        along: .vertical
                    )
                }
                totalInternalSpacing += distance
                accumulatedInternalSpacing.append(totalInternalSpacing)
                children[index].distanceToPrevious[stack] = distance

                if let margins = proxies[index][ContentMarginsKey.self] {
                    var edges = baseEdges
                    if offset == 0 {
                        edges.insert(.top)
                    }
                    if offset == indices.count - 1 {
                        edges.insert(.bottom)
                    }
                    children[index].padding = EdgeInsets(
                        top: (margins.top ?? layoutMargins.top) - layoutMargins.top,
                        leading: (margins.leading ?? layoutMargins.leading) - layoutMargins.leading,
                        bottom: (margins.bottom ?? layoutMargins.bottom) - layoutMargins.bottom,
                        trailing: (margins.trailing ?? layoutMargins.trailing) - layoutMargins.trailing
                    )
                    children[index].paddingEdges = edges
                }
                previousIndex = index
            }
        }

        func majorAxisGroup(for proposal: CGFloat?) -> MajorAxisGroup {
            MajorAxisGroup(
                count: indices.count,
                reserved: (
                    before: reservedSpacing.top,
                    after: reservedSpacing.bottom
                ),
                groups: [
                    MajorAxisGroup.Group(
                        count: indices.count,
                        proposed: proposal.map {
                            $0 - reservedSpacing.top - reservedSpacing.bottom
                        }
                    ),
                ]
            )
        }
    }

    private struct StackIndexedStorage<A> {
        var leading: A

        var center: A

        var trailing: A

        subscript(stack: Stack) -> A {
            get {
                switch stack {
                case .leading: leading
                case .center: center
                case .trailing: trailing
                }
            }
            set {
                switch stack {
                case .leading: leading = newValue
                case .center: center = newValue
                case .trailing: trailing = newValue
                }
            }
        }
    }

    fileprivate struct FixedProposal: Equatable {
        var width: CGFloat

        var height: CGFloat?
    }

    private struct Child {
        var layoutPriority: Double

        var majorAxisRangeCache: MajorAxisRangeCache

        var distanceToPrevious: StackIndexedStorage<CGFloat?>

        var majorAxisGroup: StackIndexedStorage<Int?>

        var geometry: ViewGeometry

        var width: CGFloat?

        var hasBeenReduced: Bool

        var padding: EdgeInsets

        var paddingEdges: Edge.Set

        mutating func reduceWidth(to width: CGFloat, edge: Edge.Set) {
            self.width = width
            majorAxisRangeCache = MajorAxisRangeCache()
            hasBeenReduced = true
            paddingEdges.remove(.leading)
            paddingEdges.remove(.trailing)
            paddingEdges.insert(edge)
        }
    }

    private enum Stack: UInt8, CaseIterable {
        case leading
        case center
        case trailing
    }

    private struct MajorAxisRangeCache {
        var min: CGFloat?

        var max: CGFloat?

        mutating func getMin(_ makeValue: () -> CGFloat) -> CGFloat {
            guard let min else {
                let min = makeValue()
                self.min = min
                return min
            }
            return min
        }

        mutating func getMax(_ makeValue: () -> CGFloat) -> CGFloat {
            guard let max else {
                let max = makeValue()
                self.max = max
                return max
            }
            return max
        }
    }

    private struct ProposedMetrics {
        let leadingWidth: CGFloat

        let trailingWidth: CGFloat

        let centerWidth: CGFloat

        let fullWidth: CGFloat

        let leadingAvailableWidth: CGFloat

        let trailingAvailableWidth: CGFloat

        init(
            stacks: StackIndexedStorage<StackHeader>,
            notchSize: CGSize,
            centerWidth: CGFloat,
            horizontalSizing: HorizontalSizing,
            fullWidth: Bool,
            leadingCenterSpacing: CGFloat,
            trailingCenterSpacing: CGFloat,
            leadingTrailingSpacing: CGFloat,
            proposal: FixedProposal
        ) {
            _ = stacks

            let minimumCenterWidth = notchSize.width - 2 * max(
                leadingCenterSpacing,
                trailingCenterSpacing
            )
            let centerWidth = max(centerWidth, minimumCenterWidth)
            let halfRemainder = (proposal.width - centerWidth) / 2
            let leadingAvailableWidth = max(
                0,
                halfRemainder - leadingCenterSpacing
            )
            let trailingAvailableWidth = max(
                0,
                halfRemainder - trailingCenterSpacing
            )
            let availableWidth = max(
                0,
                proposal.width - (fullWidth ? 0 : leadingTrailingSpacing)
            )

            let leadingWidth: CGFloat
            let trailingWidth: CGFloat
            if fullWidth {
                if horizontalSizing == .leading {
                    leadingWidth = availableWidth
                    trailingWidth = 0
                } else if horizontalSizing == .trailing {
                    leadingWidth = 0
                    trailingWidth = availableWidth
                } else {
                    leadingWidth = availableWidth / 2
                    trailingWidth = availableWidth / 2
                }
            } else if horizontalSizing == .leading {
                leadingWidth = max(0, availableWidth - trailingAvailableWidth)
                trailingWidth = trailingAvailableWidth
            } else if horizontalSizing == .trailing {
                leadingWidth = leadingAvailableWidth
                trailingWidth = max(0, availableWidth - leadingAvailableWidth)
            } else {
                leadingWidth = availableWidth / 2
                trailingWidth = availableWidth / 2
            }

            self.leadingWidth = leadingWidth
            self.trailingWidth = trailingWidth
            self.centerWidth = centerWidth
            self.fullWidth = max(0, proposal.width)
            self.leadingAvailableWidth = leadingAvailableWidth
            self.trailingAvailableWidth = trailingAvailableWidth
        }
    }

    fileprivate struct Implementation {
        private var header: Header

        private var children: [Child]

        private var fittingOrder: [Int]

        fileprivate init(configuration: Configuration, proxies: LayoutSubviews) {
            func indices(in region: Position.Region) -> [Int] {
                proxies.indices.filter {
                    proxies[$0][PositionKey.self].region == region
                }
            }

            let leadingIndices = indices(in: .leading)
            let centerIndices = indices(in: .center)
            let trailingIndices = indices(in: .trailing)
            let bottomIndices = indices(in: .bottom)
            _ = indices(in: .notch)
            let notchIndex = indices(in: .notch).first

            header = Header(
                configuration: configuration,
                notchIndex: notchIndex,
                proxies: proxies,
                lastProposedSize: FixedProposal(
                    width: -.infinity,
                    height: -.infinity
                ),
                stackSize: .zero,
                stacks: StackIndexedStorage(
                    leading: StackHeader(
                        indices: leadingIndices + bottomIndices,
                        topPrefix: leadingIndices.count,
                        reservedSpacing: (top: 0, bottom: 0),
                        uniformSpacing: configuration.uniformSpacing,
                        accumulatedInternalSpacing: [],
                        totalInternalSpacing: 0
                    ),
                    center: StackHeader(
                        indices: centerIndices + bottomIndices,
                        topPrefix: centerIndices.count,
                        reservedSpacing: (
                            top: configuration.notchSize.height - configuration.layoutMargins.top,
                            bottom: 0
                        ),
                        uniformSpacing: configuration.uniformSpacing,
                        accumulatedInternalSpacing: [],
                        totalInternalSpacing: 0
                    ),
                    trailing: StackHeader(
                        indices: trailingIndices + bottomIndices,
                        topPrefix: trailingIndices.count,
                        reservedSpacing: (top: 0, bottom: 0),
                        uniformSpacing: configuration.uniformSpacing,
                        accumulatedInternalSpacing: [],
                        totalInternalSpacing: 0
                    )
                ),
                horizontalSizing: .split,
                horizontalFullWidth: false
            )
            children = []
            fittingOrder = []

            determineHorizontalMode()
            makeChildren()
        }

        fileprivate mutating func sizeThatFits(in proposal: FixedProposal) -> CGSize {
            if header.lastProposedSize != proposal {
                header.lastProposedSize = proposal
                header.stackSize = sizeAndPlaceChildren(in: proposal, bounds: nil)
            }
            return header.stackSize
        }

        fileprivate mutating func placeSubviews(
            in bounds: CGRect,
            proposal: FixedProposal
        ) {
            header.lastProposedSize = proposal
            header.stackSize = sizeAndPlaceChildren(in: proposal, bounds: bounds)
        }

        private mutating func determineHorizontalMode() {
            let configuredSizing = header.configuration.horizontalSizing
            let horizontalSizing: HorizontalSizing
            if configuredSizing == .automatic {
                let leadingPriority = header.stacks.leading.indices
                    .prefix(header.stacks.leading.topPrefix)
                    .compactMap { header.proxies[$0][PriorityKey.self] }
                    .max() ?? 0
                let trailingPriority = header.stacks.trailing.indices
                    .prefix(header.stacks.trailing.topPrefix)
                    .compactMap { header.proxies[$0][PriorityKey.self] }
                    .max() ?? 0

                if leadingPriority > trailingPriority {
                    horizontalSizing = .leading
                } else if leadingPriority < trailingPriority {
                    horizontalSizing = .trailing
                } else {
                    horizontalSizing = .split
                }
            } else {
                horizontalSizing = configuredSizing
            }

            if header.stacks.trailing.topPrefix == 0 {
                header.horizontalSizing = .leading
                header.horizontalFullWidth = true
            } else if header.stacks.leading.topPrefix == 0 {
                header.horizontalSizing = .trailing
                header.horizontalFullWidth = true
            } else {
                header.horizontalSizing = horizontalSizing
                header.horizontalFullWidth = false
            }
        }

        private mutating func makeChildren() {
            children.reserveCapacity(header.proxies.count)
            fittingOrder.reserveCapacity(header.proxies.count)

            for index in header.proxies.indices {
                children.append(
                    Child(
                        layoutPriority: header.proxies[index].priority,
                        majorAxisRangeCache: MajorAxisRangeCache(),
                        distanceToPrevious: StackIndexedStorage(
                            leading: nil,
                            center: nil,
                            trailing: nil
                        ),
                        majorAxisGroup: StackIndexedStorage(
                            leading: nil,
                            center: nil,
                            trailing: nil
                        ),
                        geometry: .invalidValue,
                        width: nil,
                        hasBeenReduced: false,
                        padding: EdgeInsets(),
                        paddingEdges: []
                    )
                )
                fittingOrder.append(index)
            }

            for stack in Stack.allCases {
                var stackHeader = header.stacks[stack]
                stackHeader.computeSpacingAndPadding(
                    stack: stack,
                    layoutMargins: header.configuration.layoutMargins,
                    horizontalFullWidth: header.horizontalFullWidth,
                    proxies: header.proxies,
                    children: &children
                )
                header.stacks[stack] = stackHeader
            }
        }

        private mutating func sizeAndPlaceChildren(
            in proposal: FixedProposal,
            bounds: CGRect?
        ) -> CGSize {
            let leadingMinWidth = computeMinWidth(of: .leading, in: proposal)
            let trailingMinWidth = computeMinWidth(of: .trailing, in: proposal)

            let leadingSpacing = spacing(.leading, axis: .horizontal)
            let trailingSpacing = spacing(.trailing, axis: .horizontal)
            let centerSpacing = spacing(.center, axis: .horizontal)
            let leadingCenterSpacing = leadingSpacing.distance(
                to: centerSpacing,
                along: .horizontal
            )
            let trailingCenterSpacing = trailingSpacing.distance(
                to: centerSpacing,
                along: .horizontal
            )
            let leadingTrailingSpacing = leadingSpacing.distance(
                to: trailingSpacing,
                along: .horizontal
            )

            let centerSpacingWidth = 2 * max(
                leadingCenterSpacing,
                trailingCenterSpacing
            )
            let minimumCenterWidth = header.configuration.notchSize.width
                - centerSpacingWidth
            let centerProposalWidth = max(
                minimumCenterWidth,
                proposal.width
                    - 2 * max(leadingMinWidth, trailingMinWidth)
                    - centerSpacingWidth
            )
            let centerWidth = header.stacks.center.indices
                .prefix(header.stacks.center.topPrefix)
                .map {
                    header.proxies[$0].sizeThatFits(
                        ProposedViewSize(
                            width: centerProposalWidth,
                            height: proposal.height
                        )
                    ).width
                }
                .max() ?? 0
            let metrics = ProposedMetrics(
                stacks: header.stacks,
                notchSize: header.configuration.notchSize,
                centerWidth: centerWidth,
                horizontalSizing: header.horizontalSizing,
                fullWidth: header.horizontalFullWidth,
                leadingCenterSpacing: leadingCenterSpacing,
                trailingCenterSpacing: trailingCenterSpacing,
                leadingTrailingSpacing: leadingTrailingSpacing,
                proposal: proposal
            )

            for index in header.stacks.leading.indices
                .prefix(header.stacks.leading.topPrefix)
            {
                children[index].width = metrics.leadingWidth
            }
            for index in header.stacks.center.indices
                .prefix(header.stacks.center.topPrefix)
            {
                children[index].width = metrics.centerWidth
            }
            for index in header.stacks.trailing.indices
                .prefix(header.stacks.trailing.topPrefix)
            {
                children[index].width = metrics.trailingWidth
            }
            for index in header.stacks.leading.indices
                .dropFirst(header.stacks.leading.topPrefix)
            {
                children[index].width = metrics.fullWidth
            }

            prioritizeAndSizeChildren(in: proposal, resetCache: true)
            equalizeHeightOfLeadingAndTrailing(in: proposal)

            var remainingResizePasses = max(
                header.stacks.leading.topPrefix,
                header.stacks.trailing.topPrefix
            )
            while remainingResizePasses > 0 {
                guard resizeChildrenAdjacentToNotch(
                    in: proposal,
                    metrics: metrics
                ) else {
                    break
                }
                prioritizeAndSizeChildren(in: proposal, resetCache: false)
                equalizeHeightOfLeadingAndTrailing(in: proposal)
                remainingResizePasses -= 1
            }

            pushBelowNotchIfNeeded(in: proposal, metrics: metrics)

            if let bounds {
                place(
                    indices: header.stacks.leading.indices
                        .prefix(header.stacks.leading.topPrefix),
                    of: .leading,
                    minorAxisAnchor: 0,
                    bounds: bounds
                )
                place(
                    indices: header.stacks.trailing.indices
                        .prefix(header.stacks.trailing.topPrefix),
                    of: .trailing,
                    minorAxisAnchor: 1,
                    bounds: bounds
                )

                let centerBounds = CGRect(
                    x: bounds.midX - header.configuration.notchSize.width / 2,
                    y: bounds.minY,
                    width: header.configuration.notchSize.width,
                    height: bounds.height
                )
                place(
                    indices: header.stacks.center.indices
                        .prefix(header.stacks.center.topPrefix),
                    of: .center,
                    minorAxisAnchor: header.configuration.centerAlignment.value,
                    bounds: centerBounds
                )
                place(
                    indices: header.stacks.leading.indices
                        .suffix(from: header.stacks.leading.topPrefix),
                    of: .leading,
                    minorAxisAnchor: header.configuration.bottomAlignment.value,
                    bounds: bounds
                )

                if let notchIndex = header.notchIndex {
                    var notchChild = children[notchIndex]
                    resize(
                        &notchChild,
                        proposal: ProposedViewSize(
                            width: header.configuration.notchSize.width,
                            height: header.configuration.notchSize.height
                        ),
                        proxy: header.proxies[notchIndex]
                    )
                    children[notchIndex] = notchChild
                    var geometry = notchChild.geometry
                    geometry.origin.x = bounds.midX - geometry.dimensions.width / 2
                    geometry.origin.y = bounds.minY
                        - header.configuration.layoutMargins.top
                    header.proxies[notchIndex].place(
                        in: geometry,
                        layoutDirection: header.proxies.layoutDirection
                    )
                }
            }

            return header.stackSize
        }

        private func resize(
            _ child: inout Child,
            proposal: ProposedViewSize,
            proxy: LayoutSubview
        ) {
            let padding = child.padding.in(child.paddingEdges)
            let childProposal = ProposedViewSize(
                width: proposal.width.map { $0 - padding.horizontal },
                height: proposal.height.map { $0 - padding.vertical }
            )
            var dimensions = proxy.dimensions(in: childProposal)
            dimensions.size.width += padding.horizontal
            dimensions.size.height += padding.vertical
            child.geometry = ViewGeometry(origin: .zero, dimensions: dimensions)
        }

        private mutating func prioritize(resetCache: Bool) {
            guard !fittingOrder.isEmpty else {
                return
            }

            if resetCache {
                for index in children.indices {
                    children[index].majorAxisRangeCache = MajorAxisRangeCache()
                }
            }

            var order = fittingOrder
            func areInDecreasingFittingPriority(_ index0: Int, _ index1: Int) -> Bool {
                let priority0 = children[index0].layoutPriority
                let priority1 = children[index1].layoutPriority
                guard priority0 == priority1 else {
                    return priority0 > priority1
                }

                let width0 = children[index0].width
                let min0 = children[index0].majorAxisRangeCache.getMin {
                    header.proxies[index0].lengthThatFits(
                        ProposedViewSize(0, in: .vertical, by: width0),
                        in: .vertical
                    )
                }
                let max0 = children[index0].majorAxisRangeCache.getMax {
                    header.proxies[index0].lengthThatFits(
                        ProposedViewSize(.infinity, in: .vertical, by: width0),
                        in: .vertical
                    )
                }
                let width1 = children[index1].width
                let min1 = children[index1].majorAxisRangeCache.getMin {
                    header.proxies[index1].lengthThatFits(
                        ProposedViewSize(0, in: .vertical, by: width1),
                        in: .vertical
                    )
                }
                let max1 = children[index1].majorAxisRangeCache.getMax {
                    header.proxies[index1].lengthThatFits(
                        ProposedViewSize(.infinity, in: .vertical, by: width1),
                        in: .vertical
                    )
                }
                let estimate0 = _LayoutTraits.FlexibilityEstimate(
                    minLength: min0,
                    maxLength: max0
                )
                let estimate1 = _LayoutTraits.FlexibilityEstimate(
                    minLength: min1,
                    maxLength: max1
                )
                return estimate0 < estimate1
            }

            if order.count <= 32 {
                order.insertionSort(by: areInDecreasingFittingPriority)
            } else {
                order.sort(by: areInDecreasingFittingPriority)
            }
            fittingOrder = order

            let firstPriority = children[fittingOrder[0]].layoutPriority
            for orderIndex in fittingOrder.indices.reversed() {
                let childIndex = fittingOrder[orderIndex]
                guard children[childIndex].layoutPriority != firstPriority else {
                    break
                }
                guard children[childIndex].majorAxisRangeCache.min == nil else {
                    continue
                }
                children[childIndex].majorAxisRangeCache.min =
                    header.proxies[childIndex].lengthThatFits(
                        ProposedViewSize(
                            0,
                            in: .vertical,
                            by: children[childIndex].width
                        ),
                        in: .vertical
                    )
            }
        }

        private func spacing(_ stack: Stack, axis: Axis) -> ViewSpacing {
            let direction = header.proxies.layoutDirection
            let stackHeader = header.stacks[stack]
            guard !stackHeader.indices.isEmpty else {
                return ViewSpacing(.zero, layoutDirection: direction)
            }
            var spacing = ViewSpacing(
                Spacing(minima: [:]),
                layoutDirection: direction
            )
            for (offset, index) in stackHeader.indices.enumerated() {
                var edges: Edge.Set = axis == .horizontal ? .vertical : .horizontal
                if offset == 0 {
                    edges.insert(axis == .horizontal ? .leading : .top)
                }
                if offset == stackHeader.indices.count - 1 {
                    edges.insert(axis == .horizontal ? .trailing : .bottom)
                }
                spacing.formUnion(header.proxies[index].spacing, edges: edges)
            }
            return spacing
        }

        private func computeMinWidth(
            of stack: Stack,
            in proposal: FixedProposal
        ) -> CGFloat {
            let stackHeader = header.stacks[stack]
            return stackHeader.indices
                .prefix(stackHeader.topPrefix)
                .lazy
                .filter {
                    header.proxies[$0][VerticalPlacementKey.self]
                        != .belowNotchIfTooWide
                }
                .map {
                    header.proxies[$0].sizeThatFits(
                        ProposedViewSize(width: 0, height: proposal.height)
                    ).width
                }
                .max() ?? 0
        }

        private mutating func prioritizeAndSizeChildren(
            in proposal: FixedProposal,
            resetCache: Bool
        ) {
            prioritize(resetCache: resetCache)
            resize(
                in: proposal,
                groups: StackIndexedStorage(
                    leading: header.stacks.leading.majorAxisGroup(for: proposal.height),
                    center: header.stacks.center.majorAxisGroup(for: proposal.height),
                    trailing: header.stacks.trailing.majorAxisGroup(for: proposal.height)
                )
            )
        }

        private mutating func equalizeHeightOfLeadingAndTrailing(
            in proposal: FixedProposal
        ) {
            equalizeHeightOfLeadingAndTrailing(
                in: proposal,
                leading: header.stacks.leading.majorAxisGroup(for: proposal.height),
                trailing: header.stacks.trailing.majorAxisGroup(for: proposal.height)
            )
        }

        private mutating func pushBelowNotchIfNeeded(
            in proposal: FixedProposal,
            metrics: ProposedMetrics
        ) {
            let centerHeight = bottomOf(
                previousChild: header.stacks.center.topPrefix,
                in: .center,
                includeSpacing: false
            )
            let leadingIndex = indexToPushBelowNotch(
                in: .leading,
                availableWidth: metrics.leadingAvailableWidth,
                centerHeight: centerHeight
            )
            let trailingIndex = indexToPushBelowNotch(
                in: .trailing,
                availableWidth: metrics.trailingAvailableWidth,
                centerHeight: centerHeight
            )
            guard leadingIndex != nil || trailingIndex != nil else {
                return
            }

            var leading = header.stacks.leading.majorAxisGroup(for: proposal.height)
            var trailing = header.stacks.trailing.majorAxisGroup(for: proposal.height)
            if let leadingIndex {
                leading.updateWithSplit(
                    at: leadingIndex,
                    before: centerHeight
                        + distanceToCenterBottom(from: leadingIndex, stack: .leading)
                        - distanceToPrevious(leadingIndex, stack: .leading)
                )
            }
            if let trailingIndex {
                trailing.updateWithSplit(
                    at: trailingIndex,
                    before: centerHeight
                        + distanceToCenterBottom(from: trailingIndex, stack: .trailing)
                        - distanceToPrevious(trailingIndex, stack: .trailing)
                )
            }

            resize(
                in: proposal,
                groups: StackIndexedStorage(
                    leading: leading,
                    center: header.stacks.center.majorAxisGroup(for: proposal.height),
                    trailing: trailing
                )
            )
            equalizeHeightOfLeadingAndTrailing(
                in: proposal,
                leading: leading,
                trailing: trailing
            )
        }

        private mutating func equalizeHeightOfLeadingAndTrailing(
            in proposal: FixedProposal,
            leading: MajorAxisGroup,
            trailing: MajorAxisGroup
        ) {
            let leadingPrefix = header.stacks.leading.topPrefix
            let trailingPrefix = header.stacks.trailing.topPrefix
            let leadingBottom = bottomOf(
                previousChild: leadingPrefix,
                in: .leading,
                includeSpacing: true
            )
            let trailingBottom = bottomOf(
                previousChild: trailingPrefix,
                in: .trailing,
                includeSpacing: true
            )
            guard leadingBottom != trailingBottom else {
                return
            }

            let bottom = max(leadingBottom, trailingBottom)
            var leading = leading
            var trailing = trailing
            leading.updateWithSplit(
                at: leadingPrefix,
                before: bottom - distanceToPrevious(leadingPrefix, stack: .leading)
            )
            trailing.updateWithSplit(
                at: trailingPrefix,
                before: bottom - distanceToPrevious(trailingPrefix, stack: .trailing)
            )
            resize(
                in: proposal,
                groups: StackIndexedStorage(
                    leading: leading,
                    center: header.stacks.center.majorAxisGroup(for: proposal.height),
                    trailing: trailing
                )
            )
        }

        private func bottomOf(
            previousChild: Int,
            in stack: Stack,
            includeSpacing: Bool
        ) -> CGFloat {
            let stackHeader = header.stacks[stack]
            guard !stackHeader.indices.isEmpty, previousChild != 0 else {
                return stackHeader.reservedSpacing.top
            }

            let previousIndex = stackHeader.indices[previousChild - 1]
            let previous = children[previousIndex]
            var bottom = previous.geometry.origin.y + previous.geometry.dimensions.height
            if includeSpacing, previousChild < stackHeader.indices.count {
                bottom += children[stackHeader.indices[previousChild]]
                    .distanceToPrevious[stack]!
            }
            return bottom
        }

        private func distanceToPrevious(_ offset: Int, stack: Stack) -> CGFloat {
            let stackHeader = header.stacks[stack]
            guard stackHeader.indices.count > offset else {
                return 0
            }
            return children[stackHeader.indices[offset]].distanceToPrevious[stack]!
        }

        private mutating func resize(
            in proposal: FixedProposal,
            groups: StackIndexedStorage<MajorAxisGroup>
        ) {
            var states = prepareChildren(with: groups)

            var batchStart = fittingOrder.startIndex
            while batchStart != fittingOrder.endIndex {
                let priority = children[fittingOrder[batchStart]].layoutPriority
                var batchEnd = fittingOrder.index(after: batchStart)
                while batchEnd != fittingOrder.endIndex,
                      children[fittingOrder[batchEnd]].layoutPriority == priority
                {
                    batchEnd = fittingOrder.index(after: batchEnd)
                }

                let adjustmentIndices: Range<Int>
                let subtractMinimum: Bool
                if batchStart == fittingOrder.startIndex {
                    adjustmentIndices = batchEnd ..< fittingOrder.endIndex
                    subtractMinimum = true
                } else {
                    adjustmentIndices = batchStart ..< batchEnd
                    subtractMinimum = false
                }
                for orderIndex in adjustmentIndices {
                    let childIndex = fittingOrder[orderIndex]
                    let minimum = children[childIndex].majorAxisRangeCache.min!
                    for stack in Stack.allCases {
                        guard let stateIndex = children[childIndex].majorAxisGroup[stack]
                        else {
                            continue
                        }
                        states[stateIndex].totalAvailable = states[stateIndex]
                            .totalAvailable.map {
                                subtractMinimum ? $0 - minimum : $0 + minimum
                            }
                    }
                }

                for stateIndex in states.indices {
                    states[stateIndex].unsizedCount = 0
                }
                for orderIndex in batchStart ..< batchEnd {
                    let childIndex = fittingOrder[orderIndex]
                    for stack in Stack.allCases {
                        if let stateIndex = children[childIndex].majorAxisGroup[stack] {
                            states[stateIndex].unsizedCount += 1
                        }
                    }
                }

                for orderIndex in batchStart ..< batchEnd {
                    let childIndex = fittingOrder[orderIndex]
                    var availableShares: [CGFloat] = []
                    for stack in Stack.allCases {
                        guard let stateIndex = children[childIndex].majorAxisGroup[stack],
                              let totalAvailable = states[stateIndex].totalAvailable
                        else {
                            continue
                        }
                        availableShares.append(
                            max(
                                totalAvailable / CGFloat(states[stateIndex].unsizedCount),
                                0
                            )
                        )
                    }

                    let childProposal = ProposedViewSize(
                        availableShares.min(),
                        in: .vertical,
                        by: children[childIndex].width
                    )
                    var child = children[childIndex]
                    resize(
                        &child,
                        proposal: childProposal,
                        proxy: header.proxies[childIndex]
                    )
                    children[childIndex] = child
                    let height = child.geometry.dimensions.height
                    let consumedHeight = height.isNaN ? 0 : height
                    for stack in Stack.allCases {
                        if let stateIndex = children[childIndex].majorAxisGroup[stack] {
                            states[stateIndex].consume(consumedHeight)
                        }
                    }
                }

                batchStart = batchEnd
            }

            var stackExtents = StackIndexedStorage<CGFloat>(
                leading: 0,
                center: 0,
                trailing: 0
            )
            var sharedTopPrefixPosition: CGFloat = 0
            for stateIndex in states.indices {
                var state = states[stateIndex]
                let stack = state.stack
                let stackHeader = header.stacks[stack]
                state.currentMajorAxisPosition = stackExtents[stack]
                if state.range.lowerBound == stackHeader.topPrefix {
                    sharedTopPrefixPosition = max(
                        sharedTopPrefixPosition,
                        stackExtents[stack]
                            + distanceToPrevious(state.range.lowerBound, stack: stack)
                    )
                }

                var layoutHeight: CGFloat = 0
                for offset in state.range {
                    let childIndex = stackHeader.indices[offset]
                    layoutHeight += children[childIndex].distanceToPrevious[stack]!
                    layoutHeight += children[childIndex].geometry.dimensions.height
                }
                state.layoutHeight = layoutHeight
                stackExtents[stack] += max(state.minHeight ?? 0, layoutHeight)
                states[stateIndex] = state
            }

            var adjustedExtents = StackIndexedStorage<CGFloat>(
                leading: 0,
                center: 0,
                trailing: 0
            )
            for stateIndex in states.indices {
                var state = states[stateIndex]
                let stack = state.stack
                let stackHeader = header.stacks[stack]
                if state.range.lowerBound == stackHeader.topPrefix {
                    let firstSpacing: CGFloat
                    if stackHeader.topPrefix < stackHeader.indices.count {
                        firstSpacing = children[stackHeader.indices[stackHeader.topPrefix]]
                            .distanceToPrevious[stack]!
                    } else {
                        firstSpacing = 0
                    }
                    adjustedExtents[stack] = sharedTopPrefixPosition - firstSpacing
                }
                state.currentMajorAxisPosition = adjustedExtents[stack]
                adjustedExtents[stack] += max(
                    state.minHeight ?? 0,
                    state.layoutHeight
                )
                states[stateIndex] = state
            }

            var resultHeight: CGFloat = 0
            let order = placementOrder
            for childIndex in order {
                guard header.notchIndex != childIndex else {
                    continue
                }

                var positions: [CGFloat] = []
                for stack in Stack.allCases {
                    guard let stateIndex = children[childIndex].majorAxisGroup[stack]
                    else {
                        continue
                    }
                    positions.append(
                        children[childIndex].distanceToPrevious[stack]!
                            + states[stateIndex].currentMajorAxisPosition
                    )
                }
                let position = positions.max() ?? 0
                children[childIndex].geometry.origin.y = position
                let bottom = position + children[childIndex].geometry.dimensions.height
                for stack in Stack.allCases {
                    if let stateIndex = children[childIndex].majorAxisGroup[stack] {
                        states[stateIndex].currentMajorAxisPosition = bottom
                    }
                }
                resultHeight = max(resultHeight, bottom)
            }

            header.stackSize = CGSize(width: proposal.width, height: resultHeight)
        }

        private mutating func prepareChildren(
            with groups: StackIndexedStorage<MajorAxisGroup>
        ) -> [MajorAxisGroupState] {
            var result: [MajorAxisGroupState] = []
            result.reserveCapacity(9)

            for stack in Stack.allCases {
                var start = 0
                for group in groups[stack].allGroups {
                    let end = start + group.count
                    let stateIndex = result.count
                    for offset in start ..< end {
                        let childIndex = header.stacks[stack].indices[offset]
                        children[childIndex].majorAxisGroup[stack] = stateIndex
                    }

                    let totalAvailable = group.proposed.map { proposed in
                        let internalSpacing: CGFloat
                        if start == end {
                            internalSpacing = 0
                        } else {
                            let accumulated = header.stacks[stack]
                                .accumulatedInternalSpacing
                            internalSpacing = accumulated[end - 1]
                                - (start > 0 ? accumulated[start - 1] : 0)
                        }
                        return proposed - internalSpacing
                    }
                    result.append(
                        MajorAxisGroupState(
                            stack: stack,
                            range: start ..< end,
                            unsizedCount: 0,
                            totalAvailable: totalAvailable,
                            minHeight: group.proposed,
                            layoutHeight: 0,
                            currentMajorAxisPosition: 0
                        )
                    )
                    start = end
                }
            }
            return result
        }

        private func distanceToCenterBottom(from offset: Int, stack: Stack) -> CGFloat {
            let centerHeader = header.stacks.center
            guard let centerBottom = centerHeader.indices
                .prefix(centerHeader.topPrefix)
                .last
            else {
                return 0
            }

            let childIndex = header.stacks[stack].indices[offset]
            return header.proxies[childIndex].spacing.distance(
                to: header.proxies[centerBottom].spacing,
                along: .vertical
            )
        }

        private var placementOrder: some Sequence<Int> {
            var result = header.stacks.leading.indices
                .prefix(header.stacks.leading.topPrefix)
            result.append(
                contentsOf: header.stacks.center.indices
                    .prefix(header.stacks.center.topPrefix)
            )
            result.append(
                contentsOf: header.stacks.trailing.indices
                    .prefix(header.stacks.trailing.topPrefix)
            )
            result.append(
                contentsOf: header.stacks.leading.indices
                    .suffix(from: header.stacks.leading.topPrefix)
            )
            return result
        }

        private func shouldPushBelowIfTooWide(_ childIndex: Int) -> Bool {
            header.proxies[childIndex][VerticalPlacementKey.self]
                == .belowNotchIfTooWide
        }

        private func isTooWideForNotch(
            _ childIndex: Int,
            availableWidth: CGFloat
        ) -> Bool {
            children[childIndex].geometry.dimensions.width > availableWidth
        }

        private func indexToPushBelowNotch(
            in stack: Stack,
            availableWidth: CGFloat?,
            centerHeight: CGFloat
        ) -> Int? {
            guard let availableWidth else {
                return nil
            }

            let stackHeader = header.stacks[stack]
            return (0 ..< stackHeader.topPrefix).first { offset in
                let childIndex = stackHeader.indices[offset]
                return isTooWideForNotch(
                    childIndex,
                    availableWidth: availableWidth
                )
                    && shouldPushBelowIfTooWide(childIndex)
                    && bottomOf(
                        previousChild: offset,
                        in: stack,
                        includeSpacing: true
                    ) < centerHeight + distanceToCenterBottom(from: offset, stack: stack)
            }
        }

        private func indexToResizeInNotch(
            in stack: Stack,
            availableWidth: CGFloat?,
            centerHeight: CGFloat
        ) -> Int? {
            guard let availableWidth else {
                return nil
            }

            let stackHeader = header.stacks[stack]
            for offset in 0 ..< stackHeader.topPrefix {
                let childIndex = stackHeader.indices[offset]
                if shouldPushBelowIfTooWide(childIndex) {
                    break
                }
                if isTooWideForNotch(
                    childIndex,
                    availableWidth: availableWidth
                ),
                    !children[childIndex].hasBeenReduced,
                    bottomOf(
                        previousChild: offset,
                        in: stack,
                        includeSpacing: true
                    ) < centerHeight + distanceToCenterBottom(from: offset, stack: stack)
                {
                    return offset
                }
            }
            return nil
        }

        private mutating func resizeChildrenAdjacentToNotch(
            in proposal: FixedProposal,
            metrics: ProposedMetrics
        ) -> Bool {
            _ = proposal

            let centerHeight = bottomOf(
                previousChild: header.stacks.center.topPrefix,
                in: .center,
                includeSpacing: false
            )
            let leadingIndex = indexToResizeInNotch(
                in: .leading,
                availableWidth: metrics.leadingAvailableWidth,
                centerHeight: centerHeight
            )
            let trailingIndex = indexToResizeInNotch(
                in: .trailing,
                availableWidth: metrics.trailingAvailableWidth,
                centerHeight: centerHeight
            )
            guard leadingIndex != nil || trailingIndex != nil else {
                return false
            }

            if let leadingIndex {
                let childIndex = header.stacks.leading.indices[leadingIndex]
                children[childIndex].reduceWidth(
                    to: metrics.leadingAvailableWidth,
                    edge: .leading
                )
            }
            if let trailingIndex {
                let childIndex = header.stacks.trailing.indices[trailingIndex]
                children[childIndex].reduceWidth(
                    to: metrics.trailingAvailableWidth,
                    edge: .trailing
                )
            }
            return true
        }

        private func place(
            indices: ArraySlice<Int>,
            of stack: Stack,
            minorAxisAnchor: CGFloat,
            bounds: CGRect
        ) {
            _ = stack

            let layoutDirection = header.proxies.layoutDirection
            for index in indices {
                let child = children[index]
                let padding = child.padding.in(child.paddingEdges)
                var geometry = child.geometry
                geometry.dimensions.size.width -= padding.horizontal
                geometry.dimensions.size.height -= padding.vertical
                geometry.origin.y += bounds.minY + padding.top
                geometry.origin.x = padding.leading
                    + (bounds.width - geometry.dimensions.width) * minorAxisAnchor
                geometry.finalizeLayoutDirection(
                    layoutDirection,
                    parentSize: bounds.size
                )
                geometry.origin.x += bounds.minX
                header.proxies[index].place(
                    in: geometry,
                    layoutDirection: layoutDirection
                )
            }
        }
    }
}
