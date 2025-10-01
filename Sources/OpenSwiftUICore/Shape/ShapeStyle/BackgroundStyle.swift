//
//  BackgroundStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: C7D4771CFE453D905E7BCD5A907D32EB (SwiftUICore)

extension ShapeStyle where Self == BackgroundStyle {
    /// The background style in the current context.
    ///
    /// Access this value to get the style OpenSwiftUI uses for the background
    /// in the current context. The specific color that OpenSwiftUI renders depends
    /// on factors like the platform and whether the user has turned on Dark
    /// Mode.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var background: BackgroundStyle {
        .init()
    }
}

@frozen
public struct BackgroundStyle: ShapeStyle {
    static let shared = AnyShapeStyle(BackgroundStyle())
    
    @inlinable
    public init() {}
    
    // TODO
}

// MARK: - BackgroundStyleKey

private struct BackgroundStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
}

// MARK: - EnvironmentValues + ForegroundStyle

extension EnvironmentValues {
    package var backgroundStyle: AnyShapeStyle? {
        get { self[BackgroundStyleKey.self] }
        set { self[BackgroundStyleKey.self] = newValue }
    }
    
    package var currentBackgroundStyle: AnyShapeStyle? {
        backgroundStyle
    }
    
    package var effectiveBackgroundStyle: AnyShapeStyle {
        currentBackgroundStyle ?? BackgroundStyle.shared
    }
}
