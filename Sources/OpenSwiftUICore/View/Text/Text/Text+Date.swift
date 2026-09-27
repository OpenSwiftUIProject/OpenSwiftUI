//
//  Text+Date.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: AEE0E21EC7C6B2D1204F94F94CBF7389 (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - Text + DateStyle

@available(OpenSwiftUI_v2_0, *)
extension Text {

    /// A predefined style used to display a `Date`.
    public struct DateStyle: Sendable {

        /// A style displaying only the time component for a date.
        ///
        ///     Text(event.startDate, style: .time)
        ///
        /// Example output:
        ///     11:23PM
        public static let time: Text.DateStyle = .init(storage: .time)

        /// A style displaying a date.
        ///
        ///     Text(event.startDate, style: .date)
        ///
        /// Example output:
        ///     June 3, 2019
        public static let date: Text.DateStyle = .init(storage: .date)

        /// A style displaying a date as relative to now.
        ///
        ///     Text(event.startDate, style: .relative)
        ///
        /// Example output:
        ///     2 hours, 23 minutes
        ///     1 year, 1 month
        public static let relative: Text.DateStyle = .init(storage: .relative)

        /// A style displaying a date as offset from now.
        ///
        ///     Text(event.startDate, style: .offset)
        ///
        /// Example output:
        ///     +2 hours
        ///     -3 months
        public static let offset: Text.DateStyle = .init(storage: .offset)

        /// A style displaying a date as timer counting from now.
        ///
        ///     Text(event.startDate, style: .timer)
        ///
        /// Example output:
        ///    2:32
        ///    36:59:01
        public static let timer: Text.DateStyle = .init(storage: .timer)

        @_spi(Private)
        public static func relative(
            unitConfiguration: Text.DateStyle.UnitsConfiguration
        ) -> Text.DateStyle {
            Text.DateStyle(
                storage: .relative,
                unitConfiguration: unitConfiguration
            )
        }

        @_spi(Private)
        public static func timer(
            units: NSCalendar.Unit
        ) -> Text.DateStyle {
            Text.DateStyle(
                storage: .timer,
                unitConfiguration: UnitsConfiguration(units: units, style: .full)
            )
        }

        enum Storage: Int {
            case time
            case date
            case relative
            case offset
            case timer
        }

        var storage: Storage

        @_spi(Private)
        public struct UnitsConfiguration: Equatable, Codable, Sendable {
            public enum Style: Int, Equatable, Codable, Sendable {
                case short
                case brief
                case full
            }

            @CodableRawRepresentable
            package var units: NSCalendar.Unit

            package var style: Text.DateStyle.UnitsConfiguration.Style

            public init(
                units: NSCalendar.Unit,
                style: Text.DateStyle.UnitsConfiguration.Style
            ) {
                self._units = .init(units)
                self.style = style
            }
        }

        package var unitConfiguration: UnitsConfiguration?

        @_spi(Private)
        public var units: NSCalendar.Unit {
            if let units = unitConfiguration?.units {
                units
            } else {
                switch storage {
                case .date: [.year, .month, .day]
                case .timer: [.hour, .minute, .second]
                default: [.year, .month, .day, .hour, .minute, .second]
                }
            }

        }

        func text(for date: Date) -> Text {
            switch storage {
            case .time:
                let format = Date.FormatStyle()
                    .hour(.defaultDigits(amPM: .abbreviated))
                    .minute(.defaultDigits)
                    .attributedStyle
                let trimmedFormat = WhitespaceRemovingFormatStyle<
                    Date.FormatStyle.Attributed,
                    AttributeScopes.FoundationAttributes.DateFieldAttribute
                >(
                    base: format,
                    prefixValue: .minute,
                    suffixValue: .amPM
                )
                return Text(date, format: trimmedFormat)
            case .date:
                let format = Date.FormatStyle()
                    .year(.defaultDigits)
                    .month(.wide)
                    .day(.defaultDigits)
                return Text(date, format: format)
            case .relative, .offset, .timer:
                #if canImport(Darwin)
                return Text(
                    source: TimeDataSource<Date>.DateStorage.identity,
                    format: format(for: date)!,
                    reducedLuminanceBudget: nil
                )
                #else
                _openSwiftUIPlatformUnimplementedFailure()
                #endif
            }
        }

        #if canImport(Darwin)
        func format(for date: Date) -> SystemFormatStyle.DateOffset? {
            switch storage {
            case .time, .date:
                return nil
            case .relative, .offset:
                let allowedFields: Set<Date.ComponentsFormatStyle.Field>
                if let units = unitConfiguration?.units {
                    allowedFields = Set(units)
                } else {
                    allowedFields = [.year, .month, .day, .hour, .minute, .second]
                }
                let format = SystemFormatStyle.DateOffset(
                    to: date,
                    allowedFields: allowedFields,
                    maxFieldCount: storage == .relative ? 2 : 1,
                    sign: storage == .relative ? .never : .always(includingZero: true)
                )
                let sizeVariant: TextSizeVariant
                if let style = unitConfiguration?.style {
                    sizeVariant = TextSizeVariant(rawValue: 2 - style.rawValue)
                } else {
                    sizeVariant = storage == .relative ? .compact : .regular
                }
                return format.sizeVariant(sizeVariant)
            case .timer:
                let timerFields: Set<Date.ComponentsFormatStyle.Field> = [
                    .hour,
                    .minute,
                    .second,
                ]
                let allowedFields: Set<Date.ComponentsFormatStyle.Field>
                if let units = unitConfiguration?.units {
                    allowedFields = Set(units).intersection(timerFields)
                } else {
                    allowedFields = timerFields
                }
                return SystemFormatStyle.DateOffset(
                    to: date,
                    allowedFields: allowedFields,
                    maxFieldCount: allowedFields.count,
                    sign: .never,
                    forceUnitsAoDStyle: true
                )
            }
        }
        #endif
    }

    /// Creates an instance that displays localized dates and times using a
    /// specific style.
    ///
    /// - Parameters:
    ///     - date: The target date to display.
    ///     - style: The style used when displaying a date.
    public init(_ date: Date, style: Text.DateStyle) {
        self = style.text(for: date)
    }

    /// Creates an instance that displays a localized range between two dates.
    ///
    /// - Parameters:
    ///     - dates: The range of dates to display
    public init(_ dates: ClosedRange<Date>) {
        self.init(DateInterval(start: dates.lowerBound, end: dates.upperBound))
    }

    /// Creates an instance that displays a localized time interval.
    ///
    ///     Text(DateInterval(start: event.startDate, duration: event.duration))
    ///
    /// Example output:
    ///
    ///     9:30AM - 3:30PM
    ///
    /// - Parameters:
    ///     - interval: The date interval to display
    public init(_ interval: DateInterval) {
        self.init(anyTextStorage: DateTextStorage(storage: .interval(interval: interval)))
    }

    @_spi(Private)
    public init(
        dateFormat: String,
        timeZone: TimeZone? = nil
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    public init(
        dateFormatTemplate: String,
        timeZone: TimeZone? = nil
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

private final class DateTextStorage: AnyTextStorage, @unchecked Sendable {
    enum Storage: Equatable {
        case interval(interval: DateInterval)
        case progress(interval: ClosedRange<Date>, countdown: Bool)
    }

    var storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        func defaultContentTransition(_ countdown: Bool) -> ContentTransition? {
            if environment.contentTransitionStyle == .sessionWidget ||
                !Semantics.TextContentTransitionDisabled.isEnabled {
                .numericText(countsDown: countdown)
            } else {
                .identity
            }
        }

        switch storage {
        case let .interval(interval):
            result.append(
                resolvable: ResolvableDateInterval(interval, in: environment),
                in: environment,
                with: options,
                transition: nil
            )
        case let .progress(interval, countdown):
            result.append(
                resolvable: ResolvableProgress(interval: interval, countdown: countdown),
                in: environment,
                with: options,
                transition: defaultContentTransition(countdown)
            )
        }
    }

    override func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        false
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? DateTextStorage else {
            return false
        }
        return storage == other.storage
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        false
    }
}

// MARK: - Text + Timer Interval

@available(OpenSwiftUI_v4_0, *)
extension Text {
    /// Creates an instance that displays a timer counting within the provided
    /// interval.
    ///
    ///     Text(
    ///         timerInterval: Date.now...Date(timeInterval: 12 * 60, since: .now),
    ///         pauseTime: Date.now + (10 * 60))
    ///
    /// The example above shows a text that displays a timer counting down
    /// from "12:00" and will pause when reaching "10:00".
    ///
    /// - Parameters:
    ///     - timerInterval: The interval between where to run the timer.
    ///     - pauseTime: If present, the date at which to pause the timer.
    ///         The default is `nil` which indicates to never pause.
    ///     - countsDown: Whether to count up or down. The default is `true`.
    ///     - showsHours: Whether to include an hours component if there are
    ///         more than 60 minutes left on the timer. The default is `true`.
    public init(
        timerInterval: ClosedRange<Date>,
        pauseTime: Date? = nil,
        countsDown: Bool = true,
        showsHours: Bool = true
    ) {
        let pause = pauseTime.map {
            $0.timeIntervalSince(timerInterval.lowerBound)
        }
        let interval = DateInterval(
            start: timerInterval.lowerBound,
            end: timerInterval.upperBound
        )
        let units: NSCalendar.Unit = if showsHours {
            ResolvableTimer.defaultUnits
        } else {
            [.minute, .second]
        }
        let timer = ResolvableTimer(
            interval: interval,
            pause: pause,
            countdown: countsDown,
            units: units,
            in: EnvironmentValues()
        )
        self.init(
            source: timer.source,
            format: timer.format,
            reducedLuminanceBudget: 60.0
        )
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Text {
    @available(*, deprecated, renamed: "init(timerInterval:pauseTime:countsDown:showsHours:)")
    public init(
        interval: ClosedRange<Date>,
        pauseAt: TimeInterval? = nil,
        countdown: Bool = true,
        units: NSCalendar.Unit? = nil
    ) {
        self.init(
            interval: DateInterval(start: interval.lowerBound, end: interval.upperBound),
            pauseAt: pauseAt,
            countdown: countdown,
            units: units
        )
    }

    @available(*, deprecated, renamed: "init(timerInterval:pauseTime:countsDown:showsHours:)")
    public init(
        interval: DateInterval,
        pauseAt: TimeInterval? = nil,
        countdown: Bool = true,
        units: NSCalendar.Unit? = nil
    ) {
        let timer = ResolvableTimer(
            interval: interval,
            pause: pauseAt,
            countdown: countdown,
            units: units,
            in: EnvironmentValues()
        )
        self.init(
            source: timer.source,
            format: timer.format,
            reducedLuminanceBudget: 60.0
        )
    }
}

// MARK: - LocalizedStringKey.StringInterpolation + Date

@available(OpenSwiftUI_v2_0, *)
extension LocalizedStringKey.StringInterpolation {
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(_ date: Date, style: Text.DateStyle) {
        appendInterpolation(Text(date, style: style))
    }

    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(_ dates: ClosedRange<Date>) {
        appendInterpolation(Text(dates))
    }

    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(_ interval: DateInterval) {
        appendInterpolation(Text(interval))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension LocalizedStringKey.StringInterpolation {
    @available(*, deprecated, renamed: "appendInterpolation(timerInterval:pauseTime:countsDown:showsHours:)")
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(
        interval: ClosedRange<Date>,
        pauseAt: TimeInterval?,
        countdown: Bool = false,
        units: NSCalendar.Unit? = nil
    ) {
        appendInterpolation(Text(
            interval: interval,
            pauseAt: pauseAt,
            countdown: countdown,
            units: units
        ))
    }

    @available(*, deprecated, renamed: "appendInterpolation(timerInterval:pauseTime:countsDown:showsHours:)")
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(
        interval: DateInterval,
        pauseAt: TimeInterval?,
        countdown: Bool = false,
        units: NSCalendar.Unit? = nil
    ) {
        appendInterpolation(Text(
            interval: interval,
            pauseAt: pauseAt,
            countdown: countdown,
            units: units
        ))
    }
}

@available(OpenSwiftUI_v4_0, *)
extension LocalizedStringKey.StringInterpolation {
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(
        timerInterval: ClosedRange<Date>,
        pauseTime: Date? = nil,
        countsDown: Bool = true,
        showsHours: Bool = true
    ) {
        appendInterpolation(Text(
            timerInterval: timerInterval,
            pauseTime: pauseTime,
            countsDown: countsDown,
            showsHours: showsHours
        ))
    }
}

// MARK: - Text + Progress Interval

extension Text {
    package init(progressInterval: ClosedRange<Date>, countsDown: Bool = false) {
        self.init(anyTextStorage: DateTextStorage(storage: .progress(
            interval: progressInterval,
            countdown: countsDown
        )))
    }
}

// MARK: - Text + ReferenceDate

@available(OpenSwiftUI_v1_0, *)
extension View {
    @_spi(OpenSwiftUIPrivate)
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func referenceDate(_ date: Date?) -> some View {
        modifier(ReferenceDateModifier(date: date))
    }
}

package struct ReferenceDateInput: ViewInput {
    package static var defaultValue: WeakAttribute<Date?> {
        .init()
    }
}

extension _ViewInputs {
    @inline(__always)
    package var referenceDate: WeakAttribute<Date?> {
        get { self[ReferenceDateInput.self] }
        set { self[ReferenceDateInput.self] = newValue }
    }
}

extension _GraphInputs {
    @inline(__always)
    package var referenceDate: WeakAttribute<Date?> {
        get { self[ReferenceDateInput.self] }
        set { self[ReferenceDateInput.self] = newValue }
    }
}

package struct ReferenceDateModifier: PrimitiveViewModifier, ViewInputsModifier {
    package var date: Date?

    nonisolated package static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.base.referenceDate = WeakAttribute(
            modifier.value.unsafeBitCast(to: Date?.self)
        )
    }
}

// MARK: - Text.DateStyle + Extension

@available(OpenSwiftUI_v2_0, *)
extension Text.DateStyle: Equatable {
    public static func == (a: Text.DateStyle, b: Text.DateStyle) -> Bool {
        a.storage == b.storage && a.unitConfiguration == b.unitConfiguration
    }
}

@available(OpenSwiftUI_v2_0, *)
extension Text.DateStyle: Codable {
    enum Errors: Error {
        case unknownStorage
    }

    enum CodingKeys: CodingKey {
        case storage
        case unitConfiguration
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storage.rawValue, forKey: .storage)
        try container.encodeIfPresent(
            unitConfiguration,
            forKey: .unitConfiguration
        )
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawStorage = try container.decode(Int.self, forKey: .storage)
        guard let storage = Storage(rawValue: rawStorage) else {
            throw Errors.unknownStorage
        }
        self.storage = storage
        self.unitConfiguration = try? container.decodeIfPresent(
            UnitsConfiguration.self,
            forKey: .unitConfiguration
        )
    }
}
