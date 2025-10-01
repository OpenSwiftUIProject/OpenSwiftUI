//
//  PlacementContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: BA60BF7120E939C5C25B2A488163D4AC (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims

// MARK: - EnvironmentFetch

private struct EnvironmentFetch<Value>: Rule, AsyncAttribute, Hashable {
    @Attribute var environment: EnvironmentValues
    var keyPath: KeyPath<EnvironmentValues, Value>

    var value: Value {
        environment[keyPath: keyPath]
    }
}

// MARK: - SizeAndSpacingContext

@dynamicMemberLookup
package struct SizeAndSpacingContext {
    package var context: AnyRuleContext

    var owner: AnyAttribute

    @Attribute var environment: EnvironmentValues

    package init(context: AnyRuleContext, owner: AnyAttribute? = nil, environment: Attribute<EnvironmentValues>) {
        self.context = context
        self.owner = owner ?? context.attribute
        self._environment = environment
    }

    package init(_ context: PlacementContext) {
        self.context = context.context
        self.owner = context.owner
        self._environment = context.$environment
    }

    package subscript<T>(dynamicMember keyPath: KeyPath<EnvironmentValues, T>) -> T {
        EnvironmentFetch(environment: $environment, keyPath: keyPath)
            .cachedValue(options: [._1], owner: owner)
    }

    package func update<T>(_ body: () -> T) -> T {
        var result: T?
        context.update {
            result = body()
        }
        return result!
    }
}

// MARK: - PlacementContext

@dynamicMemberLookup
package struct PlacementContext {
    var context: AnyRuleContext

    var owner: AnyAttribute

    @Attribute var environment: EnvironmentValues

    enum ParentSize {
        case eager(ViewSize)
        case lazy(Attribute<ViewSize>)
    }

    private let parentSize: ParentSize

    package init(
        context: AnyRuleContext,
        owner: AnyAttribute? = nil,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        self.context = context
        self.owner = owner ?? context.attribute
        self._environment = environment
        self.parentSize = .lazy(size)
    }

    package init(
        context: AnyRuleContext,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        self.context = context
        self.owner = context.attribute
        self._environment = environment
        self.parentSize = .lazy(size)
    }

    package init(base: SizeAndSpacingContext, parentSize: ViewSize) {
        self.context = base.context
        self.owner = base.owner
        self._environment = base.$environment
        self.parentSize = .eager(parentSize)
    }

    package var size: CGSize {
        switch parentSize {
        case let .eager(viewSize): viewSize.value
        case let .lazy(attribute): context[attribute].value
        }
    }

    package var proposedSize: _ProposedSize {
        if isLinkedOnOrAfter(.v3) {
            switch parentSize {
            case let .eager(viewSize): viewSize.proposal
            case let .lazy(attribute): context[attribute].proposal
            }
        } else {
            switch parentSize {
            case let .eager(viewSize): _ProposedSize(viewSize.value)
            case let .lazy(attribute): _ProposedSize(context[attribute].value)
            }
        }
    }

    package subscript<T>(dynamicMember keyPath: KeyPath<EnvironmentValues, T>) -> T {
        EnvironmentFetch(environment: $environment, keyPath: keyPath)
            .cachedValue(options: [._1], owner: owner)
    }
}

// MARK: - _PositionAwarePlacementContext

@dynamicMemberLookup
package struct _PositionAwarePlacementContext {
    var context: AnyRuleContext
    var owner: AnyAttribute
    var _size: Attribute<ViewSize>
    var _environment: Attribute<EnvironmentValues>
    var _transform: Attribute<ViewTransform>
    var _position: Attribute<ViewOrigin>
    var _safeAreaInsets: OptionalAttribute<SafeAreaInsets>

    package init(
        context: AnyRuleContext,
        owner: AnyAttribute? = nil,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        self.context = context
        self.owner = owner ?? context.attribute
        self._size = size
        self._environment = environment
        self._transform = transform
        self._position = position
        self._safeAreaInsets = safeAreaInsets
    }

    package init(
        context: AnyRuleContext,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        self.context = context
        self.owner = context.attribute
        self._size = size
        self._environment = environment
        self._transform = transform
        self._position = position
        self._safeAreaInsets = safeAreaInsets
    }

    package var size: CGSize {
        context[_size].value
    }

    package var proposedSize: _ProposedSize {
        if isLinkedOnOrAfter(.v3) {
            context[_size].proposal
        } else {
            _ProposedSize(context[_size].value)
        }
    }

    package var unadjustedSafeAreaInsets: SafeAreaInsets? {
        guard let attribute = _safeAreaInsets.attribute else {
            return nil
        }
        return context[attribute]
    }

    package var transform: ViewTransform {
        context[_transform].withPosition(context[_position])
    }

    package subscript<T>(dynamicMember keyPath: KeyPath<EnvironmentValues, T>) -> T {
        EnvironmentFetch(environment: _environment, keyPath: keyPath)
            .cachedValue(options: [._1], owner: owner)
    }
}

extension ViewTransformable {
    package mutating func convert(from space: CoordinateSpace, to context: _PositionAwarePlacementContext) {
        convert(from: space, transform: context.transform)
    }

    package mutating func convert(from context: _PositionAwarePlacementContext, to space: CoordinateSpace) {
        convert(to: space, transform: context.transform)
    }
}
