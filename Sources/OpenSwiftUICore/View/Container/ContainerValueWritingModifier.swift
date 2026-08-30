//
//  ContainerValueWritingModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C5395F2C967F1B7CF8C524BFF68CD054 (SwiftUICore)

import OpenAttributeGraphShims

@available(OpenSwiftUI_v6_0, *)
extension View {
    /// Sets a particular container value of a view.
    ///
    /// Use this modifier to set one of the writable properties of the
    /// ``ContainerValues`` structure, including custom values that you
    /// create.
    ///
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
    /// The container values modifier can also be used to modify mutable
    /// subfields of container values.
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
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the
    ///     ``ContainerValues`` structure to update.
    ///   - value: The new value to set for the item specified by `keyPath`.
    ///
    /// - Returns: A view that has the given value set in its containerValues.
    @_alwaysEmitIntoClient
    nonisolated public func containerValue<V>(
        _ keyPath: WritableKeyPath<ContainerValues, V>,
        _ value: V
    ) -> some View {
        modifier(_ContainerValueWritingModifier(keyPath: keyPath, value: value))
    }
}

/// A modifier that sets a value for a container value key path.
@available(OpenSwiftUI_v6_0, *)
@frozen
public struct _ContainerValueWritingModifier<Value>: PrimitiveViewModifier {
    /// The container value keyPath to set.
    public var keyPath: WritableKeyPath<ContainerValues, Value>

    /// The container value to set for `keyPath`.
    public var value: Value

    @_alwaysEmitIntoClient
    public init(
        keyPath: WritableKeyPath<ContainerValues, Value>,
        value: Value
    ) {
        self.keyPath = keyPath
        self.value = value
    }

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
        var newInputs = inputs
        let addTrait = AddTrait(
            modifier: modifier.value,
            traits: OptionalAttribute(inputs.traits)
        )
        newInputs.traits = Attribute(addTrait)
        return body(_Graph(), newInputs)
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }

    private struct AddTrait: Rule, AsyncAttribute {
        @Attribute var modifier: _ContainerValueWritingModifier
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: ViewTraitCollection {
            var values = ContainerValues(base: traits ?? ViewTraitCollection())
            values[keyPath: modifier.keyPath] = modifier.value
            return values.base
        }
    }
}

@available(*, unavailable)
extension _ContainerValueWritingModifier: Sendable {}
