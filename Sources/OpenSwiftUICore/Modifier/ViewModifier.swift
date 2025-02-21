//
//  ViewModifier.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenGraphShims

// MARK: - ViewModifier

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

// MARK: - PrimitiveViewModifier

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

extension ViewModifier {
    func bodyError() -> Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

// MARK: - UnaryViewModifier

package protocol UnaryViewModifier: ViewModifier {}

extension UnaryViewModifier {
    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeUnaryViewList(modifier: modifier, inputs: inputs, body: body)
    }

    nonisolated static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        1
    }
}

// MARK: - MultiViewModifier

package protocol MultiViewModifier: ViewModifier {}

extension MultiViewModifier {
    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeMultiViewList(modifier: modifier, inputs: inputs, body: body)
    }
}

// MARK: - ViewModifier + _GraphInputsModifier

extension ViewModifier where Self: _GraphInputsModifier, Body == Never {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        _makeInputs(modifier: modifier, inputs: &inputs.base)
        return body(_Graph(), inputs)
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        _makeInputs(modifier: modifier, inputs: &inputs.base)
        return body(_Graph(), inputs)
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

// MARK: - ViewInputsModifier

package protocol ViewInputsModifier: ViewModifier where Body == Never {
    static var graphInputsSemantics: Semantics? { get }
    nonisolated static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs)
}

extension ViewInputsModifier {
    package static var graphInputsSemantics: Semantics? {
        nil
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var viewInputs = inputs
        _makeViewInputs(modifier: modifier, inputs: &viewInputs)
        return body(_Graph(), viewInputs)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        guard let graphInputsSemantics, isLinkedOnOrAfter(graphInputsSemantics) else {
            return makeMultiViewList(modifier: modifier, inputs: inputs, body: body)
        }
        var viewInputs = _ViewInputs.invalidInputs(inputs.base)
         _makeViewInputs(modifier: modifier, inputs: &viewInputs)
        var viewListInputs = inputs
        viewListInputs.base = viewInputs.base
        return body(_Graph(), viewListInputs)
    }

    /// The number of views that `_makeViewList()` would produce, or
    /// nil if unknown.
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

// MARK: - ViewModifier + makeViewList extension

extension ViewModifier {
    nonisolated package static func makeUnaryViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let weakModifier = WeakAttribute(modifier.value)
        return .unaryViewList(
            viewType: Self.self,
            inputs: inputs
        ) { viewInputs in
            guard let attribute = weakModifier.attribute else {
                return _ViewOutputs()
            }
            return makeImplicitRoot(
                modifier: _GraphValue(attribute),
                inputs: viewInputs,
                body: body
            )
        }
    }

    nonisolated package static func makeMultiViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var outputs = body(_Graph(), inputs)
        outputs.multiModifier(modifier, inputs: inputs)
        return outputs
    }
}

// MARK: - EmptyModifier

/// An empty, or identity, modifier, used during development to switch
/// modifiers at compile time.
///
/// Use the empty modifier to switch modifiers at compile time during
/// development. In the example below, in a debug build the ``Text``
/// view inside `ContentView` has a yellow background and a red border.
/// A non-debug build reflects the default system, or container supplied
/// appearance.
///
///     struct EmphasizedLayout: ViewModifier {
///         func body(content: Content) -> some View {
///             content
///                 .background(Color.yellow)
///                 .border(Color.red)
///         }
///     }
///
///     struct ContentView: View {
///         var body: some View {
///             Text("Hello, World!")
///                 .modifier(modifier)
///         }
///
///         var modifier: some ViewModifier {
///             #if DEBUG
///                 return EmphasizedLayout()
///             #else
///                 return EmptyModifier()
///             #endif
///         }
///     }
///
@frozen
public struct EmptyModifier: PrimitiveViewModifier, ViewModifier {
    public static let identity = EmptyModifier()

    @inlinable
    public init() {}

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        body(_Graph(), inputs)
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

// MARK: - View + modifier

extension View {
    /// Applies a modifier to a view and returns a new view.
    ///
    /// Use this modifier to combine a ``View`` and a ``ViewModifier``, to
    /// create a new view. For example, if you create a view modifier for
    /// a new kind of caption with blue text surrounded by a rounded rectangle:
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
    /// You can use ``modifier(_:)`` to extend ``View`` to create new modifier
    /// for applying the `BorderedCaption` defined above:
    ///
    ///     extension View {
    ///         func borderedCaption() -> some View {
    ///             modifier(BorderedCaption())
    ///         }
    ///     }
    ///
    /// Then you can apply the bordered caption to any view:
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
    ///
    /// - Parameter modifier: The modifier to apply to this view.
    @inlinable
    nonisolated public func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        .init(content: self, modifier: modifier)
    }
}

// MARK: - ModifiedContent

/// A value with a modifier applied to it.
@frozen
public struct ModifiedContent<Content, Modifier> {
    public typealias Body = Never

    /// The content that the modifier transforms into a new view or new
    /// view modifier.
    public var content: Content

    /// The view modifier.
    public var modifier: Modifier

    /// A structure that the defines the content and modifier needed to produce
    /// a new view or view modifier.
    ///
    /// If `content` is a ``View`` and `modifier` is a ``ViewModifier``, the
    /// result is a ``View``. If `content` and `modifier` are both view
    /// modifiers, then the result is a new ``ViewModifier`` combining them.
    ///
    /// - Parameters:
    ///     - content: The content that the modifier changes.
    ///     - modifier: The modifier to apply to the content.
    @inlinable
    nonisolated public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

@available(*, unavailable)
extension ModifiedContent: Sendable {}

// MARK: - ModifiedContent + Equatable

extension ModifiedContent: Equatable where Content: Equatable, Modifier: Equatable {
    public static func == (a: ModifiedContent<Content, Modifier>, b: ModifiedContent<Content, Modifier>) -> Bool {
        a.content == b.content && a.modifier == b.modifier
    }
}

// MARK: - ModifiedContent + View

extension ModifiedContent: View where Content: View, Modifier: ViewModifier {
    public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        Modifier.makeDebuggableView(
            modifier: view[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) {
            Content.makeDebuggableView(
                view: view[offset: { .of(&$0.content) }],
                inputs: $1
            )
        }
    }

    public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        Modifier.makeDebuggableViewList(
            modifier: view[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) {
            Content.makeDebuggableViewList(
                view: view[offset: { .of(&$0.content) }],
                inputs: $1
            )
        }
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        Modifier._viewListCount(inputs: inputs) {
            Content._viewListCount(inputs: $0)
        }
    }

    public var body: Body {
        bodyError()
    }
}

// MARK: - ModifiedContent + ViewModifier

extension ModifiedContent: ViewModifier where Content: ViewModifier, Modifier: ViewModifier {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Modifier.makeDebuggableView(
            modifier: modifier[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) {
            Content.makeDebuggableView(
                modifier: modifier[offset: { .of(&$0.content) }],
                inputs: $1,
                body: body
            )
        }
    }

    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        Modifier.makeDebuggableViewList(
            modifier: modifier[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) {
            Content.makeDebuggableViewList(
                modifier: modifier[offset: { .of(&$0.content) }],
                inputs: $1,
                body: body
            )
        }
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        Modifier._viewListCount(inputs: inputs) {
            Content._viewListCount(inputs: $0, body: body)
        }
    }
}

// MARK: - ViewModifier + modifier

extension ViewModifier {
    /// Returns a new modifier that is the result of concatenating
    /// `self` with `modifier`.
    @inlinable
    nonisolated public func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        .init(content: self, modifier: modifier)
    }
}

// MARK: - ModifiedContent + CustomViewDebugReflectable

extension ModifiedContent: CustomViewDebugReflectable {
    package var customViewDebugMirror: Mirror? { nil }
}
