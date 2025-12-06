//
//  Text+SizeFitting.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by _TextVariantPreference implementation
//  ID: 22A2F77020526CCA53FF38DE37184183 (SwiftUICore)

// MARK: - TextVariantPreference

@available(OpenSwiftUI_v6_0, *)
extension Text {

    /// Controls the way text size variants are chosen.
    ///
    /// Certain types of text, such as ``Text(_:format:)``, can generate strings of
    /// different size to better fit the available space. By default, all text uses the
    /// widest available variant. Setting the variant to be
    /// ``TextVariantPreference/sizeDependent`` allows the text to take the available
    /// space into account when choosing what content to display.
    @available(OpenSwiftUI_v6_0, *)
    public func textVariant<V>(
        _ preference: V
    ) -> some View where V: TextVariantPreference {
        preference._preference.body(self)
    }
}

/// A protocol for controlling the size variant of text views.
@available(OpenSwiftUI_v6_0, *)
public protocol TextVariantPreference {
    var _preference: _TextVariantPreference<Self> { get }
}

/// Internal requirement for ``TextVariantPreference``.
@available(OpenSwiftUI_v6_0, *)
public struct _TextVariantPreference<Preference>: Sendable where Preference: TextVariantPreference {
    fileprivate func body<V>(
        _ view: V
    ) -> some View where V: View {
        // TODO
        _openSwiftUIUnimplementedFailure()
    }
}

/// The default text variant preference that chooses the largest available
/// variant.
@available(OpenSwiftUI_v6_0, *)
public struct FixedTextVariant: TextVariantPreference, Sendable {
    public var _preference: _TextVariantPreference<FixedTextVariant> {
        .init()
    }
}

/// The size dependent variant preference allows the text to take the available
/// space into account when choosing the variant to display.
@available(OpenSwiftUI_v6_0, *)
public struct SizeDependentTextVariant: TextVariantPreference, Sendable {
    public var _preference: _TextVariantPreference<SizeDependentTextVariant> {
        .init()
    }
}

@available(OpenSwiftUI_v6_0, *)
extension TextVariantPreference where Self == FixedTextVariant {

    /// The default text variant preference. It always chooses the largest available
    /// variant.
    public static var fixed: FixedTextVariant {
        .init()
    }
}

@available(OpenSwiftUI_v6_0, *)
extension TextVariantPreference where Self == SizeDependentTextVariant {

    /// The size dependent preference allows the text to take the available space into
    /// account when choosing the size variant to display.
    ///
    /// When a ``Text`` provides different size options for its content, the size
    /// dependent preference chooses the largest option that fits into the available
    /// space without truncating or clipping its content.
    ///
    /// - Note: Only use this option where needed as it incurs a performance cost on
    /// every ``Text`` it is applied to, even if the concrete text initializer cannot
    /// provide multiple size variants and there is no visual impact.
    ///
    /// ## Difference to ViewThatFits
    ///
    /// The ``sizeDependent`` text variant preference differs from ``ViewThatFits`` both
    /// in usage and in behavior. ``ViewThatFits`` chooses the first child where the
    /// **ideal** size fits the available space. For ``Text`` this means that it will
    /// only choose texts that can fit their contents into the available space **without
    /// a line break**. With this text variant preference, on the other hand, the
    /// largest variant is chosen that can fit the available space while respecting all
    /// the regular layout rules, such as ``EnvironmentValues/lineLimit``.
    ///
    /// To use ``ViewThatFits``, multiple different views have to be provided as the
    /// different size options. With this text variant preference, a single ``Text``
    /// provides the different size variants intrinsically. The way it generates these
    /// size variants and how many size variants are available depends on the text
    /// initializer used.
    public static var sizeDependent: SizeDependentTextVariant {
        .init()
    }
}

// MARK: - TextSizeVariant

package struct TextSizeVariant: Comparable, Hashable, RawRepresentable {
    package var rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let regular: TextSizeVariant = .init(rawValue: 0)

    package static let compact: TextSizeVariant = .init(rawValue: 1)

    package static let small: TextSizeVariant = .init(rawValue: 2)

    package static let tiny: TextSizeVariant = .init(rawValue: 3)

    package static func < (lhs: TextSizeVariant, rhs: TextSizeVariant) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    package var nextUp: TextSizeVariant? {
        if rawValue == 0 {
            return nil
        } else {
            return TextSizeVariant(rawValue: rawValue - 1)
        }
    }

    package var nextDown: TextSizeVariant {
        TextSizeVariant(rawValue: rawValue + 1)
    }
}

extension TextSizeVariant: Codable {
    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        self.init(rawValue: rawValue)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - SizeFittingTextResolver [WIP]

protocol SizeFittingTextResolver: LayoutEngine {
    associatedtype Input
    associatedtype Engine: LayoutEngine

    func shouldUpdate(for input: Input, inputChanged: Bool) -> Bool
    func value(for input: Input) -> SizeFittingTextCacheValue<Engine>
    var narrowerVariant: Self { get }
}

protocol TextSizeFittingLogic {
    func suggestedVariant(for proposedSize: _ProposedSize) -> TextSizeVariant?
    func onInvalidation(of variant: TextSizeVariant)
}

class SizeFittingTextCache {

}

struct SizeFittingTextCacheValue<Engine> where Engine: LayoutEngine {
    var text: ResolvedStyledText
    var engine: Engine
    var renderer: TextRendererBoxBase?
}
