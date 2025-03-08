//
//  View.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 1ABF77B82C037C602A176AE349787FED (SwiftUICore)

import OpenSwiftUI_SPI

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
@preconcurrency
@MainActor
public protocol View {
    /// Instantiates the view using `view` as its source value, and
    /// `inputs` as its input values. Returns the view's output values.
    /// This should never be called directly, instead use the
    /// makeDebuggableView() shim function.
    nonisolated static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs
    
    nonisolated static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs
    
    /// The number of views that `_makeViewList()` would produce, or
    /// nil if unknown.
    nonisolated static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
    
    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required ``View/body-swift.property`` property.
    associatedtype Body: View
    
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
    @MainActor
    @preconcurrency
    var body: Self.Body { get }
}

// MARK: - PrimitiveView

package protocol PrimitiveView: View {}

extension PrimitiveView {
    public var body: Never {
        bodyError()
    }
}

extension View {
    package func bodyError() -> Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

// MARK: - UnaryView

package protocol UnaryView: View {}

extension UnaryView {
    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        _ViewListOutputs.unaryViewList(view: view, inputs: inputs)
    }
    
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        1
    }
}

// MARK: - MultiView

package protocol MultiView: View {}

extension MultiView {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        makeImplicitRoot(view: view, inputs: inputs)
    }
    
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        nil
    }
}

// MARK: - _UnaryViewAdaptor

/// Shim to turn a view that may implement _makeViewList() into a
/// single view.
@frozen
public struct _UnaryViewAdaptor<Content>: View, UnaryView, PrimitiveView where Content : View {
    public var content: Content

    @inlinable
    public init(_ content: Content) {
        self.content = content
    }

    package init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        Content.makeDebuggableView(view: view[offset: { .of(&$0.content)} ], inputs: inputs)
    }
}

@available(*, unavailable)
extension _UnaryViewAdaptor: Sendable {}

// MARK: - ViewVisitor

package protocol ViewVisitor {
    mutating func visit<V>(_ view: V) where V: View
}

// MARK: - ViewTypeVisitor

package protocol ViewTypeVisitor {
    mutating func visit<V>(type: V.Type) where V: View
}

// MARK: - ViewDescriptor

package struct ViewDescriptor: TupleDescriptor, ConditionalProtocolDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<ViewDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_viewProtocolDescriptor()
    }

    private static var conditionalCache: [ObjectIdentifier: ConditionalTypeDescriptor<ViewDescriptor>] = [:]

    package static func fetchConditionalType(key: ObjectIdentifier) -> ConditionalTypeDescriptor<ViewDescriptor>? {
        conditionalCache[key]
    }

    package static func insertConditionalType(key: ObjectIdentifier, value: ConditionalTypeDescriptor<ViewDescriptor>) {
        conditionalCache[key] = value
    }
}

// MARK: - TypeConformance + ViewDescriptor

extension TypeConformance where P == ViewDescriptor {
    package func visitType<V>(visitor: UnsafeMutablePointer<V>) where V: ViewTypeVisitor {
        visitor.pointee.visit(type: unsafeBitCast(self, to: (any View.Type).self))
    }
}
