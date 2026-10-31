//
//  ContentTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 91D8F0C7DA490950AB41112E50631DCA (SwiftUICore)

package import OpenAttributeGraphShims
public import OpenCoreGraphicsShims
package import OpenRenderBoxShims

// MARK: - ContentTransition

/// A kind of transition that applies to the content within a single view,
/// rather than to the insertion or removal of a view.
///
/// Set the behavior of content transitions within a view with the
/// ``View/contentTransition(_:)`` modifier, passing in one of the defined
/// transitions, such as ``opacity`` or ``interpolate`` as the parameter.
///
/// > Tip: Content transitions only take effect within transactions that apply
/// an ``Animation`` to the views inside the ``View/contentTransition(_:)``
/// modifier.
///
/// Content transitions only take effect within the context of an
/// ``Animation`` block.
@available(OpenSwiftUI_v4_0, *)
public struct ContentTransition: Equatable, Sendable {

    // MARK: - ContentTransition.Storage

    package enum Storage: Equatable, @unchecked Sendable {
        case named(ContentTransition.NamedTransition)
        case custom(ContentTransition.CustomTransition)
        case symbolReplace(_SymbolEffect.ReplaceConfiguration)
    }

    // MARK: - ContentTransition.Style

    @_spi(Private)
    public struct Style: Hashable, Sendable, Codable {
        package enum Storage: Hashable, Sendable {
            case `default`
            case sessionWidget
            case animatedWidget
        }

        package var storage: ContentTransition.Style.Storage

        package init(_ storage: ContentTransition.Style.Storage) {
            self.storage = storage
        }

        public static let `default`: ContentTransition.Style = .init(.default)

        public static let sessionWidget: ContentTransition.Style = .init(.sessionWidget)

        @available(OpenSwiftUI_v5_0, *)
        public static let animatedWidget: ContentTransition.Style = .init(.animatedWidget)
    }

    package var storage: ContentTransition.Storage

    package var isReplaceable: Bool

    package init(storage: ContentTransition.Storage) {
        self.storage = storage
        self.isReplaceable = false
    }

    // MARK: - ContentTransition.NamedTransition

    package struct NamedTransition: Hashable, Sendable {
        package enum Name: Hashable {
            case `default`
            case identity
            case opacity
            case diff
            case fadeIfDifferent
            case text(different: Bool)
            case numericText(ContentTransition.NumericTextConfiguration)
        }

        package var name: ContentTransition.NamedTransition.Name
        package var layoutDirection: LayoutDirection?
        package var style: ContentTransition.Style?

        package init(
            name: ContentTransition.NamedTransition.Name = .default,
            layoutDirection: LayoutDirection? = nil,
            style: ContentTransition.Style? = nil
        ) {
            self.name = name
            self.layoutDirection = layoutDirection
            self.style = style
        }
    }

    // MARK: - ContentTransition.NumericTextConfiguration

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public struct NumericTextConfiguration: Hashable, Sendable {
        package enum Direction: Hashable {
            case fixed(downwards: Bool)
            case automatic(value: Float)
        }

        package struct Options: OptionSet, Hashable {
            package let rawValue: UInt8

            package init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            package static let reversed: ContentTransition.NumericTextConfiguration.Options = .init(rawValue: 1 << 0)

            package static let relativeBlur: ContentTransition.NumericTextConfiguration.Options = .init(rawValue: 1 << 1)
        }

        package var direction: ContentTransition.NumericTextConfiguration.Direction
        package var axis: Axis?
        package var options: ContentTransition.NumericTextConfiguration.Options
        private var _delay: UInt8 = 18
        private var _scale: UInt8 = 51
        private var _blur: UInt8 = 32
        private var _offset: Int8 = 19

        package init(
            direction: ContentTransition.NumericTextConfiguration.Direction = .fixed(downwards: false),
            axis: Axis? = nil,
            options: ContentTransition.NumericTextConfiguration.Options = .relativeBlur
        ) {
            self.direction = direction
            self.axis = axis
            self.options = options
        }

        package var delay: Float {
            get { Float(_delay) * (1 / 120) }
            set { _delay = UInt8(clamping: newValue * 120) }
        }

        package var maxDurationMultiple: Float {
            1.25
        }

        package var scale: Float {
            get { Float(_scale) / 128 }
            set { _scale = UInt8(clamping: newValue * 128) }
        }

        package var blur: Float {
            get { Float(_blur) / 4 }
            set {
                _blur = UInt8(clamping: newValue * 4)
                options.remove(.relativeBlur)
            }
        }

        package var relativeBlur: Float {
            get { Float(_blur) / 128 }
            set {
                _blur = UInt8(clamping: newValue * 128)
                options.insert(.relativeBlur)
            }
        }

        package var offset: Float {
            get { Float(_offset) / 32 }
            set { _offset = Int8(clamping: newValue * 32) }
        }
    }

    package init(_ name: ContentTransition.NamedTransition.Name) {
        self.init(storage: .named(.init(name: name)))
    }

    // MARK: - ContentTransition.CustomTransition

    package struct CustomTransition: Equatable, Sendable {
        package var effects: [ContentTransition.Effect]
        package var method: ContentTransition.Method
        package var layoutDirection: LayoutDirection?

        package init(
            effects: [ContentTransition.Effect],
            method: ContentTransition.Method,
            layoutDirection: LayoutDirection? = nil
        ) {
            self.effects = effects
            self.method = method
            self.layoutDirection = layoutDirection
        }
    }

    @_spi(Private)
    public struct EffectType: Equatable, Sendable {
        package enum Arg: Equatable, Sendable {
            case none
            case float(Float)
            case int(UInt32)
        }

        package var type: ORBTransitionEffectType
        package var arg0: ContentTransition.EffectType.Arg, arg1: ContentTransition.EffectType.Arg

        package init(
            type: ORBTransitionEffectType,
            arg0: ContentTransition.EffectType.Arg = .none,
            arg1: ContentTransition.EffectType.Arg = .none
        ) {
            self.type = type
            self.arg0 = arg0
            self.arg1 = arg1
        }

        public static var opacity: ContentTransition.EffectType {
            self.init(type: .alpha, arg0: .none, arg1: .none)
        }

        @available(*, deprecated, message: "use opacity variable")
        public static func opacity(_ opacity: Double = 0) -> ContentTransition.EffectType {
            self.init(type: .alpha, arg0: .none, arg1: .none)
        }

        public static func blur(radius: CGFloat) -> ContentTransition.EffectType {
            self.init(type: .blur, arg0: .float(Float(radius)), arg1: .none)
        }

        @available(OpenSwiftUI_v6_0, *)
        public static func relativeBlur(scale: CGSize) -> ContentTransition.EffectType {
            self.init(type: .relativeBlur, arg0: .float(Float(scale.width)), arg1: .float(Float(scale.height)))
        }

        public static func scale(_ scale: CGFloat = 0) -> ContentTransition.EffectType {
            self.init(type: .scaleCenter, arg0: .float(Float(scale)), arg1: .none)
        }

        public static func translation(_ size: CGSize) -> ContentTransition.EffectType {
            self.init(type: .translation, arg0: .float(Float(size.width)), arg1: .float(Float(size.height)))
        }

        @available(OpenSwiftUI_v6_0, *)
        public static func translation(scale: CGSize) -> ContentTransition.EffectType {
            self.init(type: .relativeTranslation, arg0: .float(Float(scale.width)), arg1: .float(Float(scale.height)))
        }

        public static var matchMove: ContentTransition.EffectType {
            self.init(type: .matchMove, arg0: .none, arg1: .none)
        }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    public enum SequenceDirection: Hashable, Sendable {
        case leading, trailing, up, down
        case forwards, backwards
    }

    @_spi(Private)
    public struct Effect: Equatable, Sendable {
        package var type: ContentTransition.EffectType
        package var begin: Float
        package var duration: Float
        package var events: ORBTransitionEvents
        package var flags: ORBTransitionEffectFlags

        package init(
            type: ContentTransition.EffectType,
            begin: Float = 0,
            duration: Float = 1,
            events: ORBTransitionEvents = .addRemove,
            flags: ORBTransitionEffectFlags = .init()
        ) {
            self.type = type
            self.begin = begin
            self.duration = duration
            self.events = events
            self.flags = flags
        }

        public init(
            _ type: ContentTransition.EffectType,
            timeline: ClosedRange<Float> = 0 ... 1,
            appliesOnInsertion: Bool = true,
            appliesOnRemoval: Bool = true
        ) {
            self.type = type
            self.begin = timeline.lowerBound
            self.duration = timeline.upperBound - timeline.lowerBound
            self.events = [
                appliesOnInsertion ? .add : [],
                appliesOnRemoval ? .remove : [],
            ]
            self.flags = []
        }

        @available(OpenSwiftUI_v6_0, *)
        public static func sequence(
            direction: ContentTransition.SequenceDirection,
            delay: Double,
            maxAllowedDurationMultiple: Double = .infinity,
            appliesOnInsertion: Bool = true,
            appliesOnRemoval: Bool = true
        ) -> ContentTransition.Effect {
            let type: ORBTransitionEffectType = switch direction {
            case .leading: .sequenceLeft
            case .trailing: .sequenceRight
            case .up: .sequenceUp
            case .down: .sequenceDown
            case .forwards: .sequenceForwards
            case .backwards: .sequenceBackwards
            }
            // The target version applies sequence effects to both events.
            return .init(
                type: .init(type: type),
                begin: Float(delay),
                duration: 1 / Float(maxAllowedDurationMultiple)
            )
        }

        @available(OpenSwiftUI_v6_0, *)
        public func removeInverts(_ state: Bool) -> ContentTransition.Effect {
            var effect = self
            effect.flags.setValue(state, for: .removeInverts)
            return effect
        }
    }

    @_spi(Private)
    public struct Method: Equatable, Sendable {
        package var method: ORBTransitionMethod

        package init(method: ORBTransitionMethod) {
            self.method = method
        }

        public static let diff: ContentTransition.Method = .init(method: .diff)

        public static let forwards: ContentTransition.Method = .init(method: .forwards)

        public static let backwards: ContentTransition.Method = .init(method: .backwards)

        public static let prefix: ContentTransition.Method = .init(method: .prefix)

        public static let suffix: ContentTransition.Method = .init(method: .suffix)

        public static let prefixAndSuffix: ContentTransition.Method = .init(method: .prefixAndSuffix)

        public static let binary: ContentTransition.Method = .init(method: .binary)

        public static let none: ContentTransition.Method = .init(method: .none)

        public static func == (a: ContentTransition.Method, b: ContentTransition.Method) -> Bool {
            a.method == b.method
        }
    }

    @_spi(Private)
    public init(method: ContentTransition.Method, effects: [ContentTransition.Effect]) {
        self.init(storage: .custom(.init(effects: effects, method: method)))
    }

    @_spi(Private)
    public static let `default`: ContentTransition = .init(.default)

    /// The identity content transition, which indicates that content changes
    /// shouldn't animate.
    ///
    /// You can pass this value to a ``View/contentTransition(_:)``
    /// modifier to selectively disable animations that would otherwise
    /// be applied by a ``withAnimation(_:_:)`` block.
    public static let identity: ContentTransition = .init(.identity)

    /// A content transition that indicates content fades from transparent
    /// to opaque on insertion, and from opaque to transparent on removal.
    public static let opacity: ContentTransition = .init(.opacity)

    package static let fadeIfDifferent: ContentTransition = .init(.fadeIfDifferent)

    /// A content transition that indicates the views attempt to interpolate
    /// their contents during transitions, where appropriate.
    ///
    /// Text views can interpolate transitions when the text views have
    /// identical strings. Matching glyph pairs can animate changes to their
    /// color, position, size, and any variable properties. Interpolation can
    /// apply within a ``Font/Design`` case, but not between cases, or between
    /// entirely different fonts. For example, you can interpolate a change
    /// between ``Font/Weight/thin`` and ``Font/Weight/black`` variations of a
    /// font, since these are both cases of ``Font/Weight``. However, you can't
    /// interpolate between the default design of a font and its Italic version,
    /// because these are different fonts. Any changes that can't show an
    /// interpolated animation use an opacity animation instead.
    ///
    /// Symbol images created with the ``Image/init(systemName:)`` initializer
    /// work the same way as text: changes within the same symbol attempt to
    /// interpolate the symbol's paths. When interpolation is unavailable, the
    /// system uses an opacity transition instead.
    public static let interpolate: ContentTransition = .init(.diff)

    @_spi(Private)
    public static var text: ContentTransition { .init(.text(different: false)) }

    package static var differentText: ContentTransition { .init(.text(different: true)) }

    /// Creates a content transition intended to be used with `Text`
    /// views displaying numeric text. In certain environments changes
    /// to the text will enable a nonstandard transition tailored to
    /// numeric characters that count up or down.
    ///
    /// - Parameters:
    ///   - countsDown: true if the numbers represented by the text
    ///     are counting downwards.
    ///
    /// - Returns: a new content transition.
    public static func numericText(countsDown: Bool = false) -> ContentTransition {
        .init(
            storage: .named(
                NamedTransition(
                    name: .numericText(
                        NumericTextConfiguration(direction: .fixed(
                            downwards: countsDown == isDeployedOnOrAfter(.v6)
                        ))
                    )
                )
            )
        )
    }

    @_spi(Private)
    @available(*, deprecated, message: "replaced by numericText(countsDown:)")
    public static func numericText(increasing: Bool) -> ContentTransition {
        .numericText(countsDown: !increasing)
    }

    @available(OpenSwiftUI_v5_0, *)
    public static func numericText(value: Double) -> ContentTransition {
        .numericText(.automatic(value: value))
    }

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static func numericText(_ config: ContentTransition.NumericTextConfiguration) -> ContentTransition {
        .init(.numericText(config))
    }

    package func isNamed(_ name: ContentTransition.NamedTransition.Name) -> Bool {
        guard case let .named(transition) = storage else { return false }
        return transition.name == name
    }

    @_spi(Private)
    public var style: ContentTransition.Style? {
        get {
            guard case let .named(transition) = storage else { return nil }
            return transition.style
        }
        set {
            guard case var .named(transition) = storage else { return }
            transition.style = newValue
            storage = .named(transition)
        }
    }

    package var rbTransition: ORBTransition {
        switch storage {
        case let .named(named):
            let key = NamedKey(name: named, isReplaceable: isReplaceable)
            if let transition = Self._namedTransitions.wrappedValue[key] {
                return transition
            }
            let transition = named.makeRBTransition()
            transition.isReplaceable = isReplaceable
            Self._namedTransitions.wrappedValue[key] = transition
            return transition
        case let .custom(custom):
            let transition = ORBTransition()
            transition.method = custom.method.method
            for effect in custom.effects {
                let descriptor = ORBTransitionEffect()
                var type = effect.type.type
                if custom.layoutDirection == .rightToLeft {
                    switch type {
                    case .anchorLeft: type = .anchorRight
                    case .anchorRight: type = .anchorLeft
                    case .sequenceLeft: type = .sequenceRight
                    case .sequenceRight: type = .sequenceLeft
                    default: break
                    }
                }
                descriptor.type = type
                for (index, argument) in [effect.type.arg0, effect.type.arg1].enumerated() {
                    switch argument {
                    case .none: break
                    case let .float(value): descriptor.setArgumentValue(value, at: UInt(index))
                    case let .int(value): descriptor.setIntegerArgumentValue(value, at: UInt(index))
                    }
                }
                descriptor.events = effect.events
                descriptor.flags = effect.flags
                descriptor.beginTime = effect.begin
                descriptor.duration = effect.duration
                transition.addEffect(descriptor)
            }
            transition.isReplaceable = isReplaceable
            return transition
        case let .symbolReplace(configuration):
            let effect = ORBTransitionEffect()
            effect.type = .replace
            effect.setIntegerArgumentValue(configuration.transitionFlags.rawValue, at: 0)
            effect.setArgumentValue(1, at: 1)
            let transition = ORBTransition()
            transition.method = .binary
            transition.addEffect(effect)
            return transition
        }
    }

    package var numericValue: Float? {
        guard case let .named(transition) = storage,
              case let .numericText(config) = transition.name,
              case let .automatic(value) = config.direction
        else { return nil }
        return value
    }

    // MARK: - ContentTransition.Options

    @_spi(Private)
    @frozen
    public struct Options: OptionSet {
        public let rawValue: UInt32

        @inlinable
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let addsDrawingGroup: ContentTransition.Options = .init(rawValue: 1 << 0)

        public static let animatesDifferentContent: ContentTransition.Options = .init(rawValue: 1 << 1)

        package static let formsGroup: ContentTransition.Options = .init(rawValue: 1 << 2)

        package static let implicitGroup: ContentTransition.Options = .init(rawValue: 1 << 3)

        package static let inherited: ContentTransition.Options = .addsDrawingGroup
    }

    // MARK: - ContentTransition.State

    package struct State: Equatable, EnvironmentKey {
        package static let defaultValue: ContentTransition.State = .init()

        package var transition: ContentTransition
        package var style: ContentTransition.Style
        package var animation: Animation?
        package var options: ContentTransition.Options

        package init(
            transition: ContentTransition = .default,
            style: ContentTransition.Style = .default,
            animation: Animation? = nil,
            options: ContentTransition.Options = .init()
        ) {
            self.transition = transition
            self.style = style
            self.animation = animation
            self.options = options
        }

        package var rasterizationOptions: RasterizationOptions {
            var rasterizationOptions = RasterizationOptions()
            rasterizationOptions.flags.subtract(.requiresLayer)
            rasterizationOptions.flags.formUnion(options.contains(.addsDrawingGroup) ? .isAccelerated : [])
            return rasterizationOptions
        }

        package mutating func applyDynamicTextAnimation(
            in transaction: Transaction
        ) {
            guard animation == nil,
                  !transaction.disablesAnimations,
                  style != .default
            else { return }
            animation = .default
        }
    }

    package mutating func applyEnvironmentValues(
        style: ContentTransition.Style,
        layoutDirection: LayoutDirection
    ) {
        switch storage {
        case var .named(transition):
            transition.style = transition.style ?? style
            transition.layoutDirection = transition.layoutDirection ?? layoutDirection
            storage = .named(transition)
        case var .custom(transition):
            transition.layoutDirection = transition.layoutDirection ?? layoutDirection
            storage = .custom(transition)
        case .symbolReplace:
            break
        }
    }

    private struct NamedKey: Hashable {
        var name: NamedTransition
        var isReplaceable: Bool
    }

    private static let _namedTransitions = AtomicBox(wrappedValue: [NamedKey: ORBTransition]())
}

// MARK: - ContentTransition.NumericTextConfiguration + Configuration

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension ContentTransition.NumericTextConfiguration {
    public static func fixed(downwards: Bool = false) -> Self {
        .init(direction: .fixed(downwards: downwards))
    }

    public static func automatic(value: Double) -> Self {
        .init(direction: .automatic(value: Float(value)))
    }

    public func axis(_ axis: Axis) -> Self {
        var config = self
        config.axis = axis
        return config
    }

    public func delay(_ duration: Double) -> Self {
        var config = self
        config.delay = Float(duration)
        return config
    }

    public func scale(_ scale: CGFloat) -> Self {
        var config = self
        config.scale = Float(scale)
        return config
    }

    public func blur(radius: CGFloat) -> Self {
        var config = self
        config.blur = Float(radius)
        return config
    }

    public func relativeOffset(_ offset: CGFloat) -> Self {
        var config = self
        config.offset = Float(offset)
        return config
    }

    public func reversed(_ reversed: Bool) -> Self {
        var config = self
        config.options.setValue(reversed, for: .reversed)
        return config
    }
}

// MARK: - View + ContentTransition

@available(OpenSwiftUI_v4_0, *)
extension View {
    @_alwaysEmitIntoClient
    nonisolated public func contentTransition(_ transition: ContentTransition) -> some View {
        environment(\.contentTransition, transition)
    }

    @_spi(Private)
    @inlinable
    nonisolated public func contentTransition(
        _ transition: ContentTransition,
        animation: Animation? = nil,
        options: ContentTransition.Options = .init()
    ) -> some View {
        modifier(_ContentTransitionModifier(transition: transition, animation: animation, options: options))
    }

    @_spi(Private)
    @inlinable
    nonisolated public func contentTransitionGroup() -> some View {
        modifier(_ContentTransitionGroup())
    }

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    nonisolated public func contentTransitionPrefersCharacterOrder() -> some View {
        preferTextLayoutManager()
    }
}

// MARK: - _ContentTransitionModifier

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _ContentTransitionModifier: MultiViewModifier, PrimitiveViewModifier {
    @usableFromInline var transition: ContentTransition
    @usableFromInline var animation: Animation?
    @usableFromInline var options: ContentTransition.Options

    @inlinable
    init(transition: ContentTransition, animation: Animation?, options: ContentTransition.Options) {
        self.transition = transition
        self.animation = animation
        self.options = options
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.environment = Attribute(ChildEnvironment(modifier: modifier.value, environment: inputs.environment))
        return body(_Graph(), inputs)
    }

    private struct ChildEnvironment: Rule, AsyncAttribute {
        @Attribute var modifier: _ContentTransitionModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            var state = environment.contentTransitionState
            state.transition = modifier.transition
            state.animation = modifier.animation
            state.options = state.options.intersection(.inherited).union(modifier.options)
            environment.contentTransitionState = state
            return environment
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension _ContentTransitionModifier: Sendable {}

// MARK: - EnvironmentValues + ContentTransition

@available(OpenSwiftUI_v4_0, *)
extension EnvironmentValues {
    package var contentTransitionState: ContentTransition.State {
        get { self[ContentTransition.State.self] }
        set { self[ContentTransition.State.self] = newValue }
    }

    /// The current method of animating the contents of views.
    public var contentTransition: ContentTransition {
        get { contentTransitionState.transition }
        set { contentTransitionState.transition = newValue }
    }

    @_spi(Private)
    public var contentTransitionStyle: ContentTransition.Style {
        get { contentTransitionState.style }
        set { contentTransitionState.style = newValue }
    }

    @_spi(Private)
    public var contentTransitionAnimation: Animation? {
        get { contentTransitionState.animation }
        set { contentTransitionState.animation = newValue }
    }

    /// A Boolean value that controls whether views that render content
    /// transitions use GPU-accelerated rendering.
    ///
    /// Setting this value to `true` causes OpenSwiftUI to wrap content transitions
    /// with a ``View/drawingGroup(opaque:colorMode:)`` modifier.
    public var contentTransitionAddsDrawingGroup: Bool {
        get { contentTransitionState.options.contains(.addsDrawingGroup) }
        set { contentTransitionState.options.setValue(newValue, for: .addsDrawingGroup) }
    }

    package var contentTransitionGroupEffect: ContentTransitionEffect {
        var state = contentTransitionState
        state.options.insert(.formsGroup)
        state.transition.applyEnvironmentValues(style: state.style, layoutDirection: layoutDirection)
        return ContentTransitionEffect(state: state)
    }
}

// MARK: - _ContentTransitionGroup

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _ContentTransitionGroup: MultiViewModifier, PrimitiveViewModifier {
    @usableFromInline
    init() {
        _openSwiftUIEmptyStub()
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<_ContentTransitionGroup>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let effect = inputs.base.mapEnvironment(id: .contentTransitionGroupEffect) { $0.contentTransitionGroupEffect }
        return ContentTransitionEffect._makeView(modifier: .init(effect), inputs: inputs, body: body)
    }
}

// MARK: - ContentTransitionEffect

package struct ContentTransitionEffect: _RendererEffect {
    package var state: ContentTransition.State

    package init(state: ContentTransition.State) {
        self.state = state
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .contentTransition(state)
    }

    nonisolated package static func _makeView(
        modifier: _GraphValue<ContentTransitionEffect>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _makeRendererEffect(effect: modifier, inputs: inputs, body: body)
    }

    struct Init: Rule, AsyncAttribute {
        @Attribute var environment: EnvironmentValues
        var defaultTransition: ContentTransition

        var value: ContentTransitionEffect {
            var state = environment.contentTransitionState
            if state.transition.isNamed(.default) {
                state.transition = defaultTransition
                state.transition.isReplaceable = true
            }
            state.transition.applyEnvironmentValues(
                style: state.style,
                layoutDirection: environment.layoutDirection
            )
            state.options.insert(.implicitGroup)
            return ContentTransitionEffect(state: state)
        }
    }
}

extension CachedEnvironment.ID {
    static let contentTransitionGroupEffect = CachedEnvironment.ID()
}

// MARK: - ContentTransition + ProtobufMessage

extension ContentTransition: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch storage {
        case let .named(transition):
            try encoder.messageField(1, transition)
        case let .custom(transition):
            try encoder.messageField(2, transition)
        case let .symbolReplace(configuration):
            try encoder.messageField(4, configuration)
        }
        encoder.boolField(3, isReplaceable)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self = .default
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: storage = .named(try decoder.messageField(field))
            case 2: storage = .custom(try decoder.messageField(field))
            case 3: isReplaceable = try decoder.boolField(field)
            case 4: storage = .symbolReplace(try decoder.messageField(field))
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - ContentTransition.State + ProtobufMessage

extension ContentTransition.State: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, transition, defaultValue: .default)
        try encoder.messageField(2, style, defaultValue: .default)
        if let animation {
            try encoder.messageField(3, CodableAnimation(base: animation))
        }
        encoder.uintField(4, UInt(options.rawValue))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: transition = try decoder.messageField(field)
            case 2: style = try decoder.messageField(field)
            case 3: animation = try (decoder.messageField(field) as CodableAnimation).base
            case 4: options = .init(rawValue: try decoder.uint32Field(field))
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - ContentTransition.Style + ProtobufMessage

@_spi(Private)
extension ContentTransition.Style: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch storage {
        case .default: break
        case .sessionWidget: encoder.emptyField(1)
        case .animatedWidget: encoder.emptyField(2)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self = .default
        while let field = try decoder.nextField() {
            try decoder.skipField(field)
            switch field.tag {
            case 1: self = .sessionWidget
            case 2: self = .animatedWidget
            default: break
            }
        }
    }
}

@_spi(Private)
extension ContentTransition.Style: CodableByProtobuf {}

// MARK: - ContentTransition.NamedTransition + ProtobufMessage

extension ContentTransition.NamedTransition: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch name {
        case .default: break
        case .identity: encoder.emptyField(1)
        case .opacity: encoder.emptyField(2)
        case .diff: encoder.emptyField(3)
        case .fadeIfDifferent: encoder.emptyField(4)
        case let .text(different):
            encoder.messageField(5) { $0.boolField(1, different) }
        case let .numericText(configuration):
            try encoder.messageField(6, configuration)
        }
        if let layoutDirection {
            encoder.boolField(7, layoutDirection == .rightToLeft)
        }
        if let style {
            try encoder.messageField(8, style, defaultValue: .default)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                try decoder.skipField(field)
                name = .identity
            case 2:
                try decoder.skipField(field)
                name = .opacity
            case 3:
                try decoder.skipField(field)
                name = .diff
            case 4:
                try decoder.skipField(field)
                name = .fadeIfDifferent
            case 5:
                name = .text(different: try decoder.messageField(field) { decoder in
                    var different = false
                    while let field = try decoder.nextField() {
                        if field.tag == 1 {
                            different = try decoder.boolField(field)
                        } else {
                            try decoder.skipField(field)
                        }
                    }
                    return different
                })
            case 6: name = .numericText(try decoder.messageField(field))
            case 7: layoutDirection = try decoder.boolField(field) ? .rightToLeft : .leftToRight
            case 8: style = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - ContentTransition.NumericTextConfiguration + ProtobufMessage

@_spi(Private)
extension ContentTransition.NumericTextConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch direction {
        case let .fixed(downwards): encoder.boolField(1, !downwards)
        case let .automatic(value): encoder.floatField(2, value, defaultValue: nil)
        }
        if let axis {
            encoder.boolField(3, axis == .vertical, defaultValue: nil)
        }
        encoder.boolField(4, options.contains(.reversed))
        encoder.floatField(5, delay, defaultValue: 0.15)
        encoder.floatField(6, scale, defaultValue: 51.0 / 128)
        if options.contains(.relativeBlur) {
            // The baseline writes relative blur under the absolute-blur tag.
            encoder.floatField(7, relativeBlur, defaultValue: 0.25)
        } else {
            encoder.floatField(7, blur)
        }
        encoder.floatField(8, offset, defaultValue: 19.0 / 32)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: direction = .fixed(downwards: try !decoder.boolField(field))
            case 2: direction = .automatic(value: try decoder.floatField(field))
            case 3: axis = try decoder.boolField(field) ? .vertical : .horizontal
            case 4: options.setValue(try decoder.boolField(field), for: .reversed)
            case 5: delay = try decoder.floatField(field)
            case 6: scale = try decoder.floatField(field)
            case 7: blur = try decoder.floatField(field)
            case 8: offset = try decoder.floatField(field)
            case 9: relativeBlur = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - ContentTransition.CustomTransition + ProtobufMessage

extension ContentTransition.CustomTransition: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, method.method, defaultValue: .empty)
        for effect in effects {
            try encoder.messageField(2, effect)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(effects: [], method: .init(method: .empty))
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: method.method = try decoder.enumField(field) ?? .empty
            case 2: effects.append(try decoder.messageField(field))
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - ContentTransition.Effect + ProtobufMessage

@_spi(Private)
extension ContentTransition.Effect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, type.type, defaultValue: .alpha)
        encoder.floatField(4, begin)
        encoder.floatField(9, duration, defaultValue: 1)
        encoder.enumField(6, events, defaultValue: .addRemove)
        switch type.arg0 {
        case .none: break
        case let .float(value): encoder.floatField(2, value)
        case let .int(value): encoder.uintField(7, UInt(value))
        }
        switch type.arg1 {
        case .none: break
        case let .float(value): encoder.floatField(3, value)
        case let .int(value): encoder.uintField(8, UInt(value))
        }
        encoder.uintField(10, UInt(flags.rawValue))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(type: .opacity)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: type.type = try decoder.enumField(field) ?? .none
            case 2: type.arg0 = .float(try decoder.floatField(field))
            case 3: type.arg1 = .float(try decoder.floatField(field))
            case 4: begin = try decoder.floatField(field)
            case 5: duration = try decoder.floatField(field) - begin
            case 6: events = try decoder.enumField(field) ?? .addRemove
            case 7: type.arg0 = .int(try decoder.uint32Field(field))
            // The target decoder skips integer arg1 (tag 8).
            case 9: duration = try decoder.floatField(field)
            case 10: flags = .init(rawValue: try decoder.uint32Field(field))
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - RenderBox Transition Types + ProtobufEnum

extension ORBTransitionMethod: ProtobufEnum {
    package init?(protobufValue: UInt) {
        guard let value = UInt32(exactly: protobufValue) else { return nil }
        self.init(rawValue: value)
    }
}

extension ORBTransitionEffectType: ProtobufEnum {
    package init?(protobufValue: UInt) {
        guard let value = UInt32(exactly: protobufValue) else { return nil }
        self.init(rawValue: value)
    }
}

extension ORBTransitionEvents: ProtobufEnum {
    package init?(protobufValue: UInt) {
        guard let value = UInt32(exactly: protobufValue) else { return nil }
        self.init(rawValue: value)
    }
}

// MARK: - ContentTransition.NamedTransition backend descriptors

extension ContentTransition.NamedTransition {
    package func makeRBTransition() -> ORBTransition {
        let transition = ORBTransition()
        switch name {
        case .identity:
            transition.method = .none
        case .default, .opacity, .diff, .fadeIfDifferent, .text:
            if case .text(different: true) = name {
                switch style?.storage {
                case .sessionWidget:
                    makeSessionWidgetTransition(transition)
                    return transition
                case .animatedWidget:
                    makeAnimatedWidgetTransition(transition)
                    return transition
                default:
                    break
                }
            }
            switch name {
            case .opacity: transition.method = .none
            case .diff, .text(different: false): transition.method = .diff
            default: transition.method = .binary
            }
            let effect = ORBTransitionEffect()
            effect.duration = 0
            transition.addEffect(effect)
        case let .numericText(configuration):
            makeNumericTransition(transition, configuration: configuration)
        }
        return transition
    }

    private func makeNumericTransition(
        _ transition: ORBTransition,
        configuration: ContentTransition.NumericTextConfiguration
    ) {
        transition.method = .prefixAndSuffix
        let reversed = configuration.options.contains(.reversed)
        let sequence = ORBTransitionEffect()
        if configuration.axis == .vertical {
            sequence.type = reversed ? .sequenceDown : .sequenceUp
        } else {
            sequence.type = reversed != (layoutDirection == .rightToLeft) ? .sequenceRight : .sequenceLeft
        }
        sequence.beginTime = configuration.delay
        sequence.duration = 1 / configuration.maxDurationMultiple
        transition.addEffect(sequence)

        let opacity = ORBTransitionEffect()
        opacity.animationIndex = 0
        transition.addEffect(opacity)

        let blur = ORBTransitionEffect()
        if configuration.options.contains(.relativeBlur) {
            blur.type = .relativeBlur
            blur.setArgumentValue(configuration.relativeBlur, at: 1)
        } else {
            blur.type = .blur
            blur.setArgumentValue(configuration.blur, at: 0)
        }
        blur.animationIndex = 0
        transition.addEffect(blur)

        let translation = ORBTransitionEffect()
        translation.type = .relativeTranslation
        let offset: Float
        switch configuration.direction {
        case let .fixed(downwards):
            offset = downwards ? -configuration.offset : configuration.offset
            translation.flags = .removeInverts
        case .automatic:
            offset = configuration.offset
            translation.flags = .init(rawValue: 3)
        }
        translation.setArgumentValue(configuration.axis == .vertical ? offset : 0, at: 0)
        translation.setArgumentValue(configuration.axis == .vertical ? 0 : offset, at: 1)
        translation.animationIndex = 1
        transition.addEffect(translation)

        let scale = ORBTransitionEffect()
        scale.type = .scaleCenter
        scale.setArgumentValue(configuration.scale, at: 0)
        scale.animationIndex = 0
        transition.addEffect(scale)

        let animation = ORBAnimation()
        animation.addSpringDuration(0.5, mass: 1, stiffness: 344, damping: 37, initialVelocity: 0)
        animation.addSpringDuration(0.8, mass: 2, stiffness: 470, damping: 34, initialVelocity: 0)
        transition.animation = animation
    }

    private func makeSessionWidgetTransition(_ transition: ORBTransition) {
        transition.method = .prefixAndSuffix
        transition.maxChanges = 10
        let rightToLeft = layoutDirection == .rightToLeft
        let sequence = ORBTransitionEffect()
        sequence.type = rightToLeft ? .sequenceRight : .sequenceLeft
        sequence.events = .init(rawValue: 7)
        sequence.flags = .removeInverts
        sequence.beginTime = 0.04
        sequence.duration = 1
        transition.addEffect(sequence)

        let opacity = ORBTransitionEffect()
        opacity.events = .init(rawValue: 7)
        transition.addEffect(opacity)

        let delayedOpacity = ORBTransitionEffect()
        delayedOpacity.events = .init(rawValue: 11)
        delayedOpacity.beginTime = 0.33
        delayedOpacity.duration = 0.67
        transition.addEffect(delayedOpacity)

        let anchor = ORBTransitionEffect()
        anchor.type = rightToLeft ? .anchorRight : .anchorLeft
        anchor.events = .init(rawValue: 7)
        transition.addEffect(anchor)

        let blur = ORBTransitionEffect()
        blur.type = .relativeBlur
        blur.setArgumentValue(0.25, at: 1)
        blur.beginTime = 0.33
        blur.duration = 0.67
        transition.addEffect(blur)

        let originScale = ORBTransitionEffect()
        originScale.type = .scaleOrigin
        originScale.setArgumentValue(0.5, at: 0)
        originScale.events = .init(rawValue: 7)
        transition.addEffect(originScale)

        let scale = ORBTransitionEffect()
        scale.type = .scaleCenter
        scale.setArgumentValue(0.85, at: 0)
        scale.events = .init(rawValue: 11)
        scale.beginTime = 0.33
        scale.duration = 0.67
        transition.addEffect(scale)
    }

    private func makeAnimatedWidgetTransition(_ transition: ORBTransition) {
        transition.method = .binary
        let opacity = ORBTransitionEffect()
        opacity.insertAnimationIndex = 1
        opacity.removeAnimationIndex = 0
        transition.addEffect(opacity)

        let scale = ORBTransitionEffect()
        scale.type = .scaleCenter
        scale.setArgumentValue(0.7, at: 0)
        scale.insertAnimationIndex = 1
        scale.removeAnimationIndex = 0
        transition.addEffect(scale)

        let blur = ORBTransitionEffect()
        blur.type = .relativeBlur
        blur.setArgumentValue(0.25, at: 1)
        blur.insertAnimationIndex = 1
        blur.removeAnimationIndex = 0
        transition.addEffect(blur)

        let animation = ORBAnimation()
        animation.addSpringDuration(0.5, mass: 1, stiffness: 331, damping: 36.4, initialVelocity: 0)
        animation.addSpringDuration(0.8, mass: 2, stiffness: 300, damping: 50, initialVelocity: 0)
        transition.animation = animation
    }
}
