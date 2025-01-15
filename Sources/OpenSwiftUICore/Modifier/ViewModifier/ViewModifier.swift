//
//  ViewModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 15.5
//  Status: Complete

/// A modifier that you apply to a view or another view modifier, producing a
/// different version of the original value.
///
/// Adopt the ``ViewModifier`` protocol when you want to create a reusable
/// modifier that you can apply to any view. The example below combines several
/// modifiers to create a new modifier that you can use to create blue caption
/// text surrounded by a rounded rectangle:
///
///     struct BorderedCaption: ViewModifier {
///         func body(content: Content) -> some View {
///             content
///                 .font(.caption2)
///                 .padding(10)
///                 .overlay(
///                     RoundedRectangle(cornerRadius: 15)
///                         .stroke(lineWidth: 1)
///                 )
///                 .foregroundColor(Color.blue)
///         }
///     }
///
/// You can apply ``View/modifier(_:)`` directly to a view, but a more common
/// and idiomatic approach uses ``View/modifier(_:)`` to define an extension to
/// ``View`` itself that incorporates the view modifier:
///
///     extension View {
///         func borderedCaption() -> some View {
///             modifier(BorderedCaption())
///         }
///     }
///
/// You can then apply the bordered caption to any view, similar to this:
///
///     Image(systemName: "bus")
///         .resizable()
///         .frame(width:50, height:50)
///     Text("Downtown Bus")
///         .borderedCaption()
///
/// ![A screenshot showing the image of a bus with a caption reading
/// Downtown Bus. A view extension, using custom a modifier, renders the
///  caption in blue text surrounded by a rounded
///  rectangle.](OpenSwiftUI-View-ViewModifier.png)
@MainActor
@preconcurrency
public protocol ViewModifier {
    /// Makes a new view using the view modifier and inputs that you provide.
    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs

    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs

    /// The number of views that `_makeViewList()` would produce, or
    /// nil if unknown.
    nonisolated static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int?
    
    /// The type of view representing the body.
    associatedtype Body: View
    
    /// Gets the current body of the caller.
    ///
    /// `content` is a proxy for the view that will have the modifier
    /// represented by `Self` applied to it.
    @ViewBuilder
    func body(content: Content) -> Body
    
    /// The content view type passed to `body()`.
    typealias Content = _ViewModifier_Content<Self>
}

package protocol PrimitiveViewModifier: ViewModifier where Body == Never {}

extension ViewModifier where Body == Never {
    public func body(content _: Content) -> Never {
        bodyError()
    }
    
    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

extension ViewModifier where Self: _GraphInputsModifier, Body == Never {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.withMutateGraphInputs { inputs in
            _makeInputs(modifier: modifier, inputs: &inputs)
        }
        let outputs = body(_Graph(), inputs)
        return outputs
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        inputs.withMutateGraphInputs { inputs in
            _makeInputs(modifier: modifier, inputs: &inputs)
        }
        let outputs = body(_Graph(), inputs)
        return outputs
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

extension ViewModifier {
    func bodyError() -> Never {
        preconditionFailure("body() should not be called on \(Self.self)")
    }
}

extension ViewModifier {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeViewList(modifier: modifier, inputs: inputs, body: body)
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        viewListCount(inputs: inputs, body: body)
    }
}
