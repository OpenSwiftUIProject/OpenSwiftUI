//
//  Bindable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenObservation
#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif

/// A property wrapper type that supports creating bindings to the mutable
/// properties of observable objects.
///
/// Use this property wrapper to create bindings to mutable properties of a
/// data model object that conforms to the
/// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
/// protocol. For example, the following code wraps the `book` input with
/// `@Bindable`. Then it uses a ``TextField`` to change the `title` property of
/// a book, and a ``Toggle`` to change the `isAvailable` property, using the
/// `$` syntax to pass a binding for each property to those controls.
///
///     @Observable
///     class Book: Identifiable {
///         var title = "Sample Book Title"
///         var isAvailable = true
///     }
///
///     struct BookEditView: View {
///         @Bindable var book: Book
///         @Environment(\.dismiss) private var dismiss
///
///         var body: some View {
///             Form {
///                 TextField("Title", text: $book.title)
///
///                 Toggle("Book is available", isOn: $book.isAvailable)
///
///                 Button("Close") {
///                     dismiss()
///                 }
///             }
///         }
///     }
///
/// You can use the `Bindable` property wrapper on properties and variables to
/// an [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
/// object. This includes global variables, properties that exists outside of
/// OpenSwiftUI types, or even local variables. For example, you can create a
/// `@Bindable` variable within a view's ``View/body-swift.property``:
///
///     struct LibraryView: View {
///         @State private var books = [Book(), Book(), Book()]
///
///         var body: some View {
///             List(books) { book in
///                 @Bindable var book = book
///                 TextField("Title", text: $book.title)
///             }
///         }
///     }
///
/// The `@Bindable` variable `book` provides a binding that connects
/// ``TextField`` to the `title` property of a book so that a person can make
/// changes directly to the model data.
///
/// Use this same approach when you need a binding to a property of an
/// observable object stored in a view's environment. For example, the
/// following code uses the ``Environment`` property wrapper to retrieve an
/// instance of the observable type `Book`. Then the code creates a `@Bindable`
/// variable `book` and passes a binding for the `title` property to a
/// ``TextField`` using the `$` syntax.
///
///     struct TitleEditView: View {
///         @Environment(Book.self) private var book
///
///         var body: some View {
///             @Bindable var book = book
///             TextField("Title", text: $book.title)
///         }
///     }
///
@available(OpenSwiftUI_v4_0, *)
@dynamicMemberLookup
@propertyWrapper
public struct Bindable<Value> {

    /// The wrapped object.
    public var wrappedValue: Value

    /// The bindable wrapper for the object that creates bindings to its
    /// properties using dynamic member lookup.
    public var projectedValue: Bindable<Value> { self }

    @available(*, unavailable, message: "The wrapped value must be an object that conforms to Observable")
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    @available(*, unavailable, message: "The wrapped value must be an object that conforms to Observable")
    public init(projectedValue: Bindable<Value>) {
        self.wrappedValue = projectedValue.wrappedValue
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Bindable where Value: AnyObject {

    /// Returns a binding to the value of a given key path.
    public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>) -> Binding<Subject> {
        Binding(wrappedValue, keyPath: keyPath)
    }
}

extension Bindable where Value: ObservableObject {

    @available(*, unavailable, message: "@Bindable only works with Observable types. For ObservableObject types, use @ObservedObject instead.")
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Bindable where Value: AnyObject, Value: Observable {

    /// Creates a bindable object from an observable object.
    ///
    /// You should not call this initializer directly. Instead, declare a
    /// property with the `@Bindable` attribute, and provide an initial value.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    /// Creates a bindable object from an observable object.
    ///
    /// This initializer is equivalent to ``init(wrappedValue:)``, but is more
    /// succinct when when creating bindable objects nested within other
    /// expressions. For example, you can use the initializer to create a
    /// bindable object inline with code that declares a view that takes a
    /// binding as a parameter:
    ///
    ///     struct TitleEditView: View {
    ///         @Environment(Book.self) private var book
    ///
    ///         var body: some View {
    ///             TextField("Title", text: Bindable(book).title)
    ///         }
    ///     }
    ///
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    /// Creates a bindable from the value of another bindable.
    public init(projectedValue: Bindable<Value>) {
        self.wrappedValue = projectedValue.wrappedValue
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Bindable: Identifiable where Value: Identifiable {
    public var id: Value.ID {
        wrappedValue.id
    }
}

@available(OpenSwiftUI_v4_0, *)
extension Bindable: Sendable where Value: Sendable {}
