//
//  ContentTransition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

public import OpenCoreGraphicsShims
package import OpenRenderBoxShims

// MARK: - ContentTransition [WIP]

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
//        case custom(ContentTransition.CustomTransition)
        case symbolReplace(_SymbolEffect.ReplaceConfiguration)
    }

    // MARK: - ContentTransition.Style

    @_spi(Private)
    public struct Style: Hashable, Sendable/*, Codable*/ {
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

    // MARK: - ContentTransition.NumericTextConfiguration [WIP]

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
        private var _offset: UInt8 = 19

        @_spi(Private)
        package init(
            direction: ContentTransition.NumericTextConfiguration.Direction = .fixed(downwards: false),
            axis: Axis? = nil,
            options: ContentTransition.NumericTextConfiguration.Options = .relativeBlur
        ) {
            self.direction = direction
            self.axis = axis
            self.options = options
        }

        @_spi(Private)
        package var delay: Float {
            get { _openSwiftUIUnimplementedFailure() }
            set { _openSwiftUIUnimplementedFailure() }
        }

        package var maxDurationMultiple: Float {
            _openSwiftUIUnimplementedFailure()
        }

        package var scale: Float {
            get { _openSwiftUIUnimplementedFailure() }
            set { _openSwiftUIUnimplementedFailure() }
        }

        package var blur: Float {
            get { _openSwiftUIUnimplementedFailure() }
            set { _openSwiftUIUnimplementedFailure() }
        }

        package var relativeBlur: Float {
            get { _openSwiftUIUnimplementedFailure() }
            set { _openSwiftUIUnimplementedFailure() }
        }

        package var offset: Float {
            get { _openSwiftUIUnimplementedFailure() }
            set { _openSwiftUIUnimplementedFailure() }
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
            self.init(type: .opacity, arg0: .none, arg1: .none)
        }

        @available(*, deprecated, message: "use opacity variable")
        public static func opacity(_ opacity: Double = 0) -> ContentTransition.EffectType {
            self.init(type: .opacity, arg0: .none, arg1: .none)
        }

        public static func blur(radius: CGFloat) -> ContentTransition.EffectType {
            self.init(type: .blur, arg0: .float(Float(radius)), arg1: .none)
        }

        @available(OpenSwiftUI_v6_0, *)
        public static func relativeBlur(scale: CGSize) -> ContentTransition.EffectType {
            self.init(type: .relativeBlur, arg0: .float(Float(scale.width)), arg1: .float(Float(scale.height)))
        }

        public static func scale(_ scale: CGFloat = 0) -> ContentTransition.EffectType {
            self.init(type: .scale, arg0: .float(Float(scale)), arg1: .none)
        }

        public static func translation(_ size: CGSize) -> ContentTransition.EffectType {
            self.init(type: .translationSize, arg0: .float(Float(size.width)), arg1: .float(Float(size.height)))
        }

        @available(OpenSwiftUI_v6_0, *)
        public static func translation(scale: CGSize) -> ContentTransition.EffectType {
            self.init(type: .translationScale, arg0: .float(Float(scale.width)), arg1: .float(Float(scale.height)))
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
            _openSwiftUIUnimplementedFailure()
        }

        @available(OpenSwiftUI_v6_0, *)
        public func removeInverts(_ state: Bool) -> ContentTransition.Effect {
            _openSwiftUIUnimplementedFailure()
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

    // TODO
    package struct State {}

    /// The identity content transition, which indicates that content changes
    /// shouldn't animate.
    ///
    /// You can pass this value to a ``View/contentTransition(_:)``
    /// modifier to selectively disable animations that would otherwise
    /// be applied by a ``withAnimation(_:_:)`` block.
    public static let identity: ContentTransition = .init(storage: .named(.init())) // FIXME

    /// A content transition that indicates content fades from transparent
    /// to opaque on insertion, and from opaque to transparent on removal.
    public static let opacity: ContentTransition = .init(storage: .named(.init())) // FIXME

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
    public static let interpolate: ContentTransition = .init(storage: .named(.init())) // FIXME

}

// FIXME: ORB

package enum ORBTransitionMethod: Int {
    case empty
    case diff
    case forwards
    case backwards
    case prefix
    case suffix
    case binary
    case none
    case prefixAndSuffix
}

// ProtobufEnum
package struct ORBTransitionEvents: OptionSet {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let add: ORBTransitionEvents = .init(rawValue: 1)
    public static let remove: ORBTransitionEvents = .init(rawValue: 2)
    public static let addRemove: ORBTransitionEvents = .init(rawValue: 3)
}

package struct ORBTransitionEffectFlags: OptionSet {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

package enum ORBTransitionEffectType: UInt32, Equatable {
    case opacity = 1
    case scale = 2
    case translationSize = 3
    case blur = 4
    case matchMove = 5
    case translationScale = 15
    case relativeBlur = 16
}
