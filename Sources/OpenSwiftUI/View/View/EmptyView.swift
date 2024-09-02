//
//  EmptyView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

/// A view that doesn't contain any content.
///
/// You will rarely, if ever, need to create an `EmptyView` directly. Instead,
/// `EmptyView` represents the absence of a view.
///
/// OpenSwiftUI uses `EmptyView` in situations where an OpenSwiftUI view type defines one
/// or more child views with generic parameters, and allows the child views to
/// be absent. When absent, the child view's type in the generic type parameter
/// is `EmptyView`.
///
/// The following example creates an indeterminate ``ProgressView`` without
/// a label. The ``ProgressView`` type declares two generic parameters,
/// `Label` and `CurrentValueLabel`, for the types used by its subviews.
/// When both subviews are absent, like they are here, the resulting type is
/// `ProgressView<EmptyView, EmptyView>`, as indicated by the example's output:
///
///     let progressView = ProgressView()
///     print("\(type(of:progressView))")
///     // Prints: ProgressView<EmptyView, EmptyView>
///
@frozen
public struct EmptyView: PrimitiveView {
    /// Creates an empty view.
    @inlinable
    public init() {}
    
    public static func _makeView(view: _GraphValue<EmptyView>, inputs: _ViewInputs) -> _ViewOutputs {
        _ViewOutputs()
    }
    
    public static func _makeViewList(view: _GraphValue<EmptyView>, inputs: _ViewListInputs) -> _ViewListOutputs {
        guard inputs.options.contains(.isNonEmptyParent) else {
            return _ViewListOutputs.emptyParentViewList(inputs: inputs)
        }
        return _ViewListOutputs.nonEmptyParentViewList(inputs: inputs)
    }
    
    public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        0
    }
}
