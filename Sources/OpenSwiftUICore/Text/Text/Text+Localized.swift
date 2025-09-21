//
//  Text+Localized.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 8C53218A357EE528547B0855666BD2E5 (SwiftUICore)

public import Foundation

@available(OpenSwiftUI_v1_0, *)
extension Text {
    @_semantics("openswiftui.init_with_localization")
    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.init(
            anyTextStorage: LocalizedTextStorage(
                key: key,
                table: tableName,
                bundle: bundle
            )
        )
    }
}

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct LocalizedStringKey: Equatable, ExpressibleByStringInterpolation {
    internal var key: String
    internal var hasFormatting: Bool = false
    private var arguments: [LocalizedStringKey.FormatArgument]

    public init(_ value: String) {
        _openSwiftUIUnimplementedFailure()
    }

    @_semantics("openswiftui.localized_string_key.init_literal")
    public init(stringLiteral value: String) {
        _openSwiftUIUnimplementedFailure()
    }

    @_semantics("openswiftui.localized_string_key.init_interpolation")
    public init(stringInterpolation: LocalizedStringKey.StringInterpolation) {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolve(
        in environment: EnvironmentValues,
        table: String?,
        bundle: Bundle?
    ) -> String {
        _openSwiftUIUnimplementedFailure()
    }

    @usableFromInline
    internal struct FormatArgument: Equatable {
        @usableFromInline
        internal static func == (lhs: LocalizedStringKey.FormatArgument, rhs: LocalizedStringKey.FormatArgument) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        @_semantics("openswiftui.localized.interpolation_init")
        public init(literalCapacity: Int, interpolationCount: Int) {
            _openSwiftUIUnimplementedFailure()
        }

        @_semantics("openswiftui.localized.appendLiteral")
        public mutating func appendLiteral(_ literal: String) {
            _openSwiftUIUnimplementedFailure()
        }

        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ string: String) {
            _openSwiftUIUnimplementedFailure()
        }

        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: ReferenceConvertible {
            _openSwiftUIUnimplementedFailure()
        }

        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<Subject>(_ subject: Subject, formatter: Formatter? = nil) where Subject: NSObject {
            _openSwiftUIUnimplementedFailure()
        }

//        @available(OpenSwiftUI_v2_5, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
            _openSwiftUIUnimplementedFailure()
        }

        @available(OpenSwiftUI_v6_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation<F>(_ input: F.FormatInput, format: F) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == AttributedString {
            _openSwiftUIUnimplementedFailure()
        }

        @_transparent
        public mutating func appendInterpolation<T>(_ value: T) where T: _FormatSpecifiable {
            appendInterpolation(value, specifier: formatSpecifier(T.self))
        }

        @_semantics("openswiftui.localized.appendInterpolation_param_specifier")
        public mutating func appendInterpolation<T>(_ value: T, specifier: String) where T: _FormatSpecifiable {
            _openSwiftUIUnimplementedFailure()
        }

        @available(OpenSwiftUI_v2_0, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ text: Text) {
            _openSwiftUIUnimplementedFailure()
        }

//        @available(OpenSwiftUI_v2_5, *)
        @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
        public mutating func appendInterpolation(_ attributedString: AttributedString) {
            _openSwiftUIUnimplementedFailure()
        }

        @available(*, unavailable, message: "Unsupported type for interpolation, see LocalizedStringKey.StringInterpolation for supported types.")
        public mutating func appendInterpolation<T>(_ view: T) where T: View {
            _openSwiftUIUnimplementedFailure()
        }
    }

    public static func == (a: LocalizedStringKey, b: LocalizedStringKey) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

private final class LocalizedTextStorage: AnyTextStorage, @unchecked Sendable {
    let key: LocalizedStringKey
    let table: String?
    let bundle: Bundle?

    init(key: LocalizedStringKey, table: String?, bundle: Bundle?) {
        self.key = key
        self.table = table
        self.bundle = bundle
    }
}

@available(*, unavailable)
extension LocalizedStringKey.StringInterpolation: Sendable {}

@available(*, unavailable)
extension LocalizedStringKey: Sendable {}

@available(*, unavailable)
extension LocalizedStringKey.FormatArgument: Sendable {}

@_alwaysEmitIntoClient
internal var int64Specifier: String {
    get { "%lld" }
}

@_alwaysEmitIntoClient
internal var int32Specifier: String {
    get { "%d" }
}

@_alwaysEmitIntoClient
internal var uint64Specifier: String {
    get { "%llu" }
}

@_alwaysEmitIntoClient
internal var uint32Specifier: String {
    get { "%u" }
}

@_alwaysEmitIntoClient
internal var floatSpecifier: String {
    get { "%f" }
}

@_alwaysEmitIntoClient
internal var doubleSpecifier: String {
    get { "%lf" }
}

@_alwaysEmitIntoClient
@_semantics("constant_evaluable")
internal func formatSpecifier<T>(_ type: T.Type) -> String {
    switch type {
    case is Int.Type:
        fallthrough
    case is Int64.Type:
        return int64Specifier
    case is Int8.Type:
        fallthrough
    case is Int16.Type:
        fallthrough
    case is Int32.Type:
        return int32Specifier
    case is UInt.Type:
        fallthrough
    case is UInt64.Type:
        return uint64Specifier
    case is UInt8.Type:
        fallthrough
    case is UInt16.Type:
        fallthrough
    case is UInt32.Type:
        return uint32Specifier
    case is Float.Type:
        return floatSpecifier
    case is CGFloat.Type:
        fallthrough
    case is Double.Type:
        return doubleSpecifier
    default:
        return "%@"
    }
}

@available(OpenSwiftUI_v1_0, *)
public protocol _FormatSpecifiable: Equatable {
    associatedtype _Arg: CVarArg
    var _arg: Self._Arg { get }
    var _specifier: String { get }
}

@available(OpenSwiftUI_v1_0, *)
extension Int: _FormatSpecifiable {
    public var _arg: Int64 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int8: _FormatSpecifiable {
    public var _arg: Int32 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int16: _FormatSpecifiable {
    public var _arg: Int32 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int32: _FormatSpecifiable {
    public var _arg: Int32 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Int64: _FormatSpecifiable {
    public var _arg: Int64 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt: _FormatSpecifiable {
    public var _arg: UInt64 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt8: _FormatSpecifiable {
    public var _arg: UInt32 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt16: _FormatSpecifiable {
    public var _arg: UInt32 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt32: _FormatSpecifiable {
    public var _arg: UInt32 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension UInt64: _FormatSpecifiable {
    public var _arg: UInt64 {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Float: _FormatSpecifiable {
    public var _arg: Float {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Double: _FormatSpecifiable {
    public var _arg: Double {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension CGFloat: _FormatSpecifiable {
    public var _arg: CGFloat {
        _openSwiftUIUnimplementedFailure()
    }

    public var _specifier: String {
        _openSwiftUIUnimplementedFailure()
    }
}
