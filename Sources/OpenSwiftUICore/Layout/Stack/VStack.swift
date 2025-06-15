//
//  VStack.swift
//  OpenSwiftUICore
//
//  Status: Complete

public import Foundation

// MARK: - VStack [6.4.41]

/// A view that arranges its subviews in a vertical line.
///
/// Unlike ``LazyVStack``, which only renders the views when your app needs to
/// display them, a `VStack` renders the views all at once, regardless
/// of whether they are on- or offscreen. Use the regular `VStack` when you have
/// a small number of subviews or don't want the delayed rendering behavior
/// of the "lazy" version.
///
/// The following example shows a simple vertical stack of 10 text views:
///
///     var body: some View {
///         VStack(
///             alignment: .leading,
///             spacing: 10
///         ) {
///             ForEach(
///                 1...10,
///                 id: \.self
///             ) {
///                 Text("Item \($0)")
///             }
///         }
///     }
///
/// ![Ten text views, named Item 1 through Item 10, arranged in a
/// vertical line.](OpenSwiftUI-VStack-simple.png)
///
/// > Note: If you need a vertical stack that conforms to the ``Layout``
/// protocol, like when you want to create a conditional layout using
/// ``AnyLayout``, use ``VStackLayout`` instead.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct VStack<Content>: View, UnaryView, PrimitiveView where Content: View {
    @usableFromInline
    var _tree: _VariadicView.Tree<_VStackLayout, Content>

    /// Creates an instance with the given spacing and horizontal alignment.
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
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _tree = .init(
            _VStackLayout(alignment: alignment, spacing: spacing)
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
extension VStack: Sendable {}

@_spi(ReallyDoNotImport)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "VStackLayout")
extension VStack: Animatable where Content == EmptyView {
    public typealias AnimatableData = EmptyAnimatableData
}

@_spi(ReallyDoNotImport)
@available(OpenSwiftUI_v4_0, *)
@available(*, deprecated, renamed: "VStackLayout")
extension VStack: Layout where Content == EmptyView {
    public typealias Cache = _VStackLayout.Cache
}

@available(*, deprecated, renamed: "VStackLayout")
extension VStack: DerivedLayout where Content == EmptyView {
    package typealias Base = _VStackLayout

    package var base: _VStackLayout {
        _VStackLayout(
            alignment: _tree.root.alignment,
            spacing: _tree.root.spacing
        )
    }
}

// MARK: - _VStackLayout [6.4.41]

/// A layout that arranges its children in a vertical line.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _VStackLayout {
    /// The horizontal alignment of children.
    public var alignment: HorizontalAlignment

    /// The distance between adjacent children, or nil if the stack should
    /// choose a default distance for each pair of children.
    public var spacing: CGFloat?

    /// Creates an instance with the given `spacing` and X axis `alignment`.
    ///
    /// - Parameters:
    ///     - alignment: the guide that will have the same horizontal screen
    ///       coordinate for all children.
    ///     - spacing: the distance between adjacent children, or nil if the
    ///       stack should choose a default distance for each pair of children.
    @inlinable
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    package static let majorAxis: Axis = .vertical
}

extension _VStackLayout: HVStack {
    @available(OpenSwiftUI_v1_0, *)
    public typealias Body = Never

    @available(OpenSwiftUI_v1_0, *)
    package typealias MinorAxisAlignment = HorizontalAlignment
}

@available(OpenSwiftUI_v4_0, *)
extension _VStackLayout: Layout {
    public typealias Cache = _StackLayoutCache

    @available(OpenSwiftUI_v4_0, *)
    public typealias AnimatableData = EmptyAnimatableData
}

extension _VStackLayout: _VariadicView.ImplicitRoot {
    package static var implicitRoot: _VStackLayout { .init() }
}

// MARK: - VStackLayout [6.4.41]

/// A vertical container that you can use in conditional layouts.
///
/// This layout container behaves like a ``VStack``, but conforms to the
/// ``Layout`` protocol so you can use it in the conditional layouts that you
/// construct with ``AnyLayout``. If you don't need a conditional layout, use
/// ``VStack`` instead.
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct VStackLayout: Layout {
    /// The horizontal alignment of subviews.
    public var alignment: HorizontalAlignment

    /// The distance between adjacent subviews.
    ///
    /// Set this value to `nil` to use default distances between subviews.
    public var spacing: CGFloat?

    /// Creates a vertical stack with the specified spacing and horizontal
    /// alignment.
    ///
    /// - Parameters:
    ///     - alignment: The guide for aligning the subviews in this stack. It
    ///       has the same horizontal screen coordinate for all subviews.
    ///     - spacing: The distance between adjacent subviews. Set this value
    ///       to `nil` to use default distances between subviews.
    @inlinable
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    @available(OpenSwiftUI_v4_0, *)
    public typealias AnimatableData = EmptyAnimatableData

    @available(OpenSwiftUI_v4_0, *)
    public typealias Cache = _VStackLayout.Cache
}

extension VStackLayout: DerivedLayout {
    package var base: _VStackLayout {
        .init(alignment: alignment, spacing: spacing)
    }

    @available(OpenSwiftUI_v4_0, *)
    package typealias Base = _VStackLayout
}
