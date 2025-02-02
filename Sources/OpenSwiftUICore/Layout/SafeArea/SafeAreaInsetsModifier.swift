//
//  ViewBuilder.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import OpenGraphShims

package struct _SafeAreaInsetsModifier: /* MultiViewModifier, */ PrimitiveViewModifier, Equatable {
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
    
    nonisolated package static func _makeView(modifier: _GraphValue<_SafeAreaInsetsModifier>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
        // preconditionFailure("TODO")
        return body(_Graph(), inputs)
    }
}

extension _SafeAreaInsetsModifier {
    @MainActor
    @preconcurrency
    package init(insets: EdgeInsets, nextInsets: SafeAreaInsets.OptionalValue? = nil) {
        preconditionFailure("TODO")
    }
}

extension _PositionAwarePlacementContext {
    package func safeAreaInsets(matching regions: SafeAreaRegions = .all) -> EdgeInsets {
        preconditionFailure("TODO")
    }
}

package typealias SafeAreaInsetsModifier = ModifiedContent<_PaddingLayout, _SafeAreaInsetsModifier>

extension View {
    @MainActor
    @preconcurrency
    public func _safeAreaInsets(_ insets: EdgeInsets) -> some View {
        preconditionFailure("TODO")
    }

    @MainActor
    @preconcurrency
    package func safeAreaInsets(_ insets: EdgeInsets, next: SafeAreaInsets.OptionalValue? = nil) -> ModifiedContent<Self, SafeAreaInsetsModifier> {
        preconditionFailure("TODO")
    }
}

package struct ResolvedSafeAreaInsets: Rule, AsyncAttribute {
    package init(
        regions: SafeAreaRegions,
        environment: Attribute<EnvironmentValues>,
        size: Attribute<ViewSize>,
        position: Attribute<ViewOrigin>,
        transform: Attribute<ViewTransform>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        preconditionFailure("TODO")
    }
    
    package var value: EdgeInsets {
        preconditionFailure("TODO")
    }
}
