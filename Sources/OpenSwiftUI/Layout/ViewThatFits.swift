//
//  ViewThatFits.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Blocked by Layout Computer
//  ID: F613AABF2A2A0496B46514894D5116C3 (SwiftUI)

public import OpenSwiftUICore

/// A view that adapts to the available space by providing the first
/// child view that fits.
///
/// `ViewThatFits` evaluates its child views in the order you provide them
/// to the initializer. It selects the first child whose ideal size on the
/// constrained axes fits within the proposed size. This means that you
/// provide views in order of preference. Usually this order is largest to
/// smallest, but since a view might fit along one constrained axis but not the
/// other, this isn't always the case. By default, `ViewThatFits` constrains
/// in both the horizontal and vertical axes.
///
/// The following example shows an `UploadProgressView` that uses `ViewThatFits`
/// to display the upload progress in one of three ways. In order, it attempts
/// to display:
///
/// * An ``HStack`` that contains a ``Text`` view and a ``ProgressView``.
/// * Only the `ProgressView`.
/// * Only the `Text` view.
///
/// The progress views are fixed to a 100-point width.
///
///     struct UploadProgressView: View {
///         var uploadProgress: Double
///
///         var body: some View {
///             ViewThatFits(in: .horizontal) {
///                 HStack {
///                     Text("\(uploadProgress.formatted(.percent))")
///                     ProgressView(value: uploadProgress)
///                         .frame(width: 100)
///                 }
///                 ProgressView(value: uploadProgress)
///                     .frame(width: 100)
///                 Text("\(uploadProgress.formatted(.percent))")
///             }
///         }
///     }
///
/// This use of `ViewThatFits` evaluates sizes only on the horizontal axis. The
/// following code fits the `UploadProgressView` to several fixed widths:
///
///     VStack {
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 200)
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 100)
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 50)
///     }
///
/// ![A vertical stack showing three expressions of progress, constrained by
/// the available horizontal space. The first line shows the text, 75%, and a
/// three-quarters-full progress bar. The second line shows only the progress
/// view. The third line shows only the text.](ViewThatFits-1)
@frozen
public struct ViewThatFits<Content>: View, UnaryView, PrimitiveView where Content: View {
    @usableFromInline
    var _tree: _VariadicView.Tree<_SizeFittingRoot, Content>

    /// Produces a view constrained in the given axes from one of several
    /// alternatives provided by a view builder.
    ///
    /// - Parameters:
    ///     - axes: A set of axes to constrain children to. The set may
    ///       contain ``Axis/horizontal``, ``Axis/vertical``, or both of these.
    ///       `ViewThatFits` chooses the first child whose size fits within the
    ///       proposed size on these axes. If `axes` is an empty set,
    ///       `ViewThatFits` uses the first child view. By default,
    ///       `ViewThatFits` uses both axes.
    ///     - content: A view builder that provides the child views for this
    ///       container, in order of preference. The builder chooses the first
    ///       child view that fits within the proposed width, height, or both,
    ///       as defined by `axes`.
    @inlinable
    public init(in axes: Axis.Set = [.horizontal, .vertical], @ViewBuilder content: () -> Content) {
        _tree = .init(_SizeFittingRoot(axes: axes)) { content() }
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        _VariadicView.Tree<_SizeFittingRoot, Content>.makeDebuggableView(
            view: view[offset: { .of(&$0._tree) }],
            inputs: inputs
        )
    }

    public typealias Body = Never
}
@available(*, unavailable)
extension ViewThatFits: Sendable {}

@frozen
public struct _SizeFittingRoot: _VariadicView.UnaryViewRoot {
    @usableFromInline
    var axes: Axis.Set

    @inlinable
    init(axes: Axis.Set) { self.axes = axes }

    nonisolated public static func _makeView(root: _GraphValue<Self>, inputs: _ViewInputs, body: (_Graph, _ViewInputs) -> _ViewListOutputs) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    public typealias Body = Never
}

// WIP
final package class SizeFittingState {

}

// Blocked by LayoutComputer
private struct SizeFittingLayoutComputer {
    struct Engine {}
}

package protocol PlatformViewThatFitsRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool

    static func makeRepresentation(inputs: _ViewInputs, state: SizeFittingState, outputs: inout _ViewOutputs)
}

extension _ViewInputs {
    package var requestedViewThatFitsRepresentation: (any PlatformViewThatFitsRepresentable.Type)? {
        get { base.requestedViewThatFitsRepresentation }
        set { base.requestedViewThatFitsRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct ViewThatFitsRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformViewThatFitsRepresentable.Type)?
    }

    package var requestedViewThatFitsRepresentation: (any PlatformViewThatFitsRepresentable.Type)? {
        get { self[ViewThatFitsRepresentationKey.self] }
        set { self[ViewThatFitsRepresentationKey.self] = newValue }
    }
}
