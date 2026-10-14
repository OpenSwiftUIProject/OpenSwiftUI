//
//  ListRowInsets.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E0697BB83CA4DF1B18B89ADE22D27A03 (SwiftUI)

public import OpenSwiftUICore

// MARK: - ListRowInsetsTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct ListRowInsetsTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: EdgeInsets? { nil }
}

@available(*, unavailable)
extension ListRowInsetsTraitKey: Sendable {}

// MARK: - View + listRowInsets

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Applies an inset to the rows in a list.
    ///
    /// Use `listRowInsets(_:)` to change the default padding of the content of
    /// list items.
    ///
    /// In the example below, the `Flavor` enumeration provides content for list
    /// items. The OpenSwiftUI ``ForEach`` structure computes views for each element
    /// of the `Flavor` enumeration and extracts the raw value of each of its
    /// elements using the resulting text to create each list row item. The
    /// `listRowInsets(_:)` modifier then changes the edge insets of each row
    /// of the list according to the ``EdgeInsets`` provided:
    ///
    ///     struct ContentView: View {
    ///         enum Flavor: String, CaseIterable, Identifiable {
    ///             var id: String { self.rawValue }
    ///             case vanilla, chocolate, strawberry
    ///         }
    ///
    ///         var body: some View {
    ///             List {
    ///                 ForEach(Flavor.allCases) {
    ///                     Text($0.rawValue)
    ///                         .listRowInsets(.init(top: 0,
    ///                                              leading: 25,
    ///                                              bottom: 0,
    ///                                              trailing: 0))
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// ![A screenshot showing a list with leading 25 point inset on each row.](OpenSwiftUI-View-ListRowInsets.png)
    ///
    /// - Parameter insets: The ``EdgeInsets`` to apply to the edges of the
    ///   view.
    /// - Returns: A view that uses the given edge insets when used as a list
    ///   cell.
    @inlinable
    nonisolated public func listRowInsets(_ insets: EdgeInsets?) -> some View {
        _trait(ListRowInsetsTraitKey.self, insets)
    }
}

// MARK: - ListRowInsetsKey

private struct ListRowInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init()
}

// MARK: - EffectiveListRowInsetsKey

private struct EffectiveListRowInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init()
}

// MARK: - EnvironmentValues + listRowInsets

extension EnvironmentValues {
    var listRowInsets: EdgeInsets {
        get { self[ListRowInsetsKey.self] }
        set { self[ListRowInsetsKey.self] = newValue }
    }

    var effectiveListRowInsets: EdgeInsets {
        get { self[EffectiveListRowInsetsKey.self] }
        set { self[EffectiveListRowInsetsKey.self] = newValue }
    }
}
