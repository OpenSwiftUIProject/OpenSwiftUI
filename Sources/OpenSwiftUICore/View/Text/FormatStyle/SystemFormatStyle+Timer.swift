//
//  SystemFormatStyle+Timer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 451E0D01411EFA2EC2112721F598BB0F (SwiftUICore)

public import Foundation

// MARK: - FormatStyle + Timer

@available(OpenSwiftUI_v6_0, *)
extension FormatStyle where Self == SystemFormatStyle.Timer {
    /// Create a timer format style that counts down in the given interval.
    ///
    /// A timer styled display that counts down to zero within the given `interval`.
    ///
    /// - Parameters:
    ///   - interval: The interval during which the timer counts down.
    ///   - showsHours: If true, the timer shows the hours as a separate element on the
    ///     formatted string, as long as the duration is at least one hour. If false, the
    ///     timer displays minute values greather than sixty.
    ///   - maxFieldCount: The number of fields that can be shown at once. For example,
    ///     1 hour, 34 minutes is shown as `1:34:00` by default, but as `1:34` if the
    ///     `maxFieldCount` is set to two. The style automatically excludes more significant
    ///     fields if their value is zero and they are not necessary for the format pattern,
    ///     making room for less significant fields.
    ///   - maxPrecision: The precision at which the input is formatted. E.g. by
    ///     default, seconds are shown, making the maximum precision one second. Setting
    ///     the maximum precision to `.seconds(60)` would only allow hours and minutes to
    ///     be shown.
    public static func timer(
        countingDownIn interval: Range<Date>,
        showsHours: Bool = true,
        maxFieldCount: Int = 3,
        maxPrecision: Duration = .seconds(1)
    ) -> SystemFormatStyle.Timer {
        SystemFormatStyle.Timer(
            countingDownIn: interval,
            showsHours: showsHours,
            maxFieldCount: maxFieldCount,
            maxPrecision: maxPrecision
        )
    }

    /// Create a timer format style that counts up to the given interval.
    ///
    /// A timer styled display that counts up from zero within the given `interval`.
    /// `timerInterval`.
    ///
    /// - Parameters:
    ///   - interval: The interval during which the timer counts up.
    ///   - showsHours: If true, the timer shows the hours as a separate element on the
    ///     formatted string, as long as the duration is at least one hour. If false, the
    ///     timer displays minute values greather than sixty.
    ///   - maxFieldCount: The number of fields that can be shown at once. For example,
    ///     1 hour, 34 minutes is shown as `1:34:00` by default, but as `1:34` if the
    ///     `maxFieldCount` is set to two. The style automatically excludes more significant
    ///     fields if their value is zero and they are not necessary for the format pattern,
    ///     making room for less significant fields.
    ///   - maxPrecision: The precision at which the input is formatted. E.g. by
    ///     default, seconds are shown, making the maximum precision one second. Setting
    ///     the maximum precision to `.seconds(60)` would only allow hours and minutes to
    ///     be shown.
    public static func timer(
        countingUpIn interval: Range<Date>,
        showsHours: Bool = true,
        maxFieldCount: Int = 3,
        maxPrecision: Duration = .seconds(1)
    ) -> SystemFormatStyle.Timer {
        SystemFormatStyle.Timer(
            countingUpIn: interval,
            showsHours: showsHours,
            maxFieldCount: maxFieldCount,
            maxPrecision: maxPrecision
        )
    }
}

// MARK: - SystemFormatStyle.Timer

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle {
    /// The system timer format style.
    public struct Timer: Sendable {
        public typealias FormatInput = Date

        enum CountingMode: Codable, Hashable {
            case timer(countsdown: Bool)
            case stopwatch
        }

        var countingMode: CountingMode
        private var startDate: Date
        private var interval: Duration
        private var showsHours: Bool
        private var maxFieldCount: Int
        private var maxPrecision: Duration
        private var precision: Duration
        private var sizeVariant: TextSizeVariant = .regular
        var locale: Locale = .autoupdatingCurrent
        var redactUsingDashes: Bool = true
        var forceNoPadding: Bool = false
        private var capitalizationContext: FormatStyleCapitalizationContext = .unknown
        @ProxyCodable var textAlignment: TextAlignment? = nil
        @CodableAttributeEffect private var monospacedDigits: CodableAttributeEffect<MonospacedDigitEffect>
        @CodableAttributeEffect private var adjustedColon: CodableAttributeEffect<AdjustedColonEffect>
        @CodableAttributeEffect private var superscript: CodableAttributeEffect<SuperscriptEffect<MonospacedDigitEffect>>

        /// Create a timer format style that counts down from the given interval.
        ///
        /// A timer styled display that counts from the given `timerInterval` down to zero.
        ///
        /// - Parameters:
        ///   - interval: The interval during which the timer counts down.
        ///   - showsHours: If true, the timer shows the hours as a separate element on the
        ///     formatted string, as long as the duration is at least one hour. If false, the
        ///     timer displays minute values greather than sixty.
        ///   - maxFieldCount: The number of fields that can be shown at once. For example,
        ///     1 hour, 34 minutes is shown as `1:34:00` by default, but as `1:34` if the
        ///     `maxFieldCount` is set to two. The style automatically excludes more significant
        ///     fields if their value is zero and they are not necessary for the format pattern,
        ///     making room for less significant fields.
        ///   - maxPrecision: The precision at which the input is formatted. E.g. by
        ///     default, seconds are shown, making the maximum precision one second. Setting
        ///     the maximum precision to `.seconds(60)` would only allow hours and minutes to
        ///     be shown.
        public init(
            countingDownIn interval: Range<Date>,
            showsHours: Bool = true,
            maxFieldCount: Int = 3,
            maxPrecision: Duration = .seconds(1)
        ) {
            self.init(
                countingMode: .timer(countsdown: true),
                interval: interval,
                showsHours: showsHours,
                maxFieldCount: maxFieldCount,
                maxPrecision: maxPrecision
            )
        }

        /// Create a timer format style that counts up to the given interval.
        ///
        /// A timer styled display that counts from zero up to the given `timerInterval`.
        ///
        /// - Parameters:
        ///   - interval: The interval during which the timer counts up.
        ///   - showsHours: If true, the timer shows the hours as a separate element on the
        ///     formatted string, as long as the duration is at least one hour. If false, the
        ///     timer displays minute values greather than sixty.
        ///   - maxFieldCount: The number of fields that can be shown at once. For example,
        ///     1 hour, 34 minutes is shown as `1:34:00` by default, but as `1:34` if the
        ///     `maxFieldCount` is set to two. The style automatically excludes more significant
        ///     fields if their value is zero and they are not necessary for the format pattern,
        ///     making room for less significant fields.
        ///   - maxPrecision: The precision at which the input is formatted. E.g. by
        ///     default, seconds are shown, making the maximum precision one second. Setting
        ///     the maximum precision to `.seconds(60)` would only allow hours and minutes to
        ///     be shown.
        public init(
            countingUpIn interval: Range<Date>,
            showsHours: Bool = true,
            maxFieldCount: Int = 3,
            maxPrecision: Duration = .seconds(1)
        ) {
            self.init(
                countingMode: .timer(countsdown: false),
                interval: interval,
                showsHours: showsHours,
                maxFieldCount: maxFieldCount,
                maxPrecision: maxPrecision
            )
        }

        init(
            countingMode: CountingMode,
            interval: Range<Date>,
            showsHours: Bool,
            maxFieldCount: Int,
            maxPrecision: Duration
        ) {
            let maxPrecision = min(maxPrecision, .seconds(3600))
            self.countingMode = countingMode
            self.startDate = interval.lowerBound
            self.interval = .seconds(interval.upperBound.timeIntervalSince(interval.lowerBound))
            self.showsHours = showsHours
            self.maxFieldCount = maxFieldCount
            self.maxPrecision = maxPrecision
            self.precision = maxPrecision
        }
    }
}

// MARK: - AttributeEffect

protocol AttributeEffect {
    static var attributes: AttributeContainer { get }

    static func apply(
        attributes: AttributeContainer,
        to string: inout AttributedString,
        locale: Locale
    )
}

// MARK: - CodableAttributeEffect

@propertyWrapper
struct CodableAttributeEffect<Effect>: Codable, Hashable where Effect: AttributeEffect {
    var attributes: CodableNSAttributes?

    init(_ effect: Effect.Type = Effect.self) {
        attributes = nil
    }

    var wrappedValue: CodableAttributeEffect<Effect> {
        get { self }
        set { self = newValue }
    }

    func callAsFunction(
        _ string: inout AttributedString,
        locale: Locale
    ) {
        let attributes = attributes.map {
            AttributeContainer($0.wrappedValue)
        } ?? Effect.attributes
        Effect.apply(attributes: attributes, to: &string, locale: locale)
    }

    mutating func makePlatformAttributes(
        resolver: inout PlatformAttributeResolver
    ) {
        attributes = CodableNSAttributes(
            resolver.platformAttributes(
                for: Effect.attributes,
                includeDefaultValueAttributes: false
            )
        )
    }

    static func == (
        lhs: CodableAttributeEffect<Effect>,
        rhs: CodableAttributeEffect<Effect>
    ) -> Bool {
        lhs.attributes == rhs.attributes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(attributes)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(attributes, forKey: .attributes)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try container.decodeIfPresent(
            CodableNSAttributes.self,
            forKey: .attributes
        )
    }

    private enum CodingKeys: CodingKey {
        case attributes
    }
}

// MARK: - MonospacedDigitEffect

private enum MonospacedDigitEffect: AttributeEffect {
    static let attributes: AttributeContainer = {
        var attributes = AttributeContainer()
        attributes.addFontModifier(Font.MonospacedDigitModifier.self)
        return attributes
    }()

    static func apply(
        attributes: AttributeContainer,
        to string: inout AttributedString,
        locale: Locale
    ) {
        string.mergeAttributes(attributes)
    }
}

// MARK: - AdjustedColonEffect

private enum AdjustedColonEffect: AttributeEffect {
    static let attributes: AttributeContainer = {
        var attributes = AttributeContainer()
        attributes.addFontModifier(Font.StylisticAlternativeModifier(alternative: .three))
        return attributes
    }()

    static func apply(
        attributes: AttributeContainer,
        to string: inout AttributedString,
        locale: Locale
    ) {
        for index in string.characters.indices {
            if string.characters[index] == ":" {
                string[index...index].mergeAttributes(attributes)
            }
        }
    }
}

// MARK: - SuperscriptEffect

private enum SuperscriptEffect<Base>: AttributeEffect where Base: AttributeEffect {
    static var attributes: AttributeContainer {
        Base.attributes.superscript(.default)
    }

    static func apply(
        attributes: AttributeContainer,
        to string: inout AttributedString,
        locale: Locale
    ) {
        guard let decimalSeparator = locale.decimalSeparator,
              let separatorRange = string.characters.firstRange(of: decimalSeparator)
        else { return }
        let superscriptRange = separatorRange.upperBound...
        guard string.characters[superscriptRange].allSatisfy(\.isNumber) else {
            return
        }
        string[superscriptRange].mergeAttributes(attributes)
        string.removeSubrange(separatorRange)
    }
}

// MARK: - AttributeContainer + addFontModifier

extension AttributeContainer {
    mutating func addFontModifier<Modifier>(_ modifier: Modifier) where Modifier: FontModifier {
        var modifiers = self.openSwiftUI.fontModifiers ?? []
        modifiers.append(.dynamic(modifier))
        self.openSwiftUI.fontModifiers = modifiers
    }

    mutating func addFontModifier<Modifier>(_ modifier: Modifier.Type) where Modifier: StaticFontModifier {
        var modifiers = self.openSwiftUI.fontModifiers ?? []
        modifiers.append(.static(modifier))
        self.openSwiftUI.fontModifiers = modifiers
    }
}

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.Timer: FormatStyle {
    public func format(_ input: Date) -> AttributedString {
        _openSwiftUIUnimplementedFailure()
    }

    public func locale(_ locale: Locale) -> SystemFormatStyle.Timer {
        var style = self
        style.locale = locale
        return style
    }
}
