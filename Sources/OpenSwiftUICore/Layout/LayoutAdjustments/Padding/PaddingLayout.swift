//
//  PaddingLayout.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

public import Foundation

@frozen
public struct _PaddingLayout: /* UnaryLayout, */ Animatable, PrimitiveViewModifier /* , MultiViewModifier */ {
    public var edges: Edge.Set
    public var insets: EdgeInsets?

    @inlinable
    public init(edges: Edge.Set = .all, insets: EdgeInsets?) {
        self.edges = edges
        self.insets = insets
    }

    public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Never
}

extension View {
    @inlinable
    public func padding(_ insets: EdgeInsets) -> some View {
        modifier(_PaddingLayout(insets: insets))
    }

    @inlinable
    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        let insets = length.map { EdgeInsets(_all: $0) }
        return modifier(_PaddingLayout(edges: edges, insets: insets))
    }

    @inlinable
    public func padding(_ length: CGFloat) -> some View {
        padding(.all, length)
    }

    public func _tightPadding() -> some View {
        padding(8.0)
    }
}
