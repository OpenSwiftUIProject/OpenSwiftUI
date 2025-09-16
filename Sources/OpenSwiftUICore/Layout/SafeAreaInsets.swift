//
//  SafeAreaInsets.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C4DC82F2A500E9B6DEA3064A36584B42 (SwiftUICore)

import Foundation
package import OpenAttributeGraphShims

// MARK: - SafeAreaRegions

/// A set of symbolic safe area regions.
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

// MARK: - SafeAreaInsets [WIP]

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
        to: _PositionAwarePlacementContext
    )  {
        _openSwiftUIUnimplementedWarning()
    }

    private func mergedInsets(regions: SafeAreaRegions) -> (selected: EdgeInsets, total: EdgeInsets) {
        guard !elements.isEmpty else {
            return (.zero, .zero)
        }
        var selected: EdgeInsets = .zero
        var total: EdgeInsets = .zero

        // Track which edges can still contribute to the selected insets.
        // This prevents inner safe area modifiers from overriding outer ones.
        // For example, if an outer modifier sets a top inset for a different region,
        // an inner modifier matching our region shouldn't override that top edge.
        var availableEdges: Edge.Set = .all

        // Iterate through elements in reverse order (from innermost to outermost modifier).
        // This ensures that outer modifiers take precedence over inner ones for each edge.
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

// MARK: - _SafeAreaInsetsModifier [6.4.41]

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

// MARK: - SafeAreaInsetsModifier [6.4.41]

package typealias SafeAreaInsetsModifier = ModifiedContent<_PaddingLayout, _SafeAreaInsetsModifier>

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

// MARK: - ResolvedSafeAreaInsets [6.4.41]

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
