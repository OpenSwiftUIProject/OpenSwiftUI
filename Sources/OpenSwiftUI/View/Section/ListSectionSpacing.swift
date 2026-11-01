//
//  ListSectionSpacing.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 13443704EDBF17EBED429EA3EE76760A (SwiftUI)

public import Foundation
import OpenAttributeGraphShims
public import OpenSwiftUICore

// MARK: - ListSectionSpacing

/// The spacing options between two adjacent sections in a list.
@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
public struct ListSectionSpacing: Sendable {
    private var storage: Storage

    var value: CGFloat? {
        switch storage {
        case let .custom(spacing): spacing
        case .default: nil
        case .compact: 12
        }
    }

    /// The default spacing between sections
    public static let `default`: ListSectionSpacing = .init(storage: .default)

    /// Compact spacing between sections
    public static let compact: ListSectionSpacing = .init(storage: .compact)

    /// Creates a custom spacing value.
    ///
    /// - Parameter spacing: the amount of spacing to use.
    public static func custom(_ spacing: CGFloat) -> ListSectionSpacing {
        .init(storage: .custom(spacing))
    }

    private enum Storage: Sendable {
        case custom(CGFloat)
        case `default`
        case compact
    }
}

// MARK: - View + listSectionSpacing

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension View {
    /// Sets the spacing between adjacent sections in a ``List``.
    ///
    /// Pass `.default` for the default spacing, or use `.compact` for
    /// a compact appearance between sections.
    ///
    /// The following example creates a ``List`` with compact spacing between
    /// sections:
    ///
    ///     List {
    ///         Section("Colors") {
    ///             Text("Blue")
    ///             Text("Red")
    ///         }
    ///
    ///         Section("Shapes") {
    ///             Text("Square")
    ///             Text("Circle")
    ///         }
    ///     }
    ///     .listSectionSpacing(.compact)
    ///
    /// Spacing can also be specified on an individual ``Section``, as in this
    /// example:
    ///
    ///     Section("Borders") {
    ///         Text("Dashed")
    ///         Text("Solid")
    ///     }
    ///     .listSectionSpacing(.compact)
    ///
    /// Spacing applied on sections in the ``List`` overrides spacing applied on
    /// the ``List`` as a whole.
    ///
    /// - Parameter spacing: the ``ListSectionSpacing`` to apply.
    @inlinable
    nonisolated public func listSectionSpacing(_ spacing: ListSectionSpacing) -> some View {
        modifier(_TraitWritingModifier<ListSectionSpacingTraitKey>(value: spacing))
            .environment(\.listSectionSpacing, spacing)
    }

    /// Sets the spacing between adjacent sections in a ``List`` to a custom
    /// value.
    ///
    /// The following example creates a ``List`` with 5 pts of spacing between
    /// sections:
    ///
    ///     List {
    ///         Section("Colors") {
    ///             Text("Blue")
    ///             Text("Red")
    ///         }
    ///
    ///         Section("Shapes") {
    ///             Text("Square")
    ///             Text("Circle")
    ///         }
    ///     }
    ///     .listSectionSpacing(5.0)
    ///
    /// Spacing can also be specified on an individual ``Section``, as in this
    /// example:
    ///
    ///     Section("Borders") {
    ///         Text("Dashed")
    ///         Text("Solid")
    ///     }
    ///     .listSectionSpacing(10.0)
    ///
    /// If adjacent sections have different spacing applied, each section
    /// applies half its spacing above and below. Sections without
    /// explicit spacing apply the spacing of their adjacent sections.
    ///
    ///     List {
    ///         Section("Colors") {
    ///             Text("Blue")
    ///             Text("Red")
    ///         }
    ///
    ///         Section("Borders") {
    ///             Text("Dashed")
    ///             Text("Solid")
    ///         }
    ///         .listSectionSpacing(10.0)
    ///
    ///         Section("Shapes") {
    ///             Text("Square")
    ///             Text("Circle")
    ///         }
    ///         .listSectionSpacing(100.0)
    ///     }
    ///
    /// In the above example, the "Colors" and "Borders" section are separated
    /// by 10 pts of spacing, and the "Borders" and "Shapes" section are
    /// separated by 55 pts of spacing.
    ///
    /// Spacing applied on sections in the ``List`` overrides spacing applied on
    /// the ``List`` as a whole.
    ///
    /// - Parameter spacing: the amount of spacing to apply.
    @inlinable
    nonisolated public func listSectionSpacing(_ spacing: CGFloat) -> some View {
        listSectionSpacing(.custom(spacing))
    }

    nonisolated func listSectionSpacing(_ spacing: ListSectionSpacing?) -> some View {
        modifier(_TraitWritingModifier<ListSectionSpacingTraitKey>(value: spacing))
            .environment(\.listSectionSpacing, spacing)
    }
}

// MARK: - ListSectionSpacingTraitKey

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@usableFromInline
struct ListSectionSpacingTraitKey: _ViewTraitKey {
    @_alwaysEmitIntoClient
    static var defaultValue: ListSectionSpacing? { nil }

    @usableFromInline
    typealias Value = ListSectionSpacing?
}

@available(*, unavailable)
extension ListSectionSpacingTraitKey: Sendable {}

// MARK: - UseCompactSectionSpacingTraitKey

@available(OpenSwiftUI_v4_0, *)
@usableFromInline
struct UseCompactSectionSpacingTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { false }

    @usableFromInline
    typealias Value = Bool
}

@available(*, unavailable)
extension UseCompactSectionSpacingTraitKey: Sendable {}

// MARK: - EnvironmentValues + listSectionSpacing

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension EnvironmentValues {
    @usableFromInline
    var listSectionSpacing: ListSectionSpacing? {
        get { self[ListSectionSpacingEnvironmentKey.self] }
        set { self[ListSectionSpacingEnvironmentKey.self] = newValue }
    }

    var _listSectionSpacing: ListSectionSpacing? {
        get { listSectionSpacing }
        set { listSectionSpacing = newValue }
    }
}

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
private struct ListSectionSpacingEnvironmentKey: EnvironmentKey {
    static var defaultValue: ListSectionSpacing? { nil }
}

// MARK: - GraphInputs + listSectionSpacing

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension _GraphInputs {
    var listSectionSpacing: Attribute<ListSectionSpacing?> {
        mapEnvironment(id: .listSectionSpacing) { $0.listSectionSpacing }
    }
}

extension CachedEnvironment.ID {
    static let listSectionSpacing: CachedEnvironment.ID = .init()
}

// MARK: - ViewTraitCollection + effectiveListSectionSpacing

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension ViewTraitCollection {
    var effectiveListSectionSpacing: ListSectionSpacing? {
        if let spacing = self[ListSectionSpacingTraitKey.self] {
            return spacing
        }
        return self[UseCompactSectionSpacingTraitKey.self] ? .compact : nil
    }
}
