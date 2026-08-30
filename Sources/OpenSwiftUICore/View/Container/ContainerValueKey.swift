//
//  ContainerValueKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// A key for accessing container values.
///
/// You can create custom container values by extending the
/// ``ContainerValues`` structure with new properties.
/// First declare a new container value key type and specify a value for the
/// required ``defaultValue`` property:
///
///     private struct MyContainerValueKey: ContainerValueKey {
///         static let defaultValue: String = "Default value"
///     }
///
/// The Swift compiler automatically infers the associated ``Value`` type as the
/// type you specify for the default value. Then use the key to define a new
/// container value property:
///
///     extension ContainerValues {
///         var myCustomValue: String {
///             get { self[MyContainerValueKey.self] }
///             set { self[MyContainerValueKey.self] = newValue }
///         }
///     }
///
/// Clients of your container value never use the key directly.
/// Instead, they use the key path of your custom container value property.
/// To set the container value for a view, add the
/// ``View/containerValue(_:_:)`` view modifier to that view:
///
///     MyView()
///         .containerValue(\.myCustomValue, "Another string")
///
/// As a convenience, you can also define a dedicated view modifier to
/// apply this container value:
///
///     extension View {
///         func myCustomValue(_ myCustomValue: String) -> some View {
///             containerValue(\.myCustomValue, myCustomValue)
///     }
///
/// This improves clarity at the call site:
///
///     MyView()
///         .myCustomValue("Another string")
///
/// To read the container value, use `Group(subviews:)` on a containing
/// view, and then access the container value on members of that
/// collection.
///
///     @ViewBuilder var content: some View {
///         Text("A").myCustomValue("Hello")
///         Text("B").myCustomValue("World")
///     }
///
///     Group(subviews: content) { subviews in
///         ForEach(subviews) { subview in
///             Text(subview.containerValues.myCustomValue)
///         }
///     }
///
/// In practice, this will mostly be used by views that contain multiple other
/// views to extract information from their subviews. You could turn the example
/// above into such a container view as follows:
///
///     struct MyContainer<Content: View>: View {
///         var content: Content
///
///         init(@ViewBuilder content: () -> Content) {
///             self.content = content()
///         }
///
///         var body: some View {
///             Group(subviews: content) { subviews in
///                 ForEach(subviews) { subview in
///                     // Display each view side-by-side with its custom value.
///                     HStack {
///                         subview
///                         Text(subview.containerValues.myCustomValue)
///                     }
///                 }
///             }
///         }
///     }
///
@available(OpenSwiftUI_v6_0, *)
public protocol ContainerValueKey {
    /// The type of value produced by the container value.
    associatedtype Value

    /// The default value of the container value.
    static var defaultValue: Value { get }
}

package struct ContainerValueViewTraitKey<Key>: _ViewTraitKey where Key: ContainerValueKey {
    package static var defaultValue: Key.Value {
        Key.defaultValue
    }
}
