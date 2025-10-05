# Model data

Manage the data that your app uses to drive its interface.

## Overview

OpenSwiftUI offers a declarative approach to user interface design. As you
compose a hierarchy of views, you also indicate data dependencies for the views.
When the data changes, either due to an external event or because of an action
that the user performs, OpenSwiftUI automatically updates the affected parts of
the interface. As a result, the framework automatically performs most of the
work that view controllers traditionally do.

![](https://docs-assets.developer.apple.com/published/7a8488351b0c9f662b694bc1153162a5/model-data-hero%402x.png)

The framework provides tools, like state variables and bindings, for connecting
your app’s data to the user interface. These tools help you maintain a single
source of truth for every piece of data in your app, in part by reducing the
amount of glue logic you write. Select the tool that best suits the task you
need to perform:

- Manage transient UI state locally within a view by wrapping value types as
``State`` properties.

- Share a reference to a source of truth, like local state, using the
``Binding`` property wrapper.

- Connect to and observe reference model data in views by applying the
``Observable()`` macro to the model data type. Instantiate an observable model
data type directly in a view using a ``State`` property. Share the observable
model data with other views in the hierarchy without passing a reference using
the ``Environment`` property wrapper.

## Leveraging property wrappers

OpenSwiftUI implements many data management types, like ``State`` and
``Binding``, as Swift property wrappers. Apply a property wrapper by adding an
attribute with the wrapper’s name to a property’s declaration.

```swift
@State private var isVisible = true // Declares isVisible as a state variable.
```

The property gains the behavior that the wrapper specifies. The state and data
flow property wrappers in OpenSwiftUI watch for changes in your data, and
automatically update affected views as necessary. When you refer directly to the
property in your code, you access the wrapped value, which for the `isVisible`
state property in the example above is the stored Boolean.

```swift
if isVisible == true {
    Text("Hello") // Only renders when isVisible is true.
}
```

Alternatively, you can access a property wrapper’s projected value by prefixing
the property name with the dollar sign ($). OpenSwiftUI state and data flow
property wrappers project a ``Binding``, which is a two-way connection to the
wrapped value, allowing another view to access and mutate a single source of
truth.

```swift
Toggle("Visible", isOn: $isVisible) // The toggle can update the stored value.
```

For more information about property wrappers, see
[Property Wrappers](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Property-Wrappers)
in [The Swift Programming Language](https://www.swift.org/documentation/#the-swift-programming-language).

## Topics

### Creating and sharing view state

- <doc:managing-user-interface-state>
- ``State``
- ``Bindable``
- ``Binding``

### Creating model data

- <doc:managing-model-data-in-your-app>
- <doc:migrating-from-the-observable-object-protocol-to-the-observable-macro>
- ``Observable()``
- ``StateObject``
- ``ObservedObject``
- ``ObservableObject``

### Responding to data changes

- ``View/onChange(of:initial:_:)``
- ``View/onReceive(_:perform:)``

### Distributing model data throughout your app

- ``View/environmentObject(_:)``
- ``Scene/environmentObject(_:)``
- ``EnvironmentObject``

### Managing dynamic data

- ``DynamicProperty``
