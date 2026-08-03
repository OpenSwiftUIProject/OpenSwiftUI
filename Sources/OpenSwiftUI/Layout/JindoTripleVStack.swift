//
//  JindoTripleVStack.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 92DCAEF653F89C7A009F5FFAA858DAF3 (SwiftUI)

//  NOTE: This API's actual availability is between OpenSwiftUI v4.0 and v4.1:
//  @available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
//  @available(macOS, unavailable)

public import OpenSwiftUICore

// MARK: - JindoTripleVStack [TBA]

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
public struct JindoTripleVStack: Layout {

    // MARK: - JindoTripleVStack.Configuration

    public struct Configuration {
        public var notchSize: CGSize

        var horizontalSizing: HorizontalSizing

        var layoutMargins: EdgeInsets

        var sizing: Sizing

        @available(*, deprecated, message: "Use horizontalSizing")
        public var mode: HorizontalMode {
            get { .leading }
            set {}
        }

        @available(*, deprecated, message: "Use layoutMargins")
        public var defaultInsets: EdgeInsets {
            get { EdgeInsets() }
            set {}
        }

        public var centerAlignment: TextAlignment

        public var bottomAlignment: TextAlignment

        public var uniformSpacing: CGFloat?

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

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - JindoTripleVStack.Position

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

    public struct VerticalPlacement: Equatable {
        private var rawValue: UInt8

        private init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let `default` = VerticalPlacement(rawValue: 0)

        public static let belowNotchIfTooWide = VerticalPlacement(rawValue: 1)
    }

    @available(*, deprecated, message: "Use HorizontalSizing")
    public enum HorizontalMode {
        case split
        case leading
        case trailing
    }

    public struct HorizontalSizing: Equatable {
        private var rawValue: UInt8

        private init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let automatic = HorizontalSizing(rawValue: 0)

        public static let leading = HorizontalSizing(rawValue: 1)

        public static let trailing = HorizontalSizing(rawValue: 2)

        public static let split = HorizontalSizing(rawValue: 3)
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        var implementation = Implementation(configuration: configuration, subviews: subviews)
        return implementation.sizeThatFits(proposal: adjusted(proposal))
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var implementation = Implementation(configuration: configuration, subviews: subviews)
        implementation.placeSubviews(
            in: adjusted(bounds),
            proposal: adjusted(proposal)
        )
    }

    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    public typealias AnimatableData = EmptyAnimatableData

    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    public typealias Cache = ()

    private func adjusted(_ proposal: ProposedViewSize) -> ProposedViewSize {
        guard configuration.sizing == .v1 else {
            return proposal
        }
        let margins = configuration.layoutMargins
        return ProposedViewSize(
            width: proposal.width.map { $0 - margins.leading - margins.trailing },
            height: proposal.height.map { $0 - margins.top - margins.bottom }
        )
    }

    private func adjusted(_ bounds: CGRect) -> CGRect {
        guard configuration.sizing == .v1 else {
            return bounds
        }
        let margins = configuration.layoutMargins
        return CGRect(
            x: bounds.origin.x + margins.leading,
            y: bounds.origin.y + margins.top,
            width: bounds.width - margins.leading - margins.trailing,
            height: bounds.height - margins.top - margins.bottom
        )
    }
}

// MARK: - Public conformances [TBA]

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

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
extension JindoTripleVStack.Position {
    public static let leading = JindoTripleVStack.Position(region: .leading)

    public static func leading(inset: CGFloat? = nil) -> JindoTripleVStack.Position {
        JindoTripleVStack.Position(region: .leading, leadingInset: inset)
    }

    public static let trailing = JindoTripleVStack.Position(region: .trailing)

    public static func trailing(inset: CGFloat? = nil) -> JindoTripleVStack.Position {
        JindoTripleVStack.Position(region: .trailing, trailingInset: inset)
    }

    public static let center = JindoTripleVStack.Position(region: .center)

    public static let bottom = JindoTripleVStack.Position(region: .bottom)

    public static func bottom(
        leadingInset: CGFloat? = nil,
        trailingInset: CGFloat? = nil
    ) -> JindoTripleVStack.Position {
        JindoTripleVStack.Position(region: .bottom, leadingInset: leadingInset, trailingInset: trailingInset)
    }

    public static let notch = JindoTripleVStack.Position(region: .notch)
}

@_spi(Jindo)
@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
extension JindoTripleVStack {
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    public struct ContentMargins {
        fileprivate var top: CGFloat?

        fileprivate var leading: CGFloat?

        fileprivate var bottom: CGFloat?

        fileprivate var trailing: CGFloat?

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

// MARK: - Layout values [TBA]

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
    typealias Value = JindoTripleVStack.Position

    static let defaultValue: Value = .bottom
}

extension View {
    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoPosition(
        _ position: JindoTripleVStack.Position
    ) -> some View {
        layoutValue(key: PositionKey.self, value: position)
    }

    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoVerticalPlacement(
        _ verticalPlacement: JindoTripleVStack.VerticalPlacement
    ) -> some View {
        layoutValue(key: VerticalPlacementKey.self, value: verticalPlacement)
    }

    @_spi(Jindo)
    @available(OpenSwiftUI_v4_1, *)
    @available(macOS, unavailable)
    nonisolated public func jindoPriority(_ priority: Double?) -> some View {
        layoutValue(key: PriorityKey.self, value: priority)
    }

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
private extension JindoTripleVStack {
    struct Implementation {
        private let configuration: Configuration

        private let subviews: LayoutSubviews

        private let leadingIndices: [Int]

        private let centerIndices: [Int]

        private let trailingIndices: [Int]

        private let bottomIndices: [Int]

        private let notchIndex: Int?

        init(configuration: Configuration, subviews: LayoutSubviews) {
            self.configuration = configuration
            self.subviews = subviews

            var leadingIndices: [Int] = []
            var centerIndices: [Int] = []
            var trailingIndices: [Int] = []
            var bottomIndices: [Int] = []
            var notchIndex: Int?

            for index in subviews.indices {
                switch subviews[index][PositionKey.self].region {
                case .leading:
                    leadingIndices.append(index)
                case .center:
                    centerIndices.append(index)
                case .trailing:
                    trailingIndices.append(index)
                case .bottom:
                    bottomIndices.append(index)
                case .notch:
                    if notchIndex == nil {
                        notchIndex = index
                    }
                }
            }

            self.leadingIndices = leadingIndices
            self.centerIndices = centerIndices
            self.trailingIndices = trailingIndices
            self.bottomIndices = bottomIndices
            self.notchIndex = notchIndex
        }

        mutating func sizeThatFits(proposal: ProposedViewSize) -> CGSize {
            compute(proposal: proposal, bounds: nil).size
        }

        mutating func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize) {
            let result = compute(proposal: proposal, bounds: bounds)
            for placement in result.placements {
                subviews[placement.index].place(
                    at: placement.origin,
                    anchor: .topLeading,
                    proposal: placement.proposal
                )
            }
        }

        private mutating func compute(
            proposal: ProposedViewSize,
            bounds: CGRect?
        ) -> Result {
            let width = proposal.width ?? 0
            let origin = bounds?.origin ?? .zero

            let sizing = resolvedHorizontalSizing()
            let notchWidth = finiteNonnegative(configuration.notchSize.width)
            let notchHeight = finiteNonnegative(configuration.notchSize.height)
            let sideLimit = finiteNonnegative((width - notchWidth) / 2)
            let horizontalFullWidth = leadingIndices.isEmpty || trailingIndices.isEmpty
            let leadingLimit = horizontalFullWidth && !leadingIndices.isEmpty ? width : sideLimit
            let trailingLimit = horizontalFullWidth && !trailingIndices.isEmpty ? width : sideLimit

            let centerDemand = max(
                notchWidth,
                maximumWidth(of: centerIndices, proposedWidth: width)
            )
            let centerWidth = min(width, centerDemand)
            let sideWidths = sideWidths(
                totalWidth: width,
                centerWidth: centerWidth,
                sizing: sizing
            )

            let leadingPartition = partition(
                leadingIndices,
                sideLimit: sideLimit,
                allocatedWidth: sideWidths.leading
            )
            let trailingPartition = partition(
                trailingIndices,
                sideLimit: sideLimit,
                allocatedWidth: sideWidths.trailing
            )

            var placements: [Placement] = []
            placements.reserveCapacity(subviews.count)

            if let bounds, let notchIndex {
                let notchProposal = ProposedViewSize(configuration.notchSize)
                let notchSize = sanitized(subviews[notchIndex].sizeThatFits(notchProposal))
                placements.append(
                    Placement(
                        index: notchIndex,
                        origin: CGPoint(
                            x: bounds.midX - notchSize.width / 2,
                            y: bounds.minY - configuration.layoutMargins.top
                        ),
                        proposal: notchProposal
                    )
                )
            }

            let centerStart = origin.y
                + configuration.notchSize.height
                - configuration.layoutMargins.top

            let leadingTop = layout(
                leadingPartition.adjacent,
                startingAt: origin.y,
                availableWidth: min(leadingLimit, sideWidths.leading),
                horizontalOrigin: origin.x,
                alignment: 0,
                placements: &placements
            )
            let trailingTop = layout(
                trailingPartition.adjacent,
                startingAt: origin.y,
                availableWidth: min(trailingLimit, sideWidths.trailing),
                horizontalOrigin: origin.x + width - min(trailingLimit, sideWidths.trailing),
                alignment: 1,
                placements: &placements
            )
            let centerTop = layout(
                centerIndices,
                startingAt: centerStart,
                availableWidth: centerWidth,
                horizontalOrigin: (bounds?.midX ?? width / 2) - centerWidth / 2,
                alignment: alignmentValue(configuration.centerAlignment),
                placements: &placements
            )

            let belowNotchStart = max(
                origin.y + notchHeight,
                leadingTop.end,
                centerTop.end,
                trailingTop.end
            )

            let leadingBelow = layout(
                leadingPartition.deferred,
                startingAt: belowNotchStart + spacing(
                    from: leadingPartition.adjacent.last,
                    to: leadingPartition.deferred.first
                ),
                availableWidth: width,
                horizontalOrigin: origin.x,
                alignment: 0,
                placements: &placements
            )
            let trailingBelow = layout(
                trailingPartition.deferred,
                startingAt: belowNotchStart + spacing(
                    from: trailingPartition.adjacent.last,
                    to: trailingPartition.deferred.first
                ),
                availableWidth: width,
                horizontalOrigin: origin.x,
                alignment: 1,
                placements: &placements
            )
            let belowNotchEnd = max(
                belowNotchStart,
                leadingBelow.end,
                trailingBelow.end
            )

            var bottomStart = max(
                leadingTop.end,
                centerTop.end,
                trailingTop.end,
                belowNotchEnd
            )
            if let firstBottom = bottomIndices.first {
                let candidates = [
                    leadingPartition.adjacent.last,
                    centerIndices.last,
                    trailingPartition.adjacent.last,
                    leadingPartition.deferred.last,
                    trailingPartition.deferred.last,
                ]
                let bottomSpacing = candidates.compactMap { previous in
                    previous.map { spacing(from: $0, to: firstBottom) }
                }.max() ?? 0
                bottomStart += bottomSpacing
            }

            let bottom = layout(
                bottomIndices,
                startingAt: bottomStart,
                availableWidth: width,
                horizontalOrigin: origin.x,
                alignment: alignmentValue(configuration.bottomAlignment),
                placements: &placements
            )

            let end = max(
                origin.y + notchHeight,
                leadingTop.end,
                centerTop.end,
                trailingTop.end,
                belowNotchEnd,
                bottom.end
            )
            return Result(
                size: CGSize(width: width, height: finiteNonnegative(end - origin.y)),
                placements: placements
            )
        }

        private func maximumWidth(
            of indices: [Int],
            proposedWidth: CGFloat?
        ) -> CGFloat {
            indices.reduce(0) { result, index in
                let margins = contentMargins(for: index)
                let childWidth = proposedWidth.map {
                    finiteNonnegative($0 - margins.leading - margins.trailing)
                }
                let size = sanitized(
                    subviews[index].sizeThatFits(
                        ProposedViewSize(width: childWidth, height: nil)
                    )
                )
                return max(result, size.width + margins.leading + margins.trailing)
            }
        }

        private func resolvedHorizontalSizing() -> HorizontalSizing {
            if trailingIndices.isEmpty {
                return .leading
            }
            if leadingIndices.isEmpty {
                return .trailing
            }
            guard configuration.horizontalSizing == .automatic else {
                return configuration.horizontalSizing
            }

            let leadingPriority = maximumJindoPriority(in: leadingIndices + bottomIndices) ?? 0
            let trailingPriority = maximumJindoPriority(in: trailingIndices + bottomIndices) ?? 0
            if leadingPriority > trailingPriority {
                return .leading
            } else if trailingPriority > leadingPriority {
                return .trailing
            } else {
                return .split
            }
        }

        private func maximumJindoPriority(in indices: [Int]) -> Double? {
            indices.compactMap { subviews[$0][PriorityKey.self] }.max()
        }

        private func sideWidths(
            totalWidth: CGFloat,
            centerWidth: CGFloat,
            sizing: HorizontalSizing
        ) -> (leading: CGFloat, trailing: CGFloat) {
            if trailingIndices.isEmpty {
                return (totalWidth, 0)
            }
            if leadingIndices.isEmpty {
                return (0, totalWidth)
            }

            let remaining = finiteNonnegative(totalWidth - centerWidth)
            let leadingMinimum = minimumSideWidth(of: leadingIndices)
            let trailingMinimum = minimumSideWidth(of: trailingIndices)
            if sizing == .leading {
                let trailing = min(remaining, trailingMinimum)
                return (remaining - trailing, trailing)
            }
            if sizing == .trailing {
                let leading = min(remaining, leadingMinimum)
                return (leading, remaining - leading)
            }
            return (remaining / 2, remaining / 2)
        }

        private func minimumSideWidth(of indices: [Int]) -> CGFloat {
            indices.reduce(0) { result, index in
                guard subviews[index][VerticalPlacementKey.self] == .default else {
                    return result
                }
                let margins = contentMargins(for: index)
                let size = sanitized(
                    subviews[index].sizeThatFits(
                        ProposedViewSize(width: 0, height: nil)
                    )
                )
                return max(result, size.width + margins.leading + margins.trailing)
            }
        }

        private func partition(
            _ indices: [Int],
            sideLimit: CGFloat,
            allocatedWidth: CGFloat
        ) -> (adjacent: [Int], deferred: [Int]) {
            var adjacent: [Int] = []
            var deferred: [Int] = []
            let availableWidth = min(sideLimit, allocatedWidth)
            for index in indices {
                let placement = subviews[index][VerticalPlacementKey.self]
                let margins = contentMargins(for: index)
                let idealSize = sanitized(subviews[index].sizeThatFits(.unspecified))
                if placement == .belowNotchIfTooWide,
                   idealSize.width + margins.leading + margins.trailing > availableWidth {
                    deferred.append(index)
                } else {
                    adjacent.append(index)
                }
            }
            return (adjacent, deferred)
        }

        private func layout(
            _ indices: [Int],
            startingAt start: CGFloat,
            availableWidth: CGFloat,
            horizontalOrigin: CGFloat,
            alignment: CGFloat,
            placements: inout [Placement]
        ) -> StackResult {
            guard !indices.isEmpty else {
                return StackResult(end: start)
            }

            var currentY = start
            var previous: Int?
            for index in indices {
                currentY += spacing(from: previous, to: index)
                let margins = contentMargins(for: index)
                let proposedWidth = finiteNonnegative(
                    availableWidth - margins.leading - margins.trailing
                )
                let childProposal = ProposedViewSize(width: proposedWidth, height: nil)
                let size = sanitized(subviews[index].sizeThatFits(childProposal))
                let occupiedWidth = size.width + margins.leading + margins.trailing
                let remaining = availableWidth - occupiedWidth
                let x = horizontalOrigin
                    + remaining * alignment
                    + margins.leading
                let y = currentY + margins.top
                placements.append(
                    Placement(
                        index: index,
                        origin: CGPoint(x: x, y: y),
                        proposal: childProposal
                    )
                )
                currentY += margins.top + size.height + margins.bottom
                previous = index
            }
            return StackResult(end: currentY)
        }

        private func spacing(from previous: Int?, to current: Int?) -> CGFloat {
            guard let previous, let current else {
                return 0
            }
            if let uniformSpacing = configuration.uniformSpacing {
                return uniformSpacing
            }
            return subviews[previous].spacing.distance(
                to: subviews[current].spacing,
                along: .vertical
            )
        }

        private func contentMargins(for index: Int) -> EdgeInsets {
            guard let margins = subviews[index][ContentMarginsKey.self] else {
                return EdgeInsets()
            }
            let defaults = configuration.layoutMargins
            return EdgeInsets(
                top: (margins.top ?? defaults.top) - defaults.top,
                leading: (margins.leading ?? defaults.leading) - defaults.leading,
                bottom: (margins.bottom ?? defaults.bottom) - defaults.bottom,
                trailing: (margins.trailing ?? defaults.trailing) - defaults.trailing
            )
        }

        private func alignmentValue(_ alignment: TextAlignment) -> CGFloat {
            switch alignment {
            case .leading:
                0
            case .center:
                0.5
            case .trailing:
                1
            }
        }

        private func sanitized(_ size: CGSize) -> CGSize {
            CGSize(
                width: finiteNonnegative(size.width),
                height: finiteNonnegative(size.height)
            )
        }

        private func finiteNonnegative(_ value: CGFloat) -> CGFloat {
            guard value.isFinite else {
                return 0
            }
            return max(0, value)
        }

        private struct Result {
            var size: CGSize
            var placements: [Placement]
        }

        private struct Placement {
            var index: Int
            var origin: CGPoint
            var proposal: ProposedViewSize
        }

        private struct StackResult {
            var end: CGFloat
        }
    }
}
