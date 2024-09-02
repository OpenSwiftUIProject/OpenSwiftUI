//
//  View.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

/// A type that represents part of your app's user interface and provides
/// modifiers that you use to configure views.
///
/// You create custom views by declaring types that conform to the `View`
/// protocol. Implement the required ``View/body-swift.property`` computed
/// property to provide the content for your custom view.
///
///     struct MyView: View {
///         var body: some View {
///             Text("Hello, World!")
///         }
///     }
///
/// Assemble the view's body by combining one or more of the built-in views
/// provided by OpenSwiftUI, like the ``Text`` instance in the example above, plus
/// other custom views that you define, into a hierarchy of views. For more
/// information about creating custom views, see <doc:Declaring-a-Custom-View>.
///
/// The `View` protocol provides a set of modifiers — protocol
/// methods with default implementations — that you use to configure
/// views in the layout of your app. Modifiers work by wrapping the
/// view instance on which you call them in another view with the specified
/// characteristics, as described in <doc:Configuring-Views>.
/// For example, adding the ``View/opacity(_:)`` modifier to a
/// text view returns a new view with some amount of transparency:
///
///     Text("Hello, World!")
///         .opacity(0.5) // Display partially transparent text.
///
/// The complete list of default modifiers provides a large set of controls
/// for managing views.
/// For example, you can fine tune <doc:View-Layout>,
/// add <doc:View-Accessibility> information,
/// and respond to <doc:View-Input-and-Events>.
/// You can also collect groups of default modifiers into new,
/// custom view modifiers for easy reuse.
@_typeEraser(AnyView)
public protocol View {
    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required ``View/body-swift.property`` property.
    associatedtype Body: View
    
    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs
    
    static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs
    
    static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
    
    /// The content and behavior of the view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that SwiftUI provides, plus other
    /// composite views that you've already defined:
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             Text("Hello, World!")
    ///         }
    ///     }
    ///
    /// For more information about composing views and a view hierarchy,
    /// see <doc:Declaring-a-Custom-View>.
    @ViewBuilder
    @MainActor(unsafe)
    var body: Self.Body { get }
}

extension View {
    /// Instantiates the view using `view` as its source value, and
    /// `inputs` as its input values. Returns the view's output values.
    /// This should never be called directly, instead use the
    /// makeDebuggableView() shim function.
    public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        makeView(view: view, inputs: inputs)
    }
    
    public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        makeViewList(view: view, inputs: inputs)
    }
    
    public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Body._viewListCount(inputs: inputs)
    }
}


// MARK: - Never + View

extension Never: View {
    public var body: Never { self }
}

extension View {
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
