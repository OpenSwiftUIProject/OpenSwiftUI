//
//  Text+Date.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: AEE0E21EC7C6B2D1204F94F94CBF7389 (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - Text + DateStyle [WIP]

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

        enum Storage {
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
    }

    public init(_ date: Date, style: Text.DateStyle) {
        _openSwiftUIUnimplementedFailure()
    }

    public init(_ dates: ClosedRange<Date>) {
        _openSwiftUIUnimplementedFailure()
    }

    public init(_ interval: DateInterval) {
        _openSwiftUIUnimplementedFailure()
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

// TDOO

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
        _openSwiftUIUnimplementedFailure()
    }

    public init(from decoder: any Decoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}
