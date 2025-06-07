//
//  ViewBuilder.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.2
//  Status: Complete

/// A custom parameter attribute that constructs views from closures.
///
/// You typically use ``ViewBuilder`` as a parameter attribute for child
/// view-producing closure parameters, allowing those closures to provide
/// multiple child views. For example, the following `contextMenu` function
/// accepts a closure that produces one or more views via the view builder.
///
///     func contextMenu<MenuItems: View>(
///         @ViewBuilder menuItems: () -> MenuItems
///     ) -> some View
///
/// Clients of this function can use multiple-statement closures to provide
/// several child views, as shown in the following example:
///
///     myView.contextMenu {
///         Text("Cut")
///         Text("Copy")
///         Text("Paste")
///         if isSymbol {
///             Text("Jump to Definition")
///         }
///     }
///
@available(OpenSwiftUI_v1_0, *)
@resultBuilder
public struct ViewBuilder {
    /// Builds an expression within the builder.
    @_alwaysEmitIntoClient
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: View {
        content
    }

    /// Rejects incompatible expressions within the builder.
    @available(*, unavailable, message: "this expression does not conform to 'View'")
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public static func buildExpression(_ invalid: Any) -> some View {
        fatalError()
    }

    /// Builds an empty view from a block containing no statements.
    @_alwaysEmitIntoClient
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    /// Passes a single view written as a child view through unmodified.
    ///
    /// An example of a single view written as a child view is
    /// `{ Text("Hello") }`.
    @_alwaysEmitIntoClient
    public static func buildBlock<Content>(_ content: Content) -> Content where Content: View {
        content
    }

    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public static func buildBlock<each Content>(_ content: repeat each Content) -> TupleView<(repeat each Content)> where repeat each Content: View {
        TupleView((repeat each content))
    }
}

@available(*, unavailable)
extension ViewBuilder: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension ViewBuilder {
    /// Produces an optional view for conditional statements in multi-statement
    /// closures that's only visible when the condition evaluates to true.
    @_alwaysEmitIntoClient
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content: View {
        content
    }

    /// Produces content for a conditional statement in a multi-statement closure
    /// when the condition is true.
    @_alwaysEmitIntoClient
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
        .init(storage: .trueContent(first))
    }

    /// Produces content for a conditional statement in a multi-statement closure
    /// when the condition is false.
    @_alwaysEmitIntoClient
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
        .init(storage: .falseContent(second))
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ViewBuilder {
    /// Processes view content for a conditional compiler-control
    /// statement that performs an availability check.
    @_alwaysEmitIntoClient
    public static func buildLimitedAvailability<Content>(_ content: Content) -> AnyView where Content: View {
        .init(content)
    }
}
