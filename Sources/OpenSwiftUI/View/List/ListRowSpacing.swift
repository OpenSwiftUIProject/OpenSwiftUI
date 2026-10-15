//
//  ListRowSpacing.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1F5CF552B45C3ADB33DFD14469AB7BE9 (SwiftUI)

public import Foundation
public import OpenSwiftUICore

// MARK: - ListRowSpacing

private struct ListRowSpacing: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

extension CachedEnvironment.ID {
    static let listRowSpacing: CachedEnvironment.ID = .init()
}

// MARK: - View + listRowSpacing

@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    /// Sets the vertical spacing between two adjacent rows in a List.
    ///
    /// The following example creates a List with 10 pts of spacing between each
    /// row:
    ///
    ///     List {
    ///         Text("Blue")
    ///         Text("Red")
    ///     }
    ///     .listRowSpacing(10.0)
    ///
    /// - Parameter spacing: The spacing value to use. A value of `nil` uses
    ///   the default spacing.
    @inlinable
    nonisolated public func listRowSpacing(_ spacing: CGFloat?) -> some View {
        environment(\.listRowSpacing, spacing)
    }
}

// MARK: - EnvironmentValues + listRowSpacing

@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension EnvironmentValues {
    @usableFromInline
    var listRowSpacing: CGFloat? {
        get { self[ListRowSpacing.self] }
        set { self[ListRowSpacing.self] = newValue }
    }

    var _listRowSpacing: CGFloat? {
        get { listRowSpacing }
        set { listRowSpacing = newValue }
    }
}
