//
//  SafeAreaInsets.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: C4DC82F2A500E9B6DEA3064A36584B42 (SwiftUICore)

import Foundation
package import OpenGraphShims

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
        // preconditionFailure("TODO")
        .zero
    }

    private func adjust(
        _ rect: inout CGRect,
        regions: SafeAreaRegions,
        to: _PositionAwarePlacementContext
    )  {
        // preconditionFailure("TODO")
    }
}

// MARK: - _SafeAreaInsetsModifier [WIP]

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
        if inputs.needsGeometry {
            // TODO
        }
        inputs.transform = Attribute(
            Transform(
                space: space,
                transform: inputs.transform,
                position: inputs.position,
                size: inputs.size
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
            transform.appendPosition(position.value)
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
