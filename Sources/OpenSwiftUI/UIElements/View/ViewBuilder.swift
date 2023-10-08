//
//  ViewBuilder.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 17.0
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
