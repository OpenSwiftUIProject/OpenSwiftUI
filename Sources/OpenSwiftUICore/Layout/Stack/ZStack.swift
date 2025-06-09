//
//  ZStack.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: WIP

public import Foundation

/// A view that overlays its subviews, aligning them in both axes.
///
/// The `ZStack` assigns each successive subview a higher z-axis value than
/// the one before it, meaning later subviews appear "on top" of earlier ones.
///
/// The following example creates a `ZStack` of 100 x 100 point ``Rectangle``
/// views filled with one of six colors, offsetting each successive subview
/// by 10 points so they don't completely overlap:
///
///     let colors: [Color] =
///         [.red, .orange, .yellow, .green, .blue, .purple]
///
///     var body: some View {
///         ZStack {
///             ForEach(0..<colors.count) {
///                 Rectangle()
///                     .fill(colors[$0])
///                     .frame(width: 100, height: 100)
///                     .offset(x: CGFloat($0) * 10.0,
///                             y: CGFloat($0) * 10.0)
///             }
///         }
///     }
///
/// ![Six squares of different colors, stacked atop each other, with a 10-point
/// offset in both the x and y axes for each layer so they can be
/// seen.](OpenSwiftUI-ZStack-offset-rectangles.png)
///
/// The `ZStack` uses an ``Alignment`` to set the x- and y-axis coordinates of
/// each subview, defaulting to a ``Alignment/center`` alignment. In the following
/// example, the `ZStack` uses a ``Alignment/bottomLeading`` alignment to lay
/// out two subviews, a red 100 x 50 point rectangle below, and a blue 50 x 100
/// point rectangle on top. Because of the alignment value, both rectangles
/// share a bottom-left corner with the `ZStack` (in locales where left is the
/// leading side).
///
///     var body: some View {
///         ZStack(alignment: .bottomLeading) {
///             Rectangle()
///                 .fill(Color.red)
///                 .frame(width: 100, height: 50)
///             Rectangle()
///                 .fill(Color.blue)
///                 .frame(width:50, height: 100)
///         }
///         .border(Color.green, width: 1)
///     }
///
/// ![A green 100 by 100 square containing two overlapping rectangles: on the
/// bottom, a red 100 by 50 rectangle, and atop it, a blue 50 by 100 rectangle.
/// The rectangles share their bottom left point with the containing green
/// square.](SwiftUI-ZStack-alignment.png)
///
/// > Note: If you need a version of this stack that conforms to the ``Layout``
/// protocol, like when you want to create a conditional layout using
/// ``AnyLayout``, use ``ZStackLayout`` instead.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct ZStack<Content>: View, UnaryView, PrimitiveView where Content: View {
    @usableFromInline
    package var _tree: _VariadicView.Tree<_ZStackLayout, Content>

    @inlinable
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        _tree = .init(_ZStackLayout(alignment: alignment)) { content() }
    }

    nonisolated public static func _makeView(
        view: _GraphValue<ZStack<Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _VariadicView.Tree.makePlatformSubstitutableView(
            view: view[offset: { .of(&$0._tree) }],
            inputs: inputs
        )
    }

    @available(OpenSwiftUI_v1_0, *)
    public typealias Body = Never
}

@available(*, unavailable)
extension ZStack: Sendable {}

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _ZStackLayout: _VariadicView.UnaryViewRoot, Animatable {
    public var alignment: Alignment

    @inlinable
    public init(alignment: Alignment = .center) {
        self.alignment = alignment
    }

    nonisolated public static func _makeView(
        root: _GraphValue<_ZStackLayout>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        CoreGlue.shared.makeLayoutView(
            root: root,
            inputs: inputs,
            body: body
        )
    }

    @available(OpenSwiftUI_v1_0, *)
    public typealias AnimatableData = EmptyAnimatableData

    @available(OpenSwiftUI_v1_0, *)
    public typealias Body = Never
}

@available(OpenSwiftUI_v4_0, *)
extension _ZStackLayout: Layout {
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = nil
        properties.isIdentityUnaryLayout = true
        return properties
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: _ZStackLayout.Subviews,
        cache: inout Void
    ) {
        preconditionFailure("TODO")
    }

    public func spacing(subviews: _ZStackLayout.Subviews, cache: inout Void) -> ViewSpacing {
        preconditionFailure("TODO")
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: _ZStackLayout.Subviews,
        cache: inout Void
    ) -> CGSize {
        preconditionFailure("TODO")
    }

    @available(OpenSwiftUI_v4_0, *)
    public typealias Cache = Void
}

extension _ZStackLayout: _VariadicView.ImplicitRoot {
    package static var implicitRoot: _ZStackLayout { .init() }
}

/// An overlaying container that you can use in conditional layouts.
///
/// This layout container behaves like a ``ZStack``, but conforms to the
/// ``Layout`` protocol so you can use it in the conditional layouts that you
/// construct with ``AnyLayout``. If you don't need a conditional layout, use
/// ``ZStack`` instead.
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct ZStackLayout: Layout {
    /// The alignment of subviews.
    public var alignment: Alignment

    /// Creates a stack with the specified alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack
    ///     on both the x- and y-axes.
    @inlinable
    public init(alignment: Alignment = .center) {
        self.alignment = alignment
    }

    @available(OpenSwiftUI_v4_0, *)
    public typealias AnimatableData = EmptyAnimatableData

    @available(OpenSwiftUI_v4_0, *)
    public typealias Cache = Void
}

extension ZStackLayout: DerivedLayout {
    package var base: _ZStackLayout {
        .init(alignment: alignment)
    }

    @available(OpenSwiftUI_v4_0, *)
    package typealias Base = _ZStackLayout
}
