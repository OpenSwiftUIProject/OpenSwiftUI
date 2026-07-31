//
//  LineLimits.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 32CC33FA2019BEDFCE31FB4066945274 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - View + Line Limits

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Sets the maximum number of lines that text can occupy in this view.
    ///
    /// Use this modifier to cap the number of lines that an individual text
    /// element can display.
    ///
    /// The line limit applies to all ``Text`` instances within a hierarchy. For
    /// example, an ``HStack`` with multiple pieces of text longer than three
    /// lines caps each piece of text to three lines rather than capping the
    /// total number of lines across the ``HStack``.
    ///
    /// In the example below, the modifier limits the very long
    /// line in the ``Text`` element to the 2 lines that fit within the view's
    /// bounds:
    ///
    ///     Text("This is a long string that demonstrates the effect of OpenSwiftUI's lineLimit(:_) operator.")
    ///         .frame(width: 200, height: 200, alignment: .leading)
    ///         .lineLimit(2)
    ///
    /// ![A screenshot showing showing the effect of the line limit operator on
    /// a very long string in a view.](OpenSwiftUI-view-lineLimit.png)
    ///
    /// - Parameter number: The line limit. If `nil`, no line limit applies.
    ///
    /// - Returns: A view that limits the number of lines that ``Text``
    ///   instances display.
    @inlinable
    nonisolated public func lineLimit(_ number: Int?) -> some View {
        environment(\.lineLimit, number)
    }

    /// Sets to a partial range the number of lines that text can occupy in
    /// this view.
    ///
    /// Use this modifier to specify a partial range of lines that a ``Text``
    /// view or a vertical ``TextField`` can occupy. When the text of such
    /// views occupies less space than the provided limit, that view expands to
    /// occupy the minimum number of lines.
    ///
    ///     Form {
    ///         TextField("Title", text: $model.title)
    ///         TextField("Notes", text: $model.notes, axis: .vertical)
    ///             .lineLimit(3...)
    ///     }
    ///
    /// - Parameter limit: The line limit.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: PartialRangeFrom<Int>) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: limit.lowerBound,
                upperLimit: nil
            )
        )
    }

    /// Sets to a partial range the number of lines that text can occupy
    /// in this view.
    ///
    /// Use this modifier to specify a partial range of lines that a
    /// ``Text`` view or a vertical ``TextField`` can occupy. When the text of
    /// such views occupies more space than the provided limit, a ``Text`` view
    /// truncates its content while a ``TextField`` becomes scrollable.
    ///
    ///     Form {
    ///         TextField("Title", text: $model.title)
    ///         TextField("Notes", text: $model.notes, axis: .vertical)
    ///             .lineLimit(...3)
    ///     }
    ///
    /// - Parameter limit: The line limit.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: PartialRangeThrough<Int>) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: nil,
                upperLimit: limit.upperBound
            )
        )
    }

    /// Sets to a closed range the number of lines that text can occupy in
    /// this view.
    ///
    /// Use this modifier to specify a closed range of lines that a ``Text``
    /// view or a vertical ``TextField`` can occupy. When the text of such
    /// views occupies more space than the provided limit, a ``Text`` view
    /// truncates its content while a ``TextField`` becomes scrollable.
    ///
    ///     Form {
    ///         TextField("Title", text: $model.title)
    ///         TextField("Notes", text: $model.notes, axis: .vertical)
    ///             .lineLimit(1...3)
    ///     }
    ///
    /// - Parameter limit: The line limit.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: ClosedRange<Int>) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: limit.lowerBound,
                upperLimit: limit.upperBound
            )
        )
    }

    /// Sets a limit for the number of lines text can occupy in this view.
    ///
    /// Use this modifier to specify a limit to the lines that a
    /// ``Text`` or a vertical ``TextField`` may occupy. If passed a
    /// value of true for the `reservesSpace` parameter, and the text of such
    /// views occupies less space than the provided limit, that view expands
    /// to occupy the minimum number of lines. When the text occupies
    /// more space than the provided limit, a ``Text`` view truncates its
    /// content while a ``TextField`` becomes scrollable.
    ///
    ///     GroupBox {
    ///         Text("Title")
    ///             .font(.headline)
    ///             .lineLimit(2, reservesSpace: true)
    ///         Text("Subtitle")
    ///             .font(.subheadline)
    ///             .lineLimit(4, reservesSpace: true)
    ///     }
    ///
    /// - Parameter limit: The line limit.
    /// - Parameter reservesSpace: Whether text reserves space so that
    ///   it always occupies the height required to display the specified
    ///   number of lines.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: Int, reservesSpace: Bool) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: reservesSpace ? limit : nil,
                upperLimit: limit
            )
        )
    }
}

// MARK: - LineLimitModifier

struct LineLimitModifier: ViewModifier, PrimitiveViewModifier, EnvironmentModifier {
    var lowerLimit: Int?
    var upperLimit: Int?

    static func makeEnvironment(
        modifier: Attribute<LineLimitModifier>,
        environment: inout EnvironmentValues
    ) {
        environment.lineLimit = modifier.value.upperLimit
        environment.lowerLineLimit = modifier.value.lowerLimit
    }
}

// MARK: - EnvironmentValues + Line Limits

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    private struct LowerLineLimitKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    private struct LineLimitKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    /// The maximum number of lines that text can occupy in a view.
    ///
    /// The maximum number of lines is `1` if the value is less than `1`. If the
    /// value is `nil`, the text uses as many lines as required. The default is
    /// `nil`.
    public var lineLimit: Int? {
        get { self[LineLimitKey.self] }
        set { self[LineLimitKey.self] = newValue }
    }

    package var lowerLineLimit: Int? {
        get { self[LowerLineLimitKey.self] }
        set { self[LowerLineLimitKey.self] = newValue }
    }
}
