public import Foundation

@frozen
public struct HStack<Content: View>: PrimitiveView {
    @inlinable
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        _tree = .init(
            root: _HStackLayout(alignment: alignment, spacing: spacing),
            content: content()
        )
    }

    @usableFromInline
    var _tree: _VariadicView.Tree<_HStackLayout, Content>

    public static func _makeView(view _: _GraphValue<HStack<Content>>, inputs _: _ViewInputs) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}
