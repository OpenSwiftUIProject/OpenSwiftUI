//
//  LayoutPriorityLayout.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

extension View {
    /// Sets the priority by which a parent layout should apportion space to
    /// this child.
    ///
    /// Views typically have a default priority of `0` which causes space to be
    /// apportioned evenly to all sibling views. Raising a view's layout
    /// priority encourages the higher priority view to shrink later when the
    /// group is shrunk and stretch sooner when the group is stretched.
    ///
    ///     HStack {
    ///         Text("This is a moderately long string.")
    ///             .font(.largeTitle)
    ///             .border(Color.gray)
    ///
    ///         Spacer()
    ///
    ///         Text("This is a higher priority string.")
    ///             .font(.largeTitle)
    ///             .layoutPriority(1)
    ///             .border(Color.gray)
    ///     }
    ///
    /// In the example above, the first ``Text`` element has the default
    /// priority `0` which causes its view to shrink dramatically due to the
    /// higher priority of the second ``Text`` element, even though all of their
    /// other attributes (font, font size and character count) are the same.
    ///
    /// ![A screenshot showing twoText views different layout
    /// priorities.](OpenSwiftUI-View-layoutPriority.png)
    ///
    /// A parent layout offers the child views with the highest layout priority
    /// all the space offered to the parent minus the minimum space required for
    /// all its lower-priority children.
    ///
    /// - Parameter value: The priority by which a parent layout apportions
    ///   space to the child.
    @inlinable
    nonisolated public func layoutPriority(_ value: Double) -> some View {
        _trait(LayoutPriorityTraitKey.self, value)
    }
}

@usableFromInline
package struct LayoutPriorityTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Double { .zero }
}

@available(*, unavailable)
extension LayoutPriorityTraitKey: Sendable {}

// FIXME
protocol UnaryLayout: ViewModifier {
    static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs
}

// FIXME
package struct LayoutPriorityLayout: UnaryLayout {
    static func makeViewImpl(modifier: _GraphValue<LayoutPriorityLayout>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
        .init()
    }
}
