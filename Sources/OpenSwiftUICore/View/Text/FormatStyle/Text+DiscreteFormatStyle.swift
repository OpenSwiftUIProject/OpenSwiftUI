//
//  Text+DiscreteFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C8A98712CE9284278805F6E671356D1B (SwiftUICore)

public import Foundation

// MARK: - TimeDataSource

/// A source of time related data.
///
/// Instances of this type provide ``Text`` with live and automatically updating
/// values in Widgets, Live Activities, watchOS Complications, and of course
/// regular apps.
@available(OpenSwiftUI_v6_0, *)
public struct TimeDataSource<Value> {
    fileprivate let box: BoxBase

    fileprivate init(box: BoxBase) {
        self.box = box
    }

    fileprivate class BoxBase: @unchecked Sendable {
        fileprivate func textStorage<F>(
            for format: F
        ) -> AnyTextStorage where F: DiscreteFormatStyle, F.FormatInput == Value, F.FormatOutput: AttributedStringConvertible {
            _openSwiftUIBaseClassAbstractMethod()
        }
    }
}

// MARK: - TimeDataSourceStorage

package protocol TimeDataSourceStorage<Value>: Decodable, Encodable, Hashable, Sendable {
    associatedtype Value

    func value(for date: Date) -> Value
    func date(for value: Value) -> Date
    func round(_ value: Value, _ rule: FloatingPointRoundingRule, toMultipleOf multiple: Double) -> Value
    func convergesToZero(_ value: Value) -> Bool
    var end: Value? { get }
}

extension TimeDataSourceStorage {
    package func withValue(for date: Date, call closure: (Value) -> Value?) -> Date? {
        let value = value(for: date)
        guard let nextValue = closure(value) else {
            return nil
        }
        return self.date(for: nextValue)
    }

    package var end: Value? {
        nil
    }
}

// MARK: - TimeDataSource + Date

extension TimeDataSource where Value == Date {
    package enum DateStorage: TimeDataSourceStorage {
        package typealias Value = Date

        case identity
        case identityWithPause(pauseDate: Date)

        private enum CodingKeys: CodingKey {
            case identity
            case identityWithPause
        }

        private enum IdentityCodingKeys: CodingKey {
        }

        private enum IdentityWithPauseCodingKeys: CodingKey {
            case pauseDate
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard container.allKeys.count == 1 else {
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one."
                )
                throw DecodingError.typeMismatch(Self.self, context)
            }
            switch container.allKeys[0] {
            case .identity:
                _ = try container.nestedContainer(keyedBy: IdentityCodingKeys.self, forKey: .identity)
                self = .identity
            case .identityWithPause:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: IdentityWithPauseCodingKeys.self,
                    forKey: .identityWithPause
                )
                let pauseDate = try nestedContainer.decode(Date.self, forKey: .pauseDate)
                self = .identityWithPause(pauseDate: pauseDate)
            }
        }

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .identity:
                _ = container.nestedContainer(keyedBy: IdentityCodingKeys.self, forKey: .identity)
            case let .identityWithPause(pauseDate):
                var nestedContainer = container.nestedContainer(
                    keyedBy: IdentityWithPauseCodingKeys.self,
                    forKey: .identityWithPause
                )
                try nestedContainer.encode(pauseDate, forKey: .pauseDate)
            }
        }

        package func value(for date: Date) -> Date {
            self.date(for: date)
        }

        package func date(for value: Date) -> Date {
            switch self {
            case .identity:
                value
            case let .identityWithPause(pauseDate):
                min(value, pauseDate)
            }
        }

        package func round(_ value: Date, _ rule: FloatingPointRoundingRule, toMultipleOf multiple: Double) -> Date {
            Date(
                timeIntervalSinceReferenceDate: value.timeIntervalSinceReferenceDate.rounded(
                    rule,
                    toMultipleOf: multiple
                )
            )
        }

        package func convergesToZero(_ value: Date) -> Bool {
            false
        }

        package var end: Date? {
            guard case let .identityWithPause(pauseDate) = self else {
                return nil
            }
            return pauseDate
        }
    }

    private final class DateBox: BoxBase, @unchecked Sendable {
        private let storage: DateStorage

        init(storage: DateStorage) {
            self.storage = storage
        }

        override fileprivate func textStorage<F>(
            for format: F
        ) -> AnyTextStorage where F: DiscreteFormatStyle, F.FormatInput == Date, F.FormatOutput: AttributedStringConvertible {
            TimeDataFormattingStorage(source: storage, format: format, reducedLuminanceBudget: nil)
        }
    }
}

// MARK: - TimeDataSource + Duration

extension TimeDataSource where Value == Duration {
    package enum DurationStorage: TimeDataSourceStorage {
        package typealias Value = Duration

        case durationOffset(date: Date)

        private enum CodingKeys: CodingKey {
            case durationOffset
        }

        private enum DurationOffsetCodingKeys: CodingKey {
            case date
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard container.allKeys.count == 1 else {
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one."
                )
                throw DecodingError.typeMismatch(Self.self, context)
            }
            let nestedContainer = try container.nestedContainer(
                keyedBy: DurationOffsetCodingKeys.self,
                forKey: .durationOffset
            )
            let date = try nestedContainer.decode(Date.self, forKey: .date)
            self = .durationOffset(date: date)
        }

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var nestedContainer = container.nestedContainer(
                keyedBy: DurationOffsetCodingKeys.self,
                forKey: .durationOffset
            )
            switch self {
            case let .durationOffset(date):
                try nestedContainer.encode(date, forKey: .date)
            }
        }

        package func value(for date: Date) -> Duration {
            switch self {
            case let .durationOffset(referenceDate):
                Duration.seconds(date.timeIntervalSince(referenceDate))
            }
        }

        package func date(for value: Duration) -> Date {
            switch self {
            case let .durationOffset(referenceDate):
                referenceDate.addingTimeInterval(Double(value))
            }
        }

        package func round(_ value: Duration, _ rule: FloatingPointRoundingRule, toMultipleOf multiple: Double) -> Duration {
            Duration.seconds(Double(value).rounded(rule, toMultipleOf: multiple))
        }

        package func convergesToZero(_ value: Duration) -> Bool {
            value < .zero
        }
    }

    private final class DurationBox: BoxBase, @unchecked Sendable {
        private let storage: DurationStorage

        init(storage: DurationStorage) {
            self.storage = storage
        }

        override fileprivate func textStorage<F>(
            for format: F
        ) -> AnyTextStorage where F: DiscreteFormatStyle, F.FormatInput == Duration, F.FormatOutput: AttributedStringConvertible {
            TimeDataFormattingStorage(source: storage, format: format, reducedLuminanceBudget: nil)
        }
    }
}

// MARK: - TimeDataSource + Range<Date>

extension TimeDataSource where Value == Range<Date> {
    package enum DateRangeStorage: TimeDataSourceStorage {
        package typealias Value = Range<Date>

        case dateRangeStartingAt(date: Date)
        case dateRangeEndingAt(date: Date)

        private enum CodingKeys: CodingKey {
            case dateRangeStartingAt
            case dateRangeEndingAt
        }

        private enum DateRangeStartingAtCodingKeys: CodingKey {
            case date
        }

        private enum DateRangeEndingAtCodingKeys: CodingKey {
            case date
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard container.allKeys.count == 1 else {
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one."
                )
                throw DecodingError.typeMismatch(Self.self, context)
            }
            switch container.allKeys[0] {
            case .dateRangeStartingAt:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: DateRangeStartingAtCodingKeys.self,
                    forKey: .dateRangeStartingAt
                )
                let date = try nestedContainer.decode(Date.self, forKey: .date)
                self = .dateRangeStartingAt(date: date)
            case .dateRangeEndingAt:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: DateRangeEndingAtCodingKeys.self,
                    forKey: .dateRangeEndingAt
                )
                let date = try nestedContainer.decode(Date.self, forKey: .date)
                self = .dateRangeEndingAt(date: date)
            }
        }

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .dateRangeStartingAt(date):
                var nestedContainer = container.nestedContainer(
                    keyedBy: DateRangeStartingAtCodingKeys.self,
                    forKey: .dateRangeStartingAt
                )
                try nestedContainer.encode(date, forKey: .date)
            case let .dateRangeEndingAt(date):
                var nestedContainer = container.nestedContainer(
                    keyedBy: DateRangeEndingAtCodingKeys.self,
                    forKey: .dateRangeEndingAt
                )
                try nestedContainer.encode(date, forKey: .date)
            }
        }

        package func value(for date: Date) -> Range<Date> {
            switch self {
            case let .dateRangeStartingAt(startDate):
                startDate..<max(date, startDate)
            case let .dateRangeEndingAt(endDate):
                min(date, endDate)..<endDate
            }
        }

        package func date(for value: Range<Date>) -> Date {
            switch self {
            case let .dateRangeStartingAt(startDate):
                guard value.lowerBound == startDate else {
                    logFault()
                    return .distantFuture
                }
                return value.upperBound
            case let .dateRangeEndingAt(endDate):
                guard value.upperBound == endDate else {
                    logFault()
                    return .distantFuture
                }
                return value.lowerBound
            }
        }

        private func logFault() {
            let bound: String
            switch self {
            case .dateRangeStartingAt:
                bound = "lowerBound"
            case .dateRangeEndingAt:
                bound = "upperBound"
            }
            Log.externalWarning("Misconfigured Text(_:format:). The TimeDataSource is expecting the \(bound) to remain fixed, but the DiscreteFormatStyle was trying to move it. The Text will not update.")
        }

        package func round(_ value: Range<Date>, _ rule: FloatingPointRoundingRule, toMultipleOf multiple: Double) -> Range<Date> {
            switch self {
            case let .dateRangeStartingAt(startDate):
                let delta = value.upperBound.timeIntervalSince(startDate).rounded(rule, toMultipleOf: multiple)
                let roundedDate = startDate.addingTimeInterval(delta)
                return startDate..<max(roundedDate, startDate)
            case let .dateRangeEndingAt(endDate):
                let delta = value.lowerBound.timeIntervalSince(endDate).rounded(rule, toMultipleOf: multiple)
                let roundedDate = endDate.addingTimeInterval(delta)
                return min(roundedDate, endDate)..<endDate
            }
        }

        package func convergesToZero(_ value: Range<Date>) -> Bool {
            switch self {
            case .dateRangeStartingAt:
                false
            case .dateRangeEndingAt:
                true
            }
        }
    }

    private final class DateRangeBox: BoxBase, @unchecked Sendable {
        private let storage: DateRangeStorage

        init(storage: DateRangeStorage) {
            self.storage = storage
        }

        override fileprivate func textStorage<F>(
            for format: F
        ) -> AnyTextStorage where F: DiscreteFormatStyle, F.FormatInput == Range<Date>, F.FormatOutput: AttributedStringConvertible {
            TimeDataFormattingStorage(source: storage, format: format, reducedLuminanceBudget: nil)
        }
    }
}

@available(OpenSwiftUI_v6_0, *)
extension TimeDataSource: Sendable where Value: Sendable {}

@available(OpenSwiftUI_v6_0, *)
extension TimeDataSource {

    /// A time data source that produces `Date.now`.
    public static var currentDate: TimeDataSource<Date> {
        TimeDataSource<Date>(box: TimeDataSource<Date>.DateBox(storage: .identity))
    }

    /// A time data source that produces the offset between `Date.now` and the given
    /// `date` as a `Duration`.
    public static func durationOffset(to date: Date) -> TimeDataSource<Duration> {
        TimeDataSource<Duration>(box: TimeDataSource<Duration>.DurationBox(storage: .durationOffset(date: date)))
    }

    /// A time data source that produces `date..<max(date, Date.now)`.
    public static func dateRange(startingAt date: Date) -> TimeDataSource<Range<Date>> {
        TimeDataSource<Range<Date>>(box: TimeDataSource<Range<Date>>.DateRangeBox(storage: .dateRangeStartingAt(date: date)))
    }

    /// A time data source that produces `min(date, Date.now)..<date`.
    public static func dateRange(endingAt date: Date) -> TimeDataSource<Range<Date>> {
        TimeDataSource<Range<Date>>(box: TimeDataSource<Range<Date>>.DateRangeBox(storage: .dateRangeEndingAt(date: date)))
    }
}

// MARK: - SystemFormatStyle

/// A namespace for format styles that implement designs used across Apple's
/// platformes.
@available(OpenSwiftUI_v6_0, *)
public enum SystemFormatStyle: Sendable {}

// MARK: - Text + DiscreteFormatStyle

extension Text {
    package init<Source, Format>(
        source: Source,
        format: Format,
        reducedLuminanceBudget: Double?
    ) where Source: TimeDataSourceStorage,
        Format: DiscreteFormatStyle,
        Source.Value == Format.FormatInput,
        Format.FormatOutput: AttributedStringConvertible {
        self.init(anyTextStorage: TimeDataFormattingStorage(
            source: source,
            format: format,
            reducedLuminanceBudget: reducedLuminanceBudget
        ))
    }

    /// Creates a text view that displays the current system time as defined by the
    /// given format style, keeping the text up to date as time progresses.
    ///
    /// Use this initializer to create a text view that updates as time progresses, just
    /// like ``init(_:style:)``, but with the flexibility of Foundation's `FormatStyle`
    /// protocol.
    ///
    /// In the following example, the first ``Text`` view presents the offset to
    /// `startDate`, whereas the second view displays a stopwatch counting from
    /// `startDate`. Both views are kept up to date as time progresses.
    ///
    ///     Text(.currentDate, format: .offset(to: startDate))
    ///     Text(.currentDate, format: .stopwatch(startingAt: startDate))
    ///
    /// ## Redaction for Reduced Luminance
    ///
    /// When the text is displayed with reduced luminance and frame rate, it
    /// automatically modifies the `format` or its output so it never shows outdated
    /// information.
    ///
    /// If the `format` is known to OpenSwiftUI and allows removing units or fields,
    /// OpenSwiftUI removes parts that change more frequently than the frame rate
    /// allows. E.g. a string like _13 minutes, 22 seconds_ would change to just
    /// `13 minutes`.
    ///
    /// Otherwise, OpenSwiftUI inspects the `durationField`, `dateField`, and `measurement`
    /// attributes on the formatted output to determine which ranges need to be
    /// redacted. If these attributes are not present, all digits are redacted using
    /// dashes.
    @available(OpenSwiftUI_v6_0, *)
    public init<V, F>(
        _ source: TimeDataSource<V>,
        format: F
    ) where V == F.FormatInput, F: DiscreteFormatStyle, F.FormatOutput == AttributedString {
        self.init(anyTextStorage: source.box.textStorage(for: format))
    }

    /// Creates a text view that displays the current system time as defined by the
    /// given format style, keeping the text up to date as time progresses.
    ///
    /// Use this initializer to create a text view that updates as time progresses, just
    /// like ``init(_:style:)``, but with the flexibility of Foundation's `FormatStyle`
    /// protocol.
    ///
    /// In the following example, the first ``Text`` view presents the current date and
    /// time, whereas the second view displays a soccer clock counting from `startDate`.
    /// Both views are kept up to date as time progresses.
    ///
    ///     Text(.currentDate, format: .dateTime)
    ///     Text(.durationOffset(to: startDate), format: .time(pattern: .minuteSecond))
    ///
    /// ## Redaction for Reduced Luminance
    ///
    /// When the text is displayed with reduced luminance and frame rate, it
    /// automatically modifies the `format` or its output so it never shows outdated
    /// information.
    ///
    /// If the `format` is known to OpenSwiftUI and allows removing units or fields,
    /// OpenSwiftUI removes parts that change more frequently than the frame rate
    /// allows. E.g. a string like _13 minutes, 22 seconds_ would change to just
    /// `13 minutes`.
    ///
    /// Otherwise, all digits in the formatted output are redacted using dashes.
    @_disfavoredOverload
    @available(OpenSwiftUI_v6_0, *)
    public init<V, F>(
        _ source: TimeDataSource<V>,
        format: F
    ) where V == F.FormatInput, F: DiscreteFormatStyle, F.FormatOutput == String {
        self.init(anyTextStorage: source.box.textStorage(for: format))
    }
}

extension LocalizedStringKey.StringInterpolation {
    /// Appends a text view that displays the current system time as defined by the
    /// given format style, keeping the text up to date as time progresses.
    ///
    /// Use this initializer to create a text view that updates as time progresses, just
    /// like ``init(_:style:)``, but with the flexibility of Foundation's `FormatStyle`
    /// protocol.
    ///
    /// In the following example, the first ``Text`` view presents the offset to
    /// `startDate`, whereas the second view displays a stopwatch counting from
    /// `startDate`. Both views are kept up to date as time progresses.
    ///
    ///     Text(.currentDate, format: .offset(to: startDate))
    ///     Text(.currentDate, format: .stopwatch(startingAt: startDate))
    ///
    /// - Note: Don't call this method directly; it's used by the compiler when
    /// interpreting string interpolations.
    ///
    /// ## Redaction for Reduced Luminance
    ///
    /// When the text is displayed with reduced luminance and frame rate, it
    /// automatically modifies the `format` or its output so it never shows outdated
    /// information.
    ///
    /// If the `format` is known to OpenSwiftUI and allows removing units or fields,
    /// OpenSwiftUI removes parts that change more frequently than the frame rate
    /// allows. E.g. a string like _13 minutes, 22 seconds_ would change to just
    /// `13 minutes`.
    ///
    /// Otherwise, OpenSwiftUI inspects the `durationField`, `dateField`, and `measurement`
    /// attributes on the formatted output to determine which ranges need to be
    /// redacted. If these attributes are not present, all digits are redacted using
    /// dashes.
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    @available(OpenSwiftUI_v6_0, *)
    public mutating func appendInterpolation<V, F>(
        _ source: TimeDataSource<V>,
        format: F
    ) where V == F.FormatInput, F: DiscreteFormatStyle, F.FormatOutput == AttributedString {
        appendInterpolation(Text(source, format: format))
    }

    /// Appends a text view that displays the current system time as defined by the
    /// given format style, keeping the text up to date as time progresses.
    ///
    /// Use this initializer to create a text view that updates as time progresses, just
    /// like ``init(_:style:)``, but with the flexibility of Foundation's `FormatStyle`
    /// protocol.
    ///
    /// In the following example, the first ``Text`` view presents the current date and
    /// time, whereas the second view displays a soccer clock counting from `startDate`.
    /// Both views are kept up to date as time progresses.
    ///
    ///     Text(.currentDate, format: .dateTime)
    ///     Text(.durationOffset(to: startDate), format: .time(pattern: .minuteSecond))
    ///
    /// - Note: Don't call this method directly; it's used by the compiler when
    /// interpreting string interpolations.
    ///
    /// ## Redaction for Reduced Luminance
    ///
    /// When the text is displayed with reduced luminance and frame rate, it
    /// automatically modifies the `format` or its output so it never shows outdated
    /// information.
    ///
    /// If the `format` is known to OpenSwiftUI and allows removing units or fields,
    /// OpenSwiftUI removes parts that change more frequently than the frame rate
    /// allows. E.g. a string like _13 minutes, 22 seconds_ would change to just
    /// `13 minutes`.
    ///
    /// Otherwise, all digits in the formatted output are redacted using dashes.
    @_disfavoredOverload
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    @available(OpenSwiftUI_v6_0, *)
    public mutating func appendInterpolation<V, F>(
        _ source: TimeDataSource<V>,
        format: F
    ) where V == F.FormatInput, F: DiscreteFormatStyle, F.FormatOutput == String {
        appendInterpolation(Text(source, format: format))
    }
}

// MARK: - TimeDataFormattingStorage

@available(OpenSwiftUI_v6_0, *)
private final class TimeDataFormattingStorage<Source, Format>: AnyTextStorage, @unchecked Sendable where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput, Format.FormatOutput: AttributedStringConvertible {
    var source: Source
    var format: Format
    var reducedLuminanceBudget: Double?

    init(source: Source, format: Format, reducedLuminanceBudget: Double?) {
        self.source = source
        self.format = format
        self.reducedLuminanceBudget = reducedLuminanceBudget
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        var resolvedFormat = format
            .locale(environment.locale)
            .calendar(environment.calendar)
            .timeZone(environment.timeZone)

        let idiom: AnyInterfaceIdiom
        if let resultIdiom = result.idiom {
            idiom = resultIdiom
        } else {
            Log.internalWarning("TimeDataFormattingStorage was resolved without idiom!")
            idiom = _GraphInputs.defaultInterfaceIdiom
        }
        if reducedLuminanceBudget == nil,
           let dependentFormat = resolvedFormat as? any InterfaceIdiomDependentFormatStyle {
            resolvedFormat = dependentFormat.interfaceIdiom(idiom) as! Format
        }
        if let dependentFormat = resolvedFormat as? any TextAlignmentDependentFormatStyle {
            resolvedFormat = dependentFormat.textAlignment(environment.multilineTextAlignment) as! Format
        }
        if let dependentFormat = resolvedFormat as? any CapitalizationContextDependentFormatStyle {
            resolvedFormat = dependentFormat.capitalizationContext(environment.capitalizationContext.resolved) as! Format
        }
        let contentTransition: ContentTransition
        if let style = resolvedFormat as? any ContentTransitionProvidingFormatStyle<Source.Value> {
            contentTransition = style.contentTransition(for: source)
        } else {
            contentTransition = .numericText(countsDown: isDeployedOnOrAfter(.v6))
        }
        let secondsUpdateFrequencyBudget: Double
        if let reducedLuminanceBudget {
            secondsUpdateFrequencyBudget = reducedLuminanceBudget
        } else {
            let frequency: TimeDataFormatting.UpdateFrequency
            switch idiom {
            case .complication: frequency = .high
            case .widget: frequency = .minute
            case .watch: frequency = .minute
            default: frequency = .minute
            }
            secondsUpdateFrequencyBudget = frequency.interval
        }
        let resolved = TimeDataFormatting.Resolvable(
            source: source,
            format: resolvedFormat,
            secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget
        )
        result.append(
            resolvable: resolved,
            in: environment,
            with: options,
            transition: contentTransition
        )
    }

    override func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        false
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? TimeDataFormattingStorage<Source, Format> else {
            return false
        }
        return source == other.source && format == other.format
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        Format.FormatOutput.self == AttributedString.self
    }
}

// MARK: - AttributedStringConvertible

package protocol AttributedStringConvertible {
    var attributedString: AttributedString { get }
}

extension AttributedString: AttributedStringConvertible {
    package var attributedString: AttributedString {
        self
    }
}

extension String: AttributedStringConvertible {
    package var attributedString: AttributedString {
        AttributedString(self, attributes: AttributeContainer())
    }
}

extension Bundle {
    package static let systemFormatStyle: Bundle = .openSwiftUICore
}
