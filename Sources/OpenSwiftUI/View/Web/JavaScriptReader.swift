//
//  JavaScriptReader.swift
//  OpenSwiftUI
//

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
public import OpenSwiftUICore

// MARK: - JavaScriptReader

/// A view that synchronously resolves a Swift value from JavaScript-backed
/// state and uses that value to create its content.
///
/// Keep JavaScript objects inside the `resolve` closure and return a
/// `Sendable` Swift snapshot. OpenSwiftUI can evaluate the closure more than
/// once, so the closure should be fast and free of side effects.
/// JavaScript state changes don't invalidate this view by themselves; use an
/// OpenSwiftUI state change to request a new value when the source is dynamic.
///
/// This type is available only to WASI web-renderer clients. The OpenSwiftUI
/// package doesn't depend on a JavaScript bridge; the executable supplies one
/// inside the closure when needed.
@_spi(WebRenderer)
@MainActor
@preconcurrency
public struct JavaScriptReader<Value, Content>: View where Value: Sendable, Content: View {
    private let resolve: @MainActor @Sendable () -> Value
    private let content: @MainActor (Value) -> Content

    /// Creates a JavaScript-backed value reader.
    ///
    /// - Parameters:
    ///   - resolve: A synchronous, side-effect-free closure that converts
    ///     JavaScript-backed state into a `Sendable` Swift value.
    ///   - content: A view builder that creates content from the resolved value.
    public init(
        resolve: @escaping @MainActor @Sendable () -> Value,
        @ViewBuilder content: @escaping @MainActor (Value) -> Content
    ) {
        self.resolve = resolve
        self.content = content
    }

    public var body: Content {
        content(resolve())
    }
}

@available(*, unavailable)
extension JavaScriptReader: Sendable {}
#endif
