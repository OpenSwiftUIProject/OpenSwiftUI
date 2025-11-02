//
//  TextLineStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenSwiftUI_SPI

@available(OpenSwiftUI_v3_0, *)
extension Text {

    /// Description of the style used to draw the line for `StrikethroughStyleAttribute`
    /// and `UnderlineStyleAttribute`.
    ///
    /// Use this type to specify `underlineStyle` and `strikethroughStyle`
    /// OpenSwiftUI attributes of an `AttributedString`.
    public struct LineStyle: Hashable, Sendable {
        package var nsUnderlineStyleValue: Int

        package var color: Color?

        package var nsUnderlineStyle: NSUnderlineStyle {
            get { NSUnderlineStyle(rawValue: nsUnderlineStyleValue) }
            set { nsUnderlineStyleValue = newValue.rawValue }
        }

        /// Creates a line style.
        ///
        /// - Parameters:
        ///   - pattern: The pattern of the line.
        ///   - color: The color of the line. If not provided, the foreground
        ///     color of text is used.
        public init(pattern: Text.LineStyle.Pattern = .solid, color: Color? = nil) {
            self.nsUnderlineStyleValue = NSUnderlineStyle([pattern.nsUnderlineStyle, .single]).rawValue
            self.color = color
        }

        /// The pattern, that the line has.
        public struct Pattern: Sendable {
            let nsUnderlineStyle: NSUnderlineStyle

            /// Draw a solid line.
            public static let solid: Text.LineStyle.Pattern = .init(nsUnderlineStyle: [])

            /// Draw a line of dots.
            public static let dot: Text.LineStyle.Pattern = .init(nsUnderlineStyle: .patternDot)

            /// Draw a line of dashes.
            public static let dash: Text.LineStyle.Pattern = .init(nsUnderlineStyle: .patternDash)

            /// Draw a line of alternating dashes and dots.
            public static let dashDot: Text.LineStyle.Pattern = .init(nsUnderlineStyle: .patternDashDot)

            /// Draw a line of alternating dashes and two dots.
            public static let dashDotDot: Text.LineStyle.Pattern = .init(nsUnderlineStyle: .patternDashDotDot)
        }

        /// Draw a single solid line.
        public static let single: Text.LineStyle = .init()

        package init?(_nsUnderlineStyle: NSUnderlineStyle) {
            guard !_nsUnderlineStyle.contains(.thick),
                  !_nsUnderlineStyle.contains(.double),
                  !_nsUnderlineStyle.contains(.byWord),
                  !_nsUnderlineStyle.isEmpty else {
                return nil
            }
            self.nsUnderlineStyleValue = _nsUnderlineStyle.rawValue
            self.color = nil
        }

        package struct Resolved {
            package var nsUnderlineStyle: NSUnderlineStyle

            package var color: Color.Resolved?
        }
    }
}


struct UnderlineStyleKey: EnvironmentKey {
    static var defaultValue: Text.LineStyle? { nil }
}

struct StrikethroughStyleKey: EnvironmentKey {
    static var defaultValue: Text.LineStyle? { nil }
}

extension EnvironmentValues {
    var underlineStyle: Text.LineStyle? {
        get { self[UnderlineStyleKey.self] }
        set { self[UnderlineStyleKey.self] = newValue }
    }

    var strikethroughStyle: Text.LineStyle? {
        get { self[StrikethroughStyleKey.self] }
        set { self[StrikethroughStyleKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v4_0, *)
extension View {

    /// Applies an underline to the text in this view.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that indicates whether underline
    ///     is added. The default value is `true`.
    ///   - pattern: The pattern of the line. The default value is `solid`.
    ///   - color: The color of the underline. If `color` is `nil`, the
    ///     underline uses the default foreground color.
    ///
    /// - Returns: A view where text has a line running along its baseline.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func underline(
        _ isActive: Bool = true,
        pattern: Text.LineStyle.Pattern = .solid,
        color: Color? = nil
    ) -> some View {
        environment(
            \.underlineStyle,
             isActive ? Text.LineStyle(pattern: pattern, color: color) : nil
        )
    }

    /// Applies a strikethrough to the text in this view.
    ///
    /// - Parameters:
    ///   - isActive: A Boolean value that indicates whether
    ///     strikethrough is added. The default value is `true`.
    ///   - pattern: The pattern of the line. The default value is `solid`.
    ///   - color: The color of the strikethrough. If `color` is `nil`, the
    ///     strikethrough uses the default foreground color.
    ///
    /// - Returns: A view where text has a line through its center.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func strikethrough(
        _ isActive: Bool = true,
        pattern: Text.LineStyle.Pattern = .solid,
        color: Color? = nil
    ) -> some View {
        environment(
            \.strikethroughStyle,
             isActive ? Text.LineStyle(pattern: pattern, color: color) : nil
        )
    }
}
