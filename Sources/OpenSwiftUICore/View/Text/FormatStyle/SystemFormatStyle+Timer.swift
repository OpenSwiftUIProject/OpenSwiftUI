//
//  SystemFormatStyle+Timer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 451E0D01411EFA2EC2112721F598BB0F (SwiftUICore)

public import Foundation

#if canImport(Accessibility)
import Accessibility
#endif

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
        var maxFieldCount: Int
        private var maxPrecision: Duration
        private var precision: Duration
        var sizeVariant: TextSizeVariant = .regular
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
        #if canImport(Darwin)
        let attributes = attributes.map {
            AttributeContainer($0.wrappedValue)
        } ?? Effect.attributes
        #else
        // TODO: Use the decoded attributes once swift-foundation supports bridging NSAttributedString attributes to AttributeContainer.
        _openSwiftUIPlatformUnimplementedWarning()
        let attributes = Effect.attributes
        #endif
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

// MARK: - SystemFormatStyle + lessThanOneMinuteString

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle {
    static func lessThanOneMinuteString(
        _ string: AttributedString,
        locale: Locale,
        width: Duration.UnitsFormatStyle.UnitWidth
    ) -> AttributedString {
        #if canImport(Darwin)
        let resource: LocalizedStringResource
        if width == .narrow {
            resource = LocalizedStringResource(
                "<1m (narrow)",
                defaultValue: "<\(string, options: [])",
                table: "SystemFormatStyle",
                locale: locale,
                bundle: .atURL(Bundle.systemFormatStyle.bundleURL),
                comment: "Less than one minute. The argument provides '1m' as localized by ICU. Ideally, the string is visually not too different compared to just '1m', but it also shouldn't appear too mathematical."
            )
        } else if width == .condensedAbbreviated {
            resource = LocalizedStringResource(
                "<1min (condensedAbbreviated)",
                defaultValue: "<\(string, options: [])",
                table: "SystemFormatStyle",
                locale: locale,
                bundle: .atURL(Bundle.systemFormatStyle.bundleURL),
                comment: "Less than one minute. The argument provides '1min' as localized by ICU. Ideally, the string is visually not too different compared to just '1min', but it also shouldn't appear too mathematical."
            )
        } else {
            resource = LocalizedStringResource(
                "<1 minute (wide)",
                defaultValue: "<\(string, options: [])",
                table: "SystemFormatStyle",
                locale: locale,
                bundle: .atURL(Bundle.systemFormatStyle.bundleURL),
                comment: "Less than one minute. The argument provides '1 minute' as localized by ICU. Ideally, the string is visually not too different compared to just '1 minute', but it also shouldn't appear too mathematical."
            )
        }
        #if canImport(Accessibility)
        var result = AttributedString(
            localized: resource,
            including: \.accessibility
        )
        #else
        var result = AttributedString(localized: resource)
        #endif
        result.languageIdentifier = locale.language.maximalIdentifier
        return result
        #else
        var result = AttributedString("<")
        result.append(string)
        return result
        #endif
    }
}

// MARK: - SystemFormatStyle.Timer + FormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.Timer: FormatStyle {
    @inline(__always)
    private func representedDuration(at date: Date) -> Duration {
        let elapsed = Duration.seconds(date.timeIntervalSince(startDate))
        let duration = switch countingMode {
        case .timer(countsdown: true):
            interval - elapsed
        case .timer(countsdown: false), .stopwatch:
            elapsed
        }
        return min(max(duration, .zero), interval)
    }

    private var dropSubsecondsOnRedaction: Bool {
        guard capitalizationContext != .beginningOfSentence,
              capitalizationContext != .listItem,
              capitalizationContext != .middleOfSentence
        else {
            return false
        }

        switch textAlignment {
        case .leading:
            return locale.language.characterDirection == .leftToRight
        case .trailing:
            return locale.language.characterDirection == .rightToLeft
        default:
            return false
        }
    }

    private var smallestUnit: (
        unit: Duration.UnitsFormatStyle.Unit,
        fractionalDigits: Int
    ) {
        if !(.seconds(1.0 / 30.0) < precision) {
            return (.seconds, 2)
        } else if !(.seconds(0.1) < precision) {
            return (.seconds, 1)
        } else if !(.seconds(1) < precision) {
            return (.seconds, 0)
        } else if !(.seconds(60) < precision) {
            return (.minutes, 0)
        } else if !(.seconds(3600) < precision) {
            return (.hours, 0)
        } else {
            preconditionFailure("Timer encountered invalid precision of \(precision)")
        }
    }

    private var staticString: AttributedString {
        let unit = smallestUnit.unit
        let width: Duration.UnitsFormatStyle.UnitWidth = switch sizeVariant {
        case .regular: .wide
        case .compact: .condensedAbbreviated
        default: .narrow
        }
        let maximumUnitCount = if sizeVariant.rawValue > 2 {
            max(maxFieldCount + 2 - sizeVariant.rawValue, 1)
        } else {
            maxFieldCount
        }
        let style = Duration.UnitsFormatStyle(
            allowedUnits: [unit],
            width: width,
            maximumUnitCount: maximumUnitCount,
            zeroValueUnits: .show(length: 1),
            valueLength: nil,
            fractionalPart: .hide(rounded: .awayFromZero)
        )
        .attributed
        .locale(locale)
        let result = style.format(max(.seconds(1), precision))
        if unit == .minutes {
            return SystemFormatStyle.lessThanOneMinuteString(
                result,
                locale: locale,
                width: width
            )
        } else {
            return result
        }
    }

    private func increment(
        showingHours: Bool,
        showingMinutes: Bool,
        constrainToPrecision: Bool
    ) -> Duration {
        var fieldCount = maxFieldCount
        let usesMinimumFieldCount = sizeVariant.rawValue > 2
        if usesMinimumFieldCount {
            fieldCount = maxFieldCount + 2 - sizeVariant.rawValue
        }

        let naturalIncrement: Duration
        if usesMinimumFieldCount && fieldCount <= 0 {
            naturalIncrement = switch (showingHours, showingMinutes) {
            case (true, true): .seconds(3600)
            case (false, true), (true, false): .seconds(60)
            case (false, false): .seconds(1)
            }
        } else {
            if showingHours {
                fieldCount -= 1
            }
            if !showingMinutes {
                fieldCount += 1
            }
            naturalIncrement = switch fieldCount {
            case 0: .seconds(3600)
            case 1: .seconds(60)
            case 2: .seconds(1)
            default: precision
            }
        }
        return constrainToPrecision
            ? max(naturalIncrement, precision)
            : naturalIncrement
    }

    private func unitsToShow(
        greaterOrEqualTo unit: Duration.UnitsFormatStyle.Unit,
        duration: Duration,
        rounding: FloatingPointRoundingRule
    ) -> [Duration.UnitsFormatStyle.Unit] {
        var units = [unit]
        if unit == .seconds {
            if rounding == .awayFromZero {
                if Duration.seconds(59) < duration {
                    units.append(.minutes)
                }
            } else if !(duration < .seconds(60)) {
                units.append(.minutes)
            }
        }

        lazy var durationAllowsShowingHour: Bool = {
            if rounding == .awayFromZero {
                let threshold: Duration = unit == .seconds
                    ? .seconds(3599)
                    : .seconds(3540)
                return threshold < duration
            } else {
                return !(duration < .seconds(3600))
            }
        }()
        if unit != .hours,
           showsHours,
           durationAllowsShowingHour
        {
            units.append(.hours)
        }
        return units
    }

    private func timeStyle(
        for input: Duration,
        originalPrecision: Duration?
    ) -> (
        style: Duration.TimeFormatStyle.Attributed,
        applicableRange: ClosedRange<Duration>?,
        showsSubseconds: Bool
    )? {
        let maximumFieldCount = if sizeVariant.rawValue > 2 {
            max(maxFieldCount + 2 - sizeVariant.rawValue, 1)
        } else {
            maxFieldCount
        }
        guard maximumFieldCount >= 2 else {
            return nil
        }

        let originalPrecision = originalPrecision ?? precision
        lazy var naturalRoundingIncrementIfRoundingTowardZero = increment(
            showingHours: !(input < .seconds(3600)),
            showingMinutes: true,
            constrainToPrecision: false
        )
        lazy var actuallyDashesOutFields = {
            guard case .stopwatch = countingMode,
                  redactUsingDashes
            else {
                return false
            }
            return naturalRoundingIncrementIfRoundingTowardZero < originalPrecision
        }()

        let rounding: FloatingPointRoundingRule = switch countingMode {
        case .timer(countsdown: true) where !actuallyDashesOutFields:
            .awayFromZero
        case .timer(countsdown: false), .timer(countsdown: true), .stopwatch:
            .towardZero
        }
        let subHourRoundingIncrement = increment(
            showingHours: false,
            showingMinutes: true,
            constrainToPrecision: true
        )
        let inputDoesNotRoundToHour = if rounding == .awayFromZero {
            !((Duration.seconds(3600) - subHourRoundingIncrement) < input)
        } else {
            input < .seconds(3600)
        }
        lazy var shouldShowHoursMinutesSeconds =
            showsHours &&
            !(Duration.seconds(1) < subHourRoundingIncrement) &&
            maximumFieldCount > 2
        lazy var shouldShowHoursMinutes =
            showsHours &&
            !inputDoesNotRoundToHour &&
            (
                sizeVariant > .compact ||
                (
                    redactUsingDashes &&
                    Duration.seconds(1.0 / 30.0) < subHourRoundingIncrement &&
                    maxPrecision < subHourRoundingIncrement
                )
            )

        let pattern: Duration.TimeFormatStyle.Pattern
        let applicableRange: ClosedRange<Duration>?
        let showsSubseconds: Bool
        if shouldShowHoursMinutesSeconds {
            let fractionalDigits = maximumFieldCount > 3
                ? smallestUnit.fractionalDigits
                : 0
            let padHourToLength = countingMode == .stopwatch && !forceNoPadding
                ? (sizeVariant <= .compact ? 2 : 1)
                : 1
            pattern = .hourMinuteSecond(
                padHourToLength: padHourToLength,
                fractionalSecondsLength: fractionalDigits,
                roundFractionalSeconds: rounding
            )
            applicableRange = nil
            showsSubseconds = fractionalDigits > 0
        } else if shouldShowHoursMinutes {
            if !inputDoesNotRoundToHour,
               input < .seconds(3600)
            {
                pattern = .hourMinute(
                    padHourToLength: 1,
                    roundSeconds: rounding
                )
                applicableRange =
                    (Duration.seconds(3600) - subHourRoundingIncrement)...Duration.seconds(3600)
            } else {
                pattern = .hourMinute(
                    padHourToLength: 1,
                    roundSeconds: .towardZero
                )
                applicableRange = nil
            }
            showsSubseconds = false
        } else if !(Duration.seconds(1) < subHourRoundingIncrement) {
            let fractionalDigits = maximumFieldCount > 3
                ? smallestUnit.fractionalDigits
                : 0
            let padMinuteToLength = countingMode == .stopwatch && !forceNoPadding
                ? (sizeVariant <= .compact ? 2 : 1)
                : 1
            pattern = .minuteSecond(
                padMinuteToLength: padMinuteToLength,
                fractionalSecondsLength: fractionalDigits,
                roundFractionalSeconds: rounding
            )
            applicableRange = nil
            showsSubseconds = fractionalDigits > 0
        } else {
            return nil
        }

        let style = Duration.TimeFormatStyle(pattern: pattern)
            .locale(locale)
            .grouping(.never)
            .attributed
        return (style, applicableRange, showsSubseconds)
    }

    private func unitsStyle(
        for input: Duration
    ) -> (
        style: Duration.UnitsFormatStyle.Attributed,
        applicableRange: ClosedRange<Duration>?
    )? {
        if input < precision,
           Duration.seconds(1.0 / 30.0) < precision,
           maxPrecision < precision,
           Duration.seconds(1) < precision
        {
            return nil
        }

        let unit = smallestUnit.unit
        let maximumFieldCount = if sizeVariant.rawValue > 2 {
            max(maxFieldCount + 2 - sizeVariant.rawValue, 1)
        } else {
            maxFieldCount
        }
        lazy var isJustShowingSeconds =
            maximumFieldCount == 1 && input < .seconds(60)
        lazy var subHourRoundingIncrement = increment(
            showingHours: false,
            showingMinutes: !isJustShowingSeconds,
            constrainToPrecision: true
        )
        lazy var effectiveIncrement = increment(
            showingHours: showsHours &&
                !(input < (Duration.seconds(3600) - subHourRoundingIncrement)),
            showingMinutes: true,
            constrainToPrecision: true
        )
        lazy var isShowingMinutesAndSecondsOrMore =
            maximumFieldCount > 1 &&
            !(Duration.seconds(1) < effectiveIncrement)
        let isShowingSeconds = unit == .seconds &&
            (isJustShowingSeconds || isShowingMinutesAndSecondsOrMore)
        lazy var isJustNotShowingHour =
            maximumFieldCount > 1 &&
            input < .seconds(3600) &&
            (Duration.seconds(3600) - subHourRoundingIncrement) < input
        lazy var isJustNotShowingMinute =
            maximumFieldCount == 1 &&
            input < .seconds(60) &&
            (Duration.seconds(60) - subHourRoundingIncrement) < input

        let isCountdown: Bool = if case .timer(countsdown: true) = countingMode {
            true
        } else {
            false
        }
        let roundsAwayFromZero = isCountdown && (
            isShowingSeconds ||
            (unit == .seconds && (isJustNotShowingHour || isJustNotShowingMinute))
        )
        let rounding: FloatingPointRoundingRule = roundsAwayFromZero
            ? .awayFromZero
            : .towardZero
        let hasApplicableRange = isCountdown &&
            unit == .seconds &&
            (isJustNotShowingHour || isJustNotShowingMinute)

        let greaterOrEqualUnit: Duration.UnitsFormatStyle.Unit
        if isShowingSeconds {
            greaterOrEqualUnit = .seconds
        } else if unit == .hours {
            greaterOrEqualUnit = .hours
        } else {
            greaterOrEqualUnit = .minutes
        }
        let allowedUnits = Set(
            unitsToShow(
                greaterOrEqualTo: greaterOrEqualUnit,
                duration: input,
                rounding: rounding
            )
        )

        let applicableRange: ClosedRange<Duration>?
        if hasApplicableRange {
            let upperBound: Duration = input < .seconds(60)
                ? .seconds(60)
                : .seconds(3600)
            applicableRange =
                (upperBound - subHourRoundingIncrement)...upperBound
        } else {
            applicableRange = nil
        }

        let width: Duration.UnitsFormatStyle.UnitWidth = switch sizeVariant {
        case .regular: .wide
        case .compact: .condensedAbbreviated
        default: .narrow
        }
        let style = Duration.UnitsFormatStyle(
            allowedUnits: allowedUnits,
            width: width,
            maximumUnitCount: maximumFieldCount,
            zeroValueUnits: .show(length: 1),
            valueLength: nil,
            fractionalPart: .hide(rounded: rounding)
        )
        .locale(locale)
        .attributed
        return (style, applicableRange)
    }

    private func format(
        _ input: Duration,
        originalPrecision: Duration?
    ) -> AttributedString {
        let originalPrecision = originalPrecision ?? precision
        if redactUsingDashes,
           Duration.seconds(1.0 / 30.0) < precision,
           maxPrecision < precision
        {
            var style = self
            style.precision = max(
                maxPrecision,
                dropSubsecondsOnRedaction
                    ? .seconds(1)
                    : .seconds(1.0 / 30.0)
            )
            if let (timeStyle, _, showsSubseconds) = style.timeStyle(
                for: input,
                originalPrecision: originalPrecision
            ) {
                var result = timeStyle.format(input)
                monospacedDigits(&result, locale: locale)
                adjustedColon(&result, locale: locale)
                if showsSubseconds,
                   case .stopwatch = countingMode,
                   maxFieldCount >= 1
                {
                    superscript(&result, locale: locale)
                }
                result.redact(
                    for: .init(duration: precision),
                    locale: locale
                )
                return result
            }
        }

        if let (timeStyle, _, showsSubseconds) = timeStyle(
            for: input,
            originalPrecision: originalPrecision
        ) {
            var result = timeStyle.format(input)
            monospacedDigits(&result, locale: locale)
            if showsSubseconds,
               case .stopwatch = countingMode,
               maxFieldCount >= 1
            {
                superscript(&result, locale: locale)
            }
            return result
        } else if let (unitsStyle, _) = unitsStyle(for: input) {
            return unitsStyle.format(input)
        } else {
            return staticString
        }
    }

    public func format(_ input: Date) -> AttributedString {
        if Duration.seconds(1.0 / 30.0) < precision,
           maxPrecision < precision,
           !(input >= startDate && input < startDate + .init(interval))
        {
            var style = self
            style.precision = max(maxPrecision, Duration.seconds(1.0 / 30.0))
            return style.format(
                style.representedDuration(at: input),
                originalPrecision: precision
            )
        } else {
            return format(
                representedDuration(at: input),
                originalPrecision: nil
            )
        }
    }

    public func locale(_ locale: Locale) -> SystemFormatStyle.Timer {
        var style = self
        style.locale = locale
        return style
    }
}

// MARK: - SystemFormatStyle.Timer + DiscreteFormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.Timer: DiscreteFormatStyle {
    private func inputDate(for duration: Duration) -> Date {
        let offset = switch countingMode {
        case .timer(countsdown: true):
            interval - duration
        case .timer(countsdown: false), .stopwatch:
            duration
        }
        return startDate.addingTimeInterval(.init(offset))
    }

    private func discreteInput(after input: Duration) -> Duration? {
        if let (style, applicableRange, _) = timeStyle(
            for: input,
            originalPrecision: nil
        ) {
            guard let result = style.discreteInput(after: input) else {
                return applicableRange?.upperBound
            }
            guard let applicableRange else {
                return result
            }
            return min(result, applicableRange.upperBound)
        }
        if let (style, applicableRange) = unitsStyle(for: input) {
            guard let result = style.discreteInput(after: input) else {
                return applicableRange?.upperBound
            }
            guard let applicableRange else {
                return result
            }
            return min(result, applicableRange.upperBound)
        }
        return max(.seconds(1), precision)
    }

    private func discreteInput(before input: Duration) -> Duration? {
        if let (style, applicableRange, _) = timeStyle(
            for: input,
            originalPrecision: nil
        ) {
            guard let result = style.discreteInput(before: input) else {
                return applicableRange?.lowerBound
            }
            guard let applicableRange else {
                return result
            }
            return max(result, applicableRange.lowerBound)
        }
        if let (style, applicableRange) = unitsStyle(for: input) {
            guard let result = style.discreteInput(before: input) else {
                return applicableRange?.lowerBound
            }
            guard let applicableRange else {
                return result
            }
            return max(result, applicableRange.lowerBound)
        }
        return nil
    }

    private func nextInputRoundingLower(for duration: Duration) -> Date {
        let date = inputDate(for: duration)
        let representedDuration = representedDuration(at: date)
        let requiresAdjustment = switch countingMode {
        case .timer(countsdown: true):
            representedDuration < duration
        case .timer(countsdown: false), .stopwatch:
            duration < representedDuration
        }
        guard requiresAdjustment else {
            return date
        }
        return Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate.nextDown)
    }

    private func nextInputRoundingHigher(for duration: Duration) -> Date {
        let date = inputDate(for: duration)
        let representedDuration = representedDuration(at: date)
        let requiresAdjustment = switch countingMode {
        case .timer(countsdown: true):
            representedDuration < duration
        case .timer(countsdown: false), .stopwatch:
            duration < representedDuration
        }
        guard requiresAdjustment else {
            return date
        }
        return Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate.nextUp)
    }

    public func discreteInput(before input: Date) -> Date? {
        guard input > startDate else {
            return nil
        }
        let endDate = startDate + .init(interval)
        if !(input < endDate),
           Duration.seconds(1.0 / 30.0) < precision,
           maxPrecision < precision {
            return Date(timeIntervalSinceReferenceDate: endDate.timeIntervalSinceReferenceDate.nextDown)
        }

        let duration = representedDuration(at: input)
        let result = switch countingMode {
        case .timer(countsdown: true):
            discreteInput(after: duration)
        case .timer(countsdown: false), .stopwatch:
            discreteInput(before: duration)
        }
        guard let result else {
            guard Duration.seconds(1.0 / 30.0) < precision,
               maxPrecision < precision else {
                return nil
            }
            return Date(timeIntervalSinceReferenceDate: startDate.timeIntervalSinceReferenceDate.nextDown)
        }
        if !(Duration.seconds(1.0 / 30.0) < precision && maxPrecision < precision) {
            switch countingMode {
            case .timer(countsdown: true):
                guard !(interval < result) else {
                    return nil
                }
            case .timer(countsdown: false), .stopwatch:
                guard !(result < .zero) else {
                    return nil
                }
            }
        }
        return nextInputRoundingLower(
            for: max(min(result, interval), .zero)
        )
    }

    public func discreteInput(after input: Date) -> Date? {
        let endDate = startDate + .init(interval)
        guard input < endDate else {
            return nil
        }
        if !(input >= startDate),
           Duration.seconds(1.0 / 30.0) < precision,
           maxPrecision < precision {
            return startDate
        }

        let duration = representedDuration(at: input)
        let result = switch countingMode {
        case .timer(countsdown: true):
            discreteInput(before: duration)
        case .timer(countsdown: false), .stopwatch:
            discreteInput(after: duration)
        }
        guard let result else {
            guard Duration.seconds(1.0 / 30.0) < precision,
               maxPrecision < precision else {
                return nil
            }
            return Date(timeIntervalSinceReferenceDate: endDate.timeIntervalSinceReferenceDate.nextUp)
        }
        if !(Duration.seconds(1.0 / 30.0) < precision && maxPrecision < precision) {
            switch countingMode {
            case .timer(countsdown: true):
                guard !(result < .zero) else {
                    return nil
                }
            case .timer(countsdown: false), .stopwatch:
                guard !(interval < result) else {
                    return nil
                }
            }
        }
        return nextInputRoundingHigher(
            for: max(min(result, interval), .zero)
        )
    }
}

// MARK: - SystemFormatStyle.Timer + UpdateFrequencyDependentFormatStyle

extension SystemFormatStyle.Timer: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(
        _ frequency: TimeDataFormatting.UpdateFrequency
    ) -> SystemFormatStyle.Timer {
        var style = self
        style.precision = min(maxPrecision, frequency.duration)
        return style
    }
}

// MARK: - SystemFormatStyle.Timer + ContentTransitionProvidingFormatStyle

extension SystemFormatStyle.Timer: ContentTransitionProvidingFormatStyle {
    package func contentTransition<Source>(
        for source: Source
    ) -> ContentTransition where Source: TimeDataSourceStorage, Source.Value == Date {
        switch countingMode {
        case let .timer(countsdown):
            .numericText(countsDown: !countsdown)
        case .stopwatch:
            .identity
        }
    }
}

// MARK: - SystemFormatStyle.Timer + SafelySerializableDiscreteFormatStyle

extension SystemFormatStyle.Timer: SafelySerializableDiscreteFormatStyle {
    package static func representation<Source>(
        of resolvable: TimeDataFormatting.Resolvable<Source, SystemFormatStyle.Timer>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where Source: TimeDataSourceStorage, Source.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format.locale

        var units: NSCalendar.Unit = format.showsHours ? .hour : []
        if Duration.seconds(60) < format.maxPrecision {
            units.insert(.minute)
        }
        if Duration.seconds(1) < format.maxPrecision {
            units.insert(.second)
        }
        if Duration.seconds(0.01) < format.maxPrecision {
            units.insert(.nanosecond)
        }

        let pause: TimeInterval?
        if case let .identityWithPause(pauseDate) =
            resolvable.source as? TimeDataSource<Date>.DateStorage
        {
            switch format.countingMode {
            case .timer(countsdown: true):
                let endDate = format.startDate + .init(format.interval)
                pause = endDate.timeIntervalSince(pauseDate)
            case .timer(countsdown: false), .stopwatch:
                pause = pauseDate.timeIntervalSince(format.startDate)
            }
        } else {
            pause = nil
        }

        let interval = DateInterval(
            start: resolvable.source.date(for: format.startDate),
            duration: .init(format.interval)
        )
        let countdown = switch format.countingMode {
        case let .timer(countsdown):
            countsdown
        case .stopwatch:
            false
        }
        return ResolvableTimer(
            interval: interval,
            pause: pause,
            countdown: countdown,
            units: units == ResolvableTimer.defaultUnits ? nil : units,
            in: environment
        )
    }
}

// MARK: - SystemFormatStyle.Timer + InterfaceIdiomDependentFormatStyle

extension SystemFormatStyle.Timer: InterfaceIdiomDependentFormatStyle {
    package func interfaceIdiom(
        _ idiom: AnyInterfaceIdiom
    ) -> SystemFormatStyle.Timer {
        var style = self
        style.redactUsingDashes = !idiom.accepts(ComplicationInterfaceIdiom.self)
        return style
    }
}

// MARK: - SystemFormatStyle.Timer + VariablePrecisionDiscreteFormatStyle

extension SystemFormatStyle.Timer: VariablePrecisionDiscreteFormatStyle {
    package var precisionTransition: TimeDataFormatting.FormatTransition<Date> {
        let minute = Duration.seconds(60)
        switch countingMode {
        case .stopwatch:
            let oneAttosecond = Duration(
                secondsComponent: 0,
                attosecondsComponent: 1
            )
            return TimeDataFormatting.FormatTransition(
                range: startDate...nextInputRoundingLower(
                    for: minute - oneAttosecond
                ),
                handoff: nextInputRoundingHigher(for: minute)
            )
        case let .timer(countsdown):
            let handoffDuration = max(
                min(countsdown ? minute : interval - minute, interval),
                .zero
            )
            let transitionDuration = max(
                min(
                    countsdown
                        ? .seconds(59)
                        : interval - .seconds(59),
                    interval
                ),
                .zero
            )
            let endDate = startDate + .init(interval)
            return TimeDataFormatting.FormatTransition(
                range: nextInputRoundingHigher(for: transitionDuration)...endDate,
                handoff: nextInputRoundingHigher(for: handoffDuration)
            )
        }
    }
}

// MARK: - SystemFormatStyle.Timer + TextAlignmentDependentFormatStyle

extension SystemFormatStyle.Timer: TextAlignmentDependentFormatStyle {
    package func textAlignment(
        _ alignment: TextAlignment
    ) -> SystemFormatStyle.Timer {
        var style = self
        style.textAlignment = alignment
        return style
    }
}

// MARK: - SystemFormatStyle.Timer + CapitalizationContextDependentFormatStyle

extension SystemFormatStyle.Timer: CapitalizationContextDependentFormatStyle {
    package func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> SystemFormatStyle.Timer {
        var style = self
        if capitalizationContext == .unknown {
            style.capitalizationContext = context
        }
        return style
    }
}

// MARK: - SystemFormatStyle.Timer + StyledFormatStyle

extension SystemFormatStyle.Timer: StyledFormatStyle {
    package mutating func makePlatformAttributes(
        resolver: inout PlatformAttributeResolver
    ) {
        adjustedColon.makePlatformAttributes(resolver: &resolver)
        monospacedDigits.makePlatformAttributes(resolver: &resolver)
        superscript.makePlatformAttributes(resolver: &resolver)
    }
}

// MARK: - FormatStyle + Stopwatch

@available(OpenSwiftUI_v6_0, *)
extension FormatStyle where Self == SystemFormatStyle.Stopwatch {
    /// Create a stopwatch format style.
    ///
    /// A stopwatch styled display that starts counting up from zero at the given
    /// `startDate`.
    ///
    /// - Parameters:
    ///   - startDate: The date at which the stopwatch starts counting.
    ///   - showsHours: If true, the stopwatch shows the hours as a separate element on
    ///     the formatted string, once the duration is at least one hour. If false, the
    ///     stopwatch displays minute values greather than sixty.
    ///   - maxFieldCount: The number of fields that can be shown at once. For example,
    ///     1 hour, 34 minutes is shown as `1:34:00` by default, but as `1:34` if the
    ///     `maxFieldCount` is set to two. The style automatically excludes more significant
    ///     fields if their value is zero and they are not necessary for the format pattern,
    ///     making room for less significant fields.
    ///   - maxPrecision: The precision at which the input is formatted. E.g. by
    ///     default, two fractional digits are shown, making the maximum precision ten
    ///     milliseconds. Setting the maximum precision to `.seconds(60)` would only allow
    ///     hours and minutes to be shown.
    public static func stopwatch(
        startingAt startDate: Date,
        showsHours: Bool = true,
        maxFieldCount: Int = 4,
        maxPrecision: Duration = .milliseconds(10)
    ) -> SystemFormatStyle.Stopwatch {
        SystemFormatStyle.Stopwatch(
            startingAt: startDate,
            showsHours: showsHours,
            maxFieldCount: maxFieldCount,
            maxPrecision: maxPrecision
        )
    }
}

// MARK: - SystemFormatStyle.Stopwatch

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle {
    /// The system stopwatch format style.
    public struct Stopwatch: Sendable {
        public typealias FormatInput = Date

        var base: SystemFormatStyle.Timer

        init(base: SystemFormatStyle.Timer) {
            self.base = base
        }

        /// Create a stopwatch format style.
        ///
        /// A stopwatch styled display that starts counting up from zero at the given
        /// `startDate`.
        ///
        /// - Parameters:
        ///   - startDate: The date at which the stopwatch starts counting.
        ///   - showsHours: If true, the stopwatch shows the hours as a separate element on
        ///     the formatted string, once the duration is at least one hour. If false, the
        ///     stopwatch displays minute values greather than sixty.
        ///   - maxFieldCount: The number of fields that can be shown at once. For example,
        ///     1 hour, 34 minutes is shown as `1:34:00` by default, but as `1:34` if the
        ///     `maxFieldCount` is set to two. The style automatically excludes more significant
        ///     fields if their value is zero and they are not necessary for the format pattern,
        ///     making room for less significant fields.
        ///   - maxPrecision: The precision at which the input is formatted. E.g. by
        ///     default, two fractional digits are shown, making the maximum precision ten
        ///     milliseconds. Setting the maximum precision to `.seconds(60)` would only allow
        ///     hours and minutes to be shown.
        public init(
            startingAt startDate: Date,
            showsHours: Bool = true,
            maxFieldCount: Int = 4,
            maxPrecision: Duration = .milliseconds(10)
        ) {
            base = Timer(
                countingMode: .stopwatch,
                interval: startDate..<Date.distantFuture,
                showsHours: showsHours,
                maxFieldCount: maxFieldCount,
                maxPrecision: maxPrecision
            )
        }
    }
}

// MARK: - SystemFormatStyle.Stopwatch + FormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.Stopwatch: FormatStyle {
    public func format(_ input: Date) -> AttributedString {
        base.format(input)
    }

    public func locale(_ locale: Locale) -> SystemFormatStyle.Stopwatch {
        var style = self
        style.base = base.locale(locale)
        return style
    }

    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }

    public static func == (
        a: SystemFormatStyle.Stopwatch,
        b: SystemFormatStyle.Stopwatch
    ) -> Bool {
        a.base == b.base
    }

    public func encode(to encoder: any Encoder) throws {
        try base.encode(to: encoder)
    }

    public init(from decoder: any Decoder) throws {
        base = try SystemFormatStyle.Timer(from: decoder)
    }
}

// MARK: - SystemFormatStyle.Stopwatch + DiscreteFormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.Stopwatch: DiscreteFormatStyle {
    public func discreteInput(before input: Date) -> Date? {
        base.discreteInput(before: input)
    }

    public func discreteInput(after input: Date) -> Date? {
        base.discreteInput(after: input)
    }
}

// MARK: - SystemFormatStyle.Stopwatch + UpdateFrequencyDependentFormatStyle

extension SystemFormatStyle.Stopwatch: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(
        _ frequency: TimeDataFormatting.UpdateFrequency
    ) -> SystemFormatStyle.Stopwatch {
        var style = self
        style.base = base.updateFrequency(frequency)
        return style
    }
}

// MARK: - SystemFormatStyle.Stopwatch + ContentTransitionProvidingFormatStyle

extension SystemFormatStyle.Stopwatch: ContentTransitionProvidingFormatStyle {
    package func contentTransition<Source>(
        for source: Source
    ) -> ContentTransition where Source: TimeDataSourceStorage, Source.Value == Date {
        base.contentTransition(for: source)
    }
}

// MARK: - SystemFormatStyle.Stopwatch + SafelySerializableDiscreteFormatStyle

extension SystemFormatStyle.Stopwatch: SafelySerializableDiscreteFormatStyle {
    package static func representation<Source>(
        of resolvable: TimeDataFormatting.Resolvable<Source, SystemFormatStyle.Stopwatch>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where Source: TimeDataSourceStorage, Source.Value == Date
    {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - SystemFormatStyle.Stopwatch + InterfaceIdiomDependentFormatStyle

extension SystemFormatStyle.Stopwatch: InterfaceIdiomDependentFormatStyle {
    package func interfaceIdiom(
        _ idiom: AnyInterfaceIdiom
    ) -> SystemFormatStyle.Stopwatch {
        var style = self
        style.base = base.interfaceIdiom(idiom)
        return style
    }
}

// MARK: - SystemFormatStyle.Stopwatch + VariablePrecisionDiscreteFormatStyle

extension SystemFormatStyle.Stopwatch: VariablePrecisionDiscreteFormatStyle {
    package var precisionTransition: TimeDataFormatting.FormatTransition<Date> {
        base.precisionTransition
    }
}

// MARK: - SystemFormatStyle.Stopwatch + TextAlignmentDependentFormatStyle

extension SystemFormatStyle.Stopwatch: TextAlignmentDependentFormatStyle {
    package func textAlignment(
        _ alignment: TextAlignment
    ) -> SystemFormatStyle.Stopwatch {
        var style = self
        style.base = base.textAlignment(alignment)
        return style
    }
}

// MARK: - SystemFormatStyle.Stopwatch + CapitalizationContextDependentFormatStyle

extension SystemFormatStyle.Stopwatch: CapitalizationContextDependentFormatStyle {
    package func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> SystemFormatStyle.Stopwatch {
        var style = self
        style.base = base.capitalizationContext(context)
        return style
    }
}

// MARK: - SystemFormatStyle.Stopwatch + StyledFormatStyle

extension SystemFormatStyle.Stopwatch: StyledFormatStyle {
    package mutating func makePlatformAttributes(
        resolver: inout PlatformAttributeResolver
    ) {
        base.makePlatformAttributes(resolver: &resolver)
    }
}
