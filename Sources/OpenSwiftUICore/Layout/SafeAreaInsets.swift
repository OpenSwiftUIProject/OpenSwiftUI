//
//  SafeAreaInsets.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C4DC82F2A500E9B6DEA3064A36584B42 (SwiftUICore)

import Foundation
package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

// MARK: - SafeAreaRegions

/// A set of symbolic safe area regions.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct SafeAreaRegions: OptionSet {
    public let rawValue: UInt

    @inlinable
    public init(rawValue: UInt) { self.rawValue = rawValue }

    /// The safe area defined by the device and containers within the
    /// user interface, including elements such as top and bottom bars.
    public static let container = SafeAreaRegions(rawValue: 1 << 0)

    /// The safe area matching the current extent of any software
    /// keyboard displayed over the view content.
    public static let keyboard = SafeAreaRegions(rawValue: 1 << 1)

    /// All safe area regions.
    public static let all = SafeAreaRegions(rawValue: .max)

    package static let background = SafeAreaRegions(rawValue: 1 << 0)
}

// MARK: - SafeAreaInsets

package struct SafeAreaInsets: Equatable {
    package enum OptionalValue: Equatable {
        case empty
        indirect case insets(SafeAreaInsets)
    }
    
    package struct Element: Equatable {
        package var regions: SafeAreaRegions
        package var insets: EdgeInsets
        
        package init(regions: SafeAreaRegions, insets: EdgeInsets) {
            self.regions = regions
            self.insets = insets
        }
    }
    
    package var space: CoordinateSpace.ID

    package var elements: [Element]

    package var next: OptionalValue

    package init(space: CoordinateSpace.ID, elements: [Element]) {
        self.space = space
        self.elements = elements
        self.next = .empty
    }
    
    package init(space: CoordinateSpace.ID, elements: [Element], next: OptionalValue) {
        self.space = space
        self.elements = elements
        self.next = next
    }
    
    package func resolve(regions: SafeAreaRegions, in ctx: _PositionAwarePlacementContext) -> EdgeInsets {
        let size = ctx.size
        let rect = CGRect(origin: .zero, size: size)
        var adjustedRect = rect
        adjust(&adjustedRect, regions: regions, to: ctx)
        var next = next
        while case let .insets(nextInsets) = next {
            nextInsets.adjust(&adjustedRect, regions: regions, to: ctx)
            next = nextInsets.next
        }
        var insets = EdgeInsets.zero
        insets.top = rect.minY - adjustedRect.minY
        insets.leading = rect.minX - adjustedRect.minX
        insets.bottom = adjustedRect.maxY - rect.maxY
        insets.trailing = adjustedRect.maxX - rect.maxX
        insets.xFlipIfRightToLeft { ctx.layoutDirection }
        return insets
    }

    private func adjust(
        _ rect: inout CGRect,
        regions: SafeAreaRegions,
        to context: _PositionAwarePlacementContext
    ) {
        let (selectedInsets, totalInsets) = mergedInsets(regions: regions)
        guard !selectedInsets.isEmpty else { return }

        var points: [CGPoint]?
        var isInvalid = false
        context.transform.convert(.spaceToLocal(.id(space))) { item in
            if case let .sizedSpace(.id(id), size) = item, id == space {
                let innerRect = CGRect(origin: .zero, size: size).inset(by: totalInsets)
                points = innerRect.cornerPoints
                points?.append(contentsOf: innerRect.inset(by: -selectedInsets).cornerPoints)
            } else {
                switch item {
                    case let .affineTransform(transform, _):
                        if !transform.isRectilinear {
                            isInvalid = true
                        }
                    case let .projectionTransform(transform, _):
                        if !transform.isAffine ||
                           !CGAffineTransform(transform).isRectilinear {
                            isInvalid = true
                        }
                    default:
                        break
                }
                if !isInvalid {
                    points?.applyTransform(item: item)
                }
            }
        }
        guard !isInvalid, let points else { return }

        let innerRect = CGRect(cornerPoints: points[0...3])
        let outerRect = CGRect(cornerPoints: points[4...7])
        let minY = rect.minY
        let maxY = rect.maxY
        let minX = rect.minX
        let maxX = rect.maxX
        let epsilon = context.pixelLength * 0.5 + 0.001

        if minY - epsilon < innerRect.minY,
           outerRect.minY < minY + epsilon {
            let delta = minY - outerRect.minY
            rect.origin.y -= delta
            rect.size.height += delta
        }
        if innerRect.maxY < maxY + epsilon,
           maxY - epsilon < outerRect.maxY {
            rect.size.height += outerRect.maxY - maxY
        }
        if minX - epsilon < innerRect.minX,
           outerRect.minX < minX + epsilon {
            let delta = minX - outerRect.minX
            rect.origin.x -= delta
            rect.size.width += delta
        }
        if innerRect.maxX < maxX + epsilon,
           maxX - epsilon < outerRect.maxX {
            rect.size.width += outerRect.maxX - maxX
        }
    }

    private func mergedInsets(regions: SafeAreaRegions) -> (selected: EdgeInsets, total: EdgeInsets) {
        guard !elements.isEmpty else {
            return (.zero, .zero)
        }
        var selected: EdgeInsets = .zero
        var total: EdgeInsets = .zero

        // Track which edges can still contribute to the selected insets after
        // later elements in the array have been considered.
        var availableEdges: Edge.Set = .all

        // A disjoint element with a nonzero inset consumes that edge, preventing
        // earlier elements from contributing it to the selected region.
        for element in elements.reversed() {
            let insets = element.insets
            if element.regions.isDisjoint(with: regions) {
                if insets.leading != 0 {
                    availableEdges.remove(.leading)
                }
                if insets.trailing != 0 {
                    availableEdges.remove(.trailing)
                }
                if insets.top != 0 {
                    availableEdges.remove(.top)
                }
                if insets.bottom != 0 {
                    availableEdges.remove(.bottom)
                }
            } else {
                if availableEdges.contains(.top) {
                    selected.top += insets.top
                }
                if availableEdges.contains(.leading) {
                    selected.leading += insets.leading
                }
                if availableEdges.contains(.bottom) {
                    selected.bottom += insets.bottom
                }
                if availableEdges.contains(.trailing) {
                    selected.trailing += insets.trailing
                }
            }
            total += insets
        }
        return (selected, total)
    }
}

// MARK: - _SafeAreaInsetsModifier

@MainActor
@preconcurrency
package struct _SafeAreaInsetsModifier: MultiViewModifier, PrimitiveViewModifier, Equatable {
    var elements: [SafeAreaInsets.Element]
    var nextInsets: SafeAreaInsets.OptionalValue?

    package init() {
        elements = []
        nextInsets = nil
    }

    package init(elements: [SafeAreaInsets.Element], nextInsets: SafeAreaInsets.OptionalValue? = nil) {
        self.elements = elements
        self.nextInsets = nextInsets
    }

    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let space = CoordinateSpace.ID()
        inputs.transform = Attribute(
            Transform(
                space: space,
                transform: inputs.transform,
                position: inputs.animatedPosition(),
                size: inputs.animatedSize()
            )
        )
        inputs.safeAreaInsets = OptionalAttribute(
            Attribute(
                Insets(
                    space: space,
                    modifier: modifier.value,
                    next: inputs.safeAreaInsets
                )
            )
        )
        return body(_Graph(), inputs)
    }

    private struct Insets: Rule, AsyncAttribute {
        let space: CoordinateSpace.ID
        @Attribute var modifier: _SafeAreaInsetsModifier
        @OptionalAttribute var next: SafeAreaInsets?

        var value: SafeAreaInsets {
            let insets: SafeAreaInsets.OptionalValue
            if let nextInsets = modifier.nextInsets {
                insets = nextInsets
            } else {
                if let next {
                    insets = .insets(next)
                } else {
                    insets = .empty
                }
            }
            return SafeAreaInsets(space: space, elements: modifier.elements, next: insets)
        }
    }

    private struct Transform: Rule, AsyncAttribute {
        let space: CoordinateSpace.ID
        @Attribute var transform: ViewTransform
        @Attribute var position: ViewOrigin
        @Attribute var size: ViewSize

        var value: ViewTransform {
            var transform = transform
            transform.appendPosition(position)
            transform.appendSizedSpace(id: space, size: size.value)
            return transform
        }
    }
}

extension _SafeAreaInsetsModifier {
    @MainActor
    @preconcurrency
    package init(insets: EdgeInsets, nextInsets: SafeAreaInsets.OptionalValue? = nil) {
        self.elements = [.init(regions: .container, insets: insets)]
        self.nextInsets = nextInsets
    }
}

extension _PositionAwarePlacementContext {
    package func safeAreaInsets(matching regions: SafeAreaRegions = .all) -> EdgeInsets {
        guard let unadjustedSafeAreaInsets else {
            return .zero
        }
        return unadjustedSafeAreaInsets.resolve(regions: regions, in: self)
    }
}

// MARK: - SafeAreaInsetsModifier

package typealias SafeAreaInsetsModifier = ModifiedContent<_PaddingLayout, _SafeAreaInsetsModifier>

@available(OpenSwiftUI_v2_0, *)
extension View {
    @MainActor
    @preconcurrency
    public func _safeAreaInsets(_ insets: EdgeInsets) -> some View {
        safeAreaInsets(insets, next: nil)
    }

    @MainActor
    @preconcurrency
    package func safeAreaInsets(_ insets: EdgeInsets, next: SafeAreaInsets.OptionalValue? = nil) -> ModifiedContent<Self, SafeAreaInsetsModifier> {
        modifier(
            _PaddingLayout(insets: insets)
                .concat(_SafeAreaInsetsModifier(insets: insets, nextInsets: next))
        )
    }
}

// MARK: - ResolvedSafeAreaInsets

package struct ResolvedSafeAreaInsets: Rule, AsyncAttribute {
    let regions: SafeAreaRegions
    @Attribute var environment: EnvironmentValues
    @Attribute var size: ViewSize
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?

    package init(
        regions: SafeAreaRegions,
        environment: Attribute<EnvironmentValues>,
        size: Attribute<ViewSize>,
        position: Attribute<ViewOrigin>,
        transform: Attribute<ViewTransform>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        self.regions = regions
        self._environment = environment
        self._size = size
        self._position = position
        self._transform = transform
        self._safeAreaInsets = safeAreaInsets
    }

    package var value: EdgeInsets {
        let context = AnyRuleContext(context)
        guard let safeAreaInsetsAttribute = $safeAreaInsets else {
            return .zero
        }
        return context[safeAreaInsetsAttribute].resolve(
            regions: regions,
            in: _PositionAwarePlacementContext(
                context: context,
                size: _size,
                environment: _environment,
                transform: _transform,
                position: _position,
                safeAreaInsets: _safeAreaInsets
            )
        )
    }
}
