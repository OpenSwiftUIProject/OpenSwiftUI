//
//  Text+Formatter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7267202B6A40C9B73733978AB256B462 (SwiftUICore)

public import Foundation

// MARK: - Text + Formatter

@available(OpenSwiftUI_v2_0, *)
extension Text {
    /// Creates a text view that displays the formatted representation
    /// of a reference-convertible value.
    ///
    /// Use this initializer to create a text view that formats `subject`
    /// using `formatter`.
    /// - Parameters:
    ///   - subject: A
    ///   [ReferenceConvertible](https://developer.apple.com/documentation/foundation/referenceconvertible)
    ///   instance compatible with `formatter`.
    ///   - formatter: A
    ///   [Formatter](https://developer.apple.com/documentation/foundation/formatter)
    ///   capable of converting `subject` into a string representation.
    public init<Subject>(
        _ subject: Subject,
        formatter: Formatter
    ) where Subject: ReferenceConvertible {
        self.init(
            anyTextStorage: FormatterTextStorage(
                object: subject as! Subject.ReferenceType,
                formatter: formatter
            )
        )
    }

    /// Creates a text view that displays the formatted representation
    /// of a Foundation object.
    ///
    /// Use this initializer to create a text view that formats `subject`
    /// using `formatter`.
    /// - Parameters:
    ///   - subject: An
    ///   [NSObject](https://developer.apple.com/documentation/objectivec/nsobject)
    ///   instance compatible with `formatter`.
    ///   - formatter: A
    ///   [Formatter](https://developer.apple.com/documentation/foundation/formatter)
    ///   capable of converting `subject` into a string representation.
    public init<Subject>(
        _ subject: Subject,
        formatter: Formatter
    ) where Subject: NSObject {
        self.init(
            anyTextStorage: FormatterTextStorage(
                object: subject,
                formatter: formatter
            )
        )
    }
}

private final class FormatterTextStorage: AnyTextStorage, @unchecked Sendable {
    let object: NSObject
    let formatter: Formatter

    init(object: NSObject, formatter: Formatter) {
        self.object = object
        self.formatter = formatter
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        (formatter as? EnvironmentConfigurableFormatter)?.configure(in: environment)
        guard let string = formatter.string(for: object) else {
            return
        }
        result.append(
            string,
            in: environment,
            with: options
        )
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? FormatterTextStorage else {
            return false
        }
        return object == other.object && formatter == other.formatter
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        false
    }
}

// MARK: - Text + FormatStyle

@available(OpenSwiftUI_v3_0, *)
extension Text {
    /// Creates a text view that displays the formatted representation
    /// of a nonstring type supported by a corresponding format style.
    ///
    /// Use this initializer to create a text view backed by a nonstring
    /// value, using a
    /// [FormatStyle](https://developer.apple.com/documentation/foundation/formatstyle)
    /// to convert the type to a string representation. Any changes to the value
    /// update the string displayed by the text view.
    ///
    /// In the following example, three ``Text`` views present a date with
    /// different combinations of date and time fields, by using different
    /// [Date.FormatStyle](https://developer.apple.com/documentation/foundation/date/formatstyle)
    /// options.
    ///
    ///     @State private var myDate = Date()
    ///     var body: some View {
    ///         VStack {
    ///             Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
    ///             Text(myDate, format: Date.FormatStyle(date: .complete, time: .complete))
    ///             Text(myDate, format: Date.FormatStyle().hour(.defaultDigitsNoAMPM).minute())
    ///         }
    ///     }
    ///
    /// ![Three vertically stacked text views showing the date with different
    /// levels of detail: 4/1/1976; April 1, 1976; Thursday, April 1,
    /// 1976.](Text-init-format-1)
    ///
    /// - Parameters:
    ///   - input: The underlying value to display.
    ///   - format: A format style of type `F` to convert the underlying value
    ///     of type `F.FormatInput` to a string representation.
    public init<F>(
        _ input: F.FormatInput,
        format: F
    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(anyTextStorage: FormatStyleStorage(input: input, format: format))
    }
}

@available(OpenSwiftUI_v6_0, *)
extension Text {
    /// Creates a text view that displays the formatted representation
    /// of a nonstring type supported by a corresponding format style.
    ///
    /// Use this initializer to create a text view backed by a nonstring
    /// value, using a
    /// [FormatStyle](https://developer.apple.com/documentation/foundation/formatstyle)
    /// to convert the type to an attributed string representation. Any changes to the value
    /// update the string displayed by the text view.
    ///
    /// In the following example, three ``Text`` views present a date with
    /// different combinations of date and time fields, by using different
    /// [Date.FormatStyle](https://developer.apple.com/documentation/foundation/date/formatstyle)
    /// options.
    ///
    ///     @State private var myDate = Date()
    ///     var body: some View {
    ///         VStack {
    ///             Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted).attributedStyle)
    ///             Text(myDate, format: Date.FormatStyle(date: .complete, time: .complete).attributedStyle)
    ///             Text(myDate, format: Date.FormatStyle().hour(.defaultDigitsNoAMPM).minute().attributedStyle)
    ///         }
    ///     }
    ///
    /// ![Three vertically stacked text views showing the date with different
    /// levels of detail: 4/1/1976; April 1, 1976; Thursday, April 1,
    /// 1976.](Text-init-format-1)
    ///
    /// - Parameters:
    ///   - input: The underlying value to display.
    ///   - format: A format style of type `F` to convert the underlying value
    ///     of type `F.FormatInput` to an attributed string representation.
    public init<F>(
        _ input: F.FormatInput,
        format: F
    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == AttributedString {
        self.init(anyTextStorage: FormatStyleStorage(input: input, format: format))
    }
}

private class FormatStyleBoxBase {
    func isEqual(to other: FormatStyleBoxBase) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func format(
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom?
    ) -> (output: AttributedString, exact: Bool) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private final class FormatStyleBox<F>: FormatStyleBoxBase where
    F: FormatStyle,
    F.FormatInput: Equatable,
    F.FormatOutput: AttributedStringConvertible
{
    let input: F.FormatInput
    let format: F

    init(input: F.FormatInput, format: F) {
        self.input = input
        self.format = format
    }

    override func isEqual(to other: FormatStyleBoxBase) -> Bool {
        guard let other = other as? FormatStyleBox<F> else {
            return false
        }
        return input == other.input && format == other.format
    }

    override func format(
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom?
    ) -> (output: AttributedString, exact: Bool) {
        var resolvedFormat = format.locale(environment.locale)
        if isLinkedOnOrAfter(.v6) {
            resolvedFormat = resolvedFormat
                .calendar(environment.calendar)
                .timeZone(environment.timeZone)
        }
        if let dependentFormat = resolvedFormat as? any InterfaceIdiomDependentFormatStyle {
            let resolvedIdiom: AnyInterfaceIdiom
            if let idiom {
                resolvedIdiom = idiom
            } else {
                Log.internalWarning("FormatStyleStorage was resolved without idiom!")
                resolvedIdiom = _GraphInputs.defaultInterfaceIdiom
            }
            resolvedFormat = dependentFormat.interfaceIdiom(resolvedIdiom) as! F
        }
        if let dependentFormat = resolvedFormat as? any TextAlignmentDependentFormatStyle {
            resolvedFormat = dependentFormat.textAlignment(environment.multilineTextAlignment) as! F
        }
        if isLinkedOnOrAfter(.v6),
           let dependentFormat = resolvedFormat as? any CapitalizationContextDependentFormatStyle {
            resolvedFormat = dependentFormat.capitalizationContext(environment.capitalizationContext.resolved) as! F
        }
        let resolved = resolvedFormat.exactSizeVariant(environment.textSizeVariant)
        let output = resolved.style.format(input).attributedString
        return (output, resolved.exact)
    }
}

private final class FormatStyleStorage: AnyTextStorage, @unchecked Sendable {
    let storage: FormatStyleBoxBase

    init<F>(
        input: F.FormatInput,
        format: F
    ) where
        F: FormatStyle,
        F.FormatInput: Equatable,
        F.FormatOutput: AttributedStringConvertible
    {
        storage = FormatStyleBox(input: input, format: format)
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        let resolved = storage.format(in: environment, idiom: result.idiom)
        result.append(
            NSAttributedString(resolved.output),
            in: environment,
            with: options,
            isUniqueSizeVariant: resolved.exact
        )
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? FormatStyleStorage else {
            return false
        }
        return storage.isEqual(to: other.storage)
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        false
    }
}

#if !canImport(Darwin)
extension NSAttributedString {
    fileprivate convenience init(_ attributedString: AttributedString) {
        self.init(string: String(attributedString))
    }
}
#endif
