//
//  HStack.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: Complete

public import Foundation

/// A view that arranges its subviews in a horizontal line.
///
/// Unlike ``LazyHStack``, which only renders the views when your app needs to
/// display them onscreen, an `HStack` renders the views all at once, regardless
/// of whether they are on- or offscreen. Use the regular `HStack` when you have
/// a small number of subviews or don't want the delayed rendering behavior
/// of the "lazy" version.
///
/// The following example shows a simple horizontal stack of five text views:
///
///     var body: some View {
///         HStack(
///             alignment: .top,
///             spacing: 10
///         ) {
///             ForEach(
///                 1...5,
///                 id: \.self
///             ) {
///                 Text("Item \($0)")
///             }
///         }
///     }
///
/// ![Five text views, named Item 1 through Item 5, arranged in a
/// horizontal row.](OpenSwiftUI-HStack-simple.png)
///
/// > Note: If you need a horizontal stack that conforms to the ``Layout``
/// protocol, like when you want to create a conditional layout using
/// ``AnyLayout``, use ``HStackLayout`` instead.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct HStack<Content>: View, UnaryView, PrimitiveView where Content: View {
    @usableFromInline
    var _tree: _VariadicView.Tree<_HStackLayout, Content>

    /// Creates a horizontal stack with the given spacing and vertical alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. This
    ///     guide has the same vertical screen coordinate for every subview.
    ///   - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the stack to choose a default distance for each pair of
    ///     subviews.
    ///   - content: A view builder that creates the content of this stack.
    @inlinable
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _tree = .init(
            _HStackLayout(alignment: alignment, spacing: spacing)
        ) {
            content()
        }
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _VariadicView.Tree.makeDebuggableView(
            view: view[offset: { .of(&$0._tree) }],
            inputs: inputs
        )
    }
}

@available(*, unavailable)
extension HStack: Sendable {}

@_spi(ReallyDoNotImport)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "HStackLayout")
extension HStack: Animatable where Content == EmptyView {
    public typealias AnimatableData = EmptyAnimatableData
}

@_spi(ReallyDoNotImport)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "HStackLayout")
extension HStack: Layout where Content == EmptyView {
    public typealias Cache = _HStackLayout.Cache
}

@available(*, deprecated, renamed: "HStackLayout")
extension HStack: DerivedLayout where Content == EmptyView {
    package typealias Base = _HStackLayout

    package var base: _HStackLayout {
        _HStackLayout(
            alignment: _tree.root.alignment,
            spacing: _tree.root.spacing
        )
    }
}

@frozen
public struct _HStackLayout {
    public var alignment: VerticalAlignment

    public var spacing: CGFloat?

    @inlinable
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    package static let majorAxis: Axis = .horizontal
}

extension _HStackLayout: HVStack {
    @available(OpenSwiftUI_v1_0, *)
    public typealias Body = Never

    @available(OpenSwiftUI_v1_0, *)
    package typealias MinorAxisAlignment = VerticalAlignment
}

@available(OpenSwiftUI_v4_0, *)
extension _HStackLayout: Layout {
    public typealias Cache = _StackLayoutCache

    @available(OpenSwiftUI_v4_0, *)
    public typealias AnimatableData = EmptyAnimatableData
}

extension _HStackLayout: _VariadicView.ImplicitRoot {
    package static var implicitRoot: _HStackLayout { .init() }
}

/// A horizontal container that you can use in conditional layouts.
///
/// This layout container behaves like an ``HStack``, but conforms to the
/// ``Layout`` protocol so you can use it in the conditional layouts that you
/// construct with ``AnyLayout``. If you don't need a conditional layout, use
/// ``HStack`` instead.
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct HStackLayout: Layout {
    /// The vertical alignment of subviews.
    public var alignment: VerticalAlignment

    /// The distance between adjacent subviews.
    ///
    /// Set this value to `nil` to use default distances between subviews.
    public var spacing: CGFloat?

    /// Creates a horizontal stack with the specified spacing and vertical
    /// alignment.
    ///
    /// - Parameters:
    ///     - alignment: The guide for aligning the subviews in this stack. It
    ///       has the same vertical screen coordinate for all subviews.
    ///     - spacing: The distance between adjacent subviews. Set this value
    ///       to `nil` to use default distances between subviews.
    @inlinable
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    @available(OpenSwiftUI_v4_0, *)
    public typealias AnimatableData = EmptyAnimatableData

    @available(OpenSwiftUI_v4_0, *)
    public typealias Cache = _HStackLayout.Cache
}

extension HStackLayout: DerivedLayout {
    package var base: _HStackLayout {
        .init(alignment: alignment, spacing: spacing)
    }

    @available(OpenSwiftUI_v4_0, *)
    package typealias Base = _HStackLayout
}
