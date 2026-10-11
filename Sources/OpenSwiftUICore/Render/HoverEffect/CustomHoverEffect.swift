//
//  CustomHoverEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: B2E20BEC96D7E01EE3D55A38320E6294 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - CustomHoverEffect

/// A type that represents how a view should change when a pointer hovers
/// over a view, or when someone looks at the view.
///
/// Custom hover effects apply their inactive values when the effect is
/// inactive, and their active values when the effect is active. For example,
/// the following effect causes a view to be partially transparent when
/// inactive, but animate to fully opaque when active:
///
///
///     struct FadeInHoverEffect: CustomHoverEffect {
///         func body(content: Content) -> some CustomHoverEffect {
///             content.hoverEffect { effect, isActive, proxy in
///                 effect.animation(.easeOut) {
///                     $0.opacity(isActive ? 1 : 0.5)
///                 }
///             }
///         }
///     }
///
///
/// This effect can be applied to a view using the `hoverEffect(_:)` modifier:
///
///
///     Color.red
///         .hoverEffect(FadeInHoverEffect())
///
///
/// Hover effects do not affect a view's layout, and may be applied to a view
/// out-of-process. Therefore an effect's current phase may not be visible
/// within your app.
@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public protocol CustomHoverEffect {
    /// The type of effect representing the body of this effect. When you create
    /// a custom effect, Swift infers this type from your implementation of the
    /// required ``CustomHoverEffect/body(content:)`` method.
    associatedtype Body: CustomHoverEffect

    /// The content effect type passed to `body(content:)`.
    typealias Content = EmptyHoverEffect

    /// Defines the effect produced by this effect.
    ///
    /// You implement this method to describe a custom effect to apply to a
    /// view. `content` is an empty effect you use to build your effect, which
    /// will later be applied to a View, or combined with other
    /// `CustomHoverEffect`s.
    ///
    /// - Parameter content: An empty effect you use to compose the custom
    ///   effect.
    /// - Returns: A custom effect.
    func body(content: Content) -> Body

    /// Makes a new effect using the provided effect and inputs.
    static func _makeCustomHoverEffect(
        effect: _GraphValue<Self>,
        inputs: _CustomHoverEffectInputs,
        body: @escaping (_CustomHoverEffectInputs) -> _CustomHoverEffectOutputs
    ) -> _CustomHoverEffectOutputs
}

// MARK: - EmptyHoverEffect

/// A base hover effect used to build additional effects.
///
/// `EmptyHoverEffect`
/// does not change a view on hover.
@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct EmptyHoverEffect: CustomHoverEffect, PrimitiveCustomHoverEffect {
    public static func _makeCustomHoverEffect(
        effect: _GraphValue<Self>,
        inputs: _CustomHoverEffectInputs,
        body: @escaping (_CustomHoverEffectInputs) -> _CustomHoverEffectOutputs
    ) -> _CustomHoverEffectOutputs {
        body(inputs)
    }

    package init() {
        _openSwiftUIEmptyStub()
    }

    package var systemHoverEffect: SystemHoverEffect {
        SystemHoverEffect()
    }

    public typealias Body = Never

    package typealias WrappedEffectType = EmptyHoverEffect
}

@available(*, unavailable)
extension EmptyHoverEffect: Sendable {}

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension CustomHoverEffect where Self == EmptyHoverEffect {
    /// An effect that applies no changes when hovered.
    public static var empty: EmptyHoverEffect {
        EmptyHoverEffect()
    }
}

// MARK: - _CustomHoverEffectInputs

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct _CustomHoverEffectInputs {
    package var base: _ViewInputs
    package private(set) var context: Attribute<HoverEffectContext>

    package init(base: _ViewInputs, context: Attribute<HoverEffectContext>) {
        self.base = base
        self.context = context
        self.base.environment = Attribute(UpdateEnvironmentCustomHoverEffectContext(
            hoverEffectContext: context,
            environment: base.environment
        ))
    }

    package func makeIndirectOutputs() -> _CustomHoverEffectOutputs {
        _CustomHoverEffectOutputs(base: base.makeIndirectOutputs())
    }

    package mutating func updateContext(_ newContext: Attribute<HoverEffectContext>) {
        context = newContext
        base.environment = Attribute(UpdateEnvironmentCustomHoverEffectContext(
            hoverEffectContext: newContext,
            environment: base.environment
        ))
    }

    package mutating func removeContextFromEnvironment() {
        base.environment = Attribute(ClearCustomHoverEffectContextFromEnvironment(
            environment: base.environment
        ))
    }
}

@available(*, unavailable)
extension _CustomHoverEffectInputs: Sendable {}

// MARK: - _CustomHoverEffectOutputs

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct _CustomHoverEffectOutputs {
    package var base: _ViewOutputs

    package init(base: _ViewOutputs) {
        self.base = base
    }
}

@available(*, unavailable)
extension _CustomHoverEffectOutputs: Sendable {}

// MARK: - PrimitiveCustomHoverEffect

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
package protocol PrimitiveCustomHoverEffect: InternalCustomHoverEffect where Body == Never {}

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension CustomHoverEffect where Body == Never {
    public func body(content: Content) -> Never {
        bodyError()
    }
}

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension Never: CustomHoverEffect {}

// MARK: - InternalCustomHoverEffect

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
package protocol InternalCustomHoverEffect: CustomHoverEffect {
    associatedtype WrappedEffectType: InternalCustomHoverEffect

    var systemHoverEffect: SystemHoverEffect { get }

    var wrappedEffect: WrappedEffectType { get }
}

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension InternalCustomHoverEffect where Self == WrappedEffectType {
    package var wrappedEffect: Self {
        self
    }
}

// MARK: - SystemHoverEffect

package struct SystemHoverEffect {
    package var info: Info?
    package var isEnabled: Bool

    package init(info: Info? = nil, isEnabled: Bool = true) {
        self.info = info
        self.isEnabled = isEnabled
    }

    package enum Style: Hashable {
        case automatic
        case highlight
        case lift
        #if os(visionOS)
        case spotlight
        case pointerHidden
        #endif
    }

    package struct Info: Equatable {
        package var style: Style
        #if os(visionOS)
        package var background: Bool
        #endif

        package init(_ style: Style) {
            self.style = style
            #if os(visionOS)
            background = false
            #endif
        }

        #if os(visionOS)
        package init(_ style: Style, background: Bool) {
            self.style = style
            self.background = background
        }
        #endif
    }

    package struct Resolved: Equatable {
        package var info: Info
        package var isEnabled: Bool

        package init(info: Info, isEnabled: Bool) {
            self.info = info
            self.isEnabled = isEnabled
        }
    }

    package func resolve() -> Resolved {
        Resolved(info: info ?? Info(.automatic), isEnabled: isEnabled)
    }

    package func merge(with child: SystemHoverEffect) -> SystemHoverEffect {
        SystemHoverEffect(
            info: child.info ?? info,
            isEnabled: isEnabled && child.isEnabled
        )
    }
}

// MARK: - CustomHoverEffect + Body

@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension CustomHoverEffect {
    public static func _makeCustomHoverEffect(
        effect: _GraphValue<Self>,
        inputs: _CustomHoverEffectInputs,
        body: @escaping (_CustomHoverEffectInputs) -> _CustomHoverEffectOutputs
    ) -> _CustomHoverEffectOutputs {
        precondition(
            Metadata(Self.self).isValueType,
            "custom hover effects must be value types: \(Self.self)"
        )
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let accessor = ModifierBodyAccessor<Self>()
        let (effectBody, buffer) = accessor.makeBody(
            container: effect,
            inputs: &inputs.base.base,
            fields: fields
        )
        let outputs = Body._makeCustomHoverEffect(
            effect: effectBody,
            inputs: inputs,
            body: body
        )
        if let buffer {
            buffer.traceMountedProperties(to: effect, fields: fields)
        }
        return outputs
    }

    private func bodyError() -> Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

// MARK: - ModifierBodyAccessor

@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct ModifierBodyAccessor<Modifier>: BodyAccessor where Modifier: CustomHoverEffect {
    typealias Body = Modifier.Body

    func updateBody(of container: Modifier, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body(content: EmptyHoverEffect())
        }
    }
}

// MARK: - EnvironmentValues + HoverEffectContext

extension EnvironmentValues {
    package var hoverEffectContext: HoverEffectContext? {
        get { self[HoverEffectContextKey.self] }
        set { self[HoverEffectContextKey.self] = newValue }
    }
}

private struct UpdateEnvironmentCustomHoverEffectContext: Rule, AsyncAttribute {
    @Attribute var hoverEffectContext: HoverEffectContext
    @Attribute var environment: EnvironmentValues

    var value: EnvironmentValues {
        var environment = environment
        environment.hoverEffectContext = hoverEffectContext
        return environment
    }
}

private struct ClearCustomHoverEffectContextFromEnvironment: Rule, AsyncAttribute {
    @Attribute var environment: EnvironmentValues

    var value: EnvironmentValues {
        var environment = environment
        environment.hoverEffectContext = nil
        return environment
    }
}

private struct HoverEffectContextKey: EnvironmentKey {
    static var defaultValue: HoverEffectContext? { nil }
}

// MARK: - HoverEffectContext [WIP]

// TODO: Implement the hover phase, group, and accessibility state.
package struct HoverEffectContext {}
