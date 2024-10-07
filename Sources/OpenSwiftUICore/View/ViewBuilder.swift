//
//  ViewBuilder.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2023
//  Status: Complete

@resultBuilder
public enum ViewBuilder {
    @_alwaysEmitIntoClient
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: View {
        content
    }

    @_alwaysEmitIntoClient
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

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
extension ViewBuilder: Swift.Sendable {}

extension ViewBuilder {
    @_alwaysEmitIntoClient
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content: View {
        content
    }

    @_alwaysEmitIntoClient
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
        .init(storage: .trueContent(first))
    }

    @_alwaysEmitIntoClient
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent: View, FalseContent: View {
        .init(storage: .falseContent(second))
    }
}

extension ViewBuilder {
    @_alwaysEmitIntoClient
    public static func buildLimitedAvailability(_ content: some View) -> AnyView {
        .init(content)
    }
}
