//
//  ContainerValues.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// A collection of container values associated with a given view.
///
/// OpenSwiftUI exposes a collection of values associated with each view in the
/// `ContainerValues` structure.
///
/// Container values you set on a given view affect only that view.
/// Like preferences, container values are able to be read by views above
/// the view they're set on. Unlike preferences, however, container values
/// don't have merging behavior because they don't escape their closest
/// container. In the following example, the container value is set
/// on the contained view, but is dropped when it reaches the containing
///  ``VStack``.
///
///     VStack {
///         Text("A")
///             .containerValue(\.myCustomValue, 1) // myCustomValue = 1
///         Text("B")
///             .containerValue(\.myCustomValue, 2) // myCustomValue = 2
///         // container values are unaffected by views that aren't containers:
///         Text("C")
///             .containerValue(\.myCustomValue, 3)
///             .padding() // myCustomValue = 3
///     } // myCustomValue = its default value, values do not escape the container
///
/// Even if a stack has only one child, container values still won't
/// be readable outside of the `VStack`. Container values don't escape a
/// container even if the container has only one child.
///
/// In this example, a direct subview writes a container value, allowing its
/// direct container view to read it back:
///
///     @ViewBuilder var content: some View {
///         Text("A")
///             .containerValue(\.myCustomValue, 1)
///     }
///
///     ForEach(subviews: content) { subview in
///         Text("value = \(subview.containerValues.myCustomValue)") // shows "value = 1"
///     }
///
/// However in the next example, the wrapping `VStack` means the `Text` view
/// is not a direct subview of the outer container, so that container cannot
/// read the changed value:
///
///     @ViewBuilder var containedContent: some View {
///         VStack {
///             Text("A")
///                 .containerValue(\.myCustomValue, 1)
///         }
///     }
///
///     ForEach(subviews: containedContent) { subviews in
///         Text("value = \(subview.containerValues.myCustomValue)") // shows the default value
///     }
///
/// Create a custom container value by declaring a new property
/// in an extension to the container values structure and applying
/// the ``Entry()`` macro to the variable declaration:
///
///     extension ContainerValues {
///         @Entry var myCustomValue: String = "Default value"
///     }
///
/// Clients of your value then access the value by reading it from the container
/// values collection of a ``Subview``.
///
/// Related pieces of container configuration can also be grouped under the same
/// container values key.
///
///     struct PinPosition {
///         var rotation: Double = 0
///         var xOffset: Int = 0
///     }
///
///     extension ContainerValues {
///         @Entry var pinPosition: PinPosition = .init()
///     }
///
///     // pinPosition.rotation = 0, pinPosition.xOffset = 3
///     Text("A").containerValue(\.pinPosition.xOffset, 3)
///
///     // pinPosition.rotation = 10, pinPosition.xOffset = 5
///     Text("B")
///         .containerValue(\.pinPosition.rotation, 10)
///         .containerValue(\.pinPosition.xOffset, 5)
///
/// This allows you to group multiple related container values into
/// structs while maintaining separate modifiers to write each value.
///
///     extension View {
///         func pinRotation(_ rotation: Double) -> some View {
///             containerValue(\.pinPosition.rotation, rotation)
///         }
///
///         func pinXOffset(_ xOffset: Int) -> some View {
///             containerValue(\.pinPosition.xOffset, xOffset)
///         }
///     }
///
@available(OpenSwiftUI_v6_0, *)
public struct ContainerValues {
    package var base: ViewTraitCollection

    package init(base: ViewTraitCollection) {
        self.base = base
    }

    /// Accesses the particular container value associated with a custom key.
    ///
    /// Create a custom container value by declaring a new property
    /// in an extension to the container values structure and applying
    /// the ``Entry()`` macro to the variable declaration:
    ///
    ///     extension ContainerValues {
    ///         @Entry var myCustomValue: String = "Default value"
    ///     }
    ///
    /// You use custom container values the same way you use system-provided
    /// values, setting a value with the ``View/containerValue(_:_:)`` view
    /// modifier, and reading values from a ``Subview`` provided by the
    /// `subviews` modifier. You can also provide a dedicated view modifier as a
    /// convenience for setting the value:
    ///
    ///     extension View {
    ///         func myCustomValue(_ myCustomValue: String) -> some View {
    ///             containerValue(\.myCustomValue, myCustomValue)
    ///         }
    ///     }
    ///
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: ContainerValueKey {
        get { base[ContainerValueViewTraitKey<Key>.self] }
        set { base[ContainerValueViewTraitKey<Key>.self] = newValue }
    }

    /// The tag value for the given type if the container values contains one.
    ///
    /// Tag values are set using the ``View/tag`` modifier.
    ///
    /// - Parameter type: The type to get the tag value for.
    /// - Returns: The tag value for the given type if the subview has one,
    ///   otherwise `nil`.
    public func tag<V>(for type: V.Type) -> V? where V: Hashable {
        base.tag(for: type)
    }

    /// Returns true if the container values contain a tag matching a given
    /// value.
    ///
    /// Tag values are set using the ``View/tag`` modifier.
    ///
    /// - Parameter tag: The tag value to check for.
    /// - Returns: If the container values has a tag matching the given value.
    public func hasTag<V>(_ tag: V) -> Bool where V: Hashable {
        base.tag(for: V.self) == tag
    }
}

@available(*, unavailable)
extension ContainerValues: Sendable {}
