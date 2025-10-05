# Managing user interface state

Encapsulate view-specific data within your app’s view hierarchy to make your
views reusable.

## Overview

Store data as state in the least common ancestor of the views that need the data
to establish a single source of truth that’s shared across views. Provide the
data as read-only through a Swift property, or create a two-way connection to
the state with a binding. OpenSwiftUI watches for changes in the data, and
updates any affected views as needed.

![](https://docs-assets.developer.apple.com/published/c75c698bd113a4ac7c708e178f8294ca/managing-user-interface-state%402x.png)

Don’t use state properties for persistent storage because the life cycle of
state variables mirrors the view life cycle. Instead, use them to manage
transient state that only affects the user interface, like the highlight state
of a button, filter settings, or the currently selected list item. You might
also find this kind of storage convenient while you prototype, before you’re
ready to make changes to your app’s data model.

### Manage mutable values as state

If a view needs to store data that it can modify, declare a variable with the
``State`` property wrapper. For example, you can create an isPlaying Boolean inside 
a podcast player view to keep track of when a podcast is running:

```
struct PlayerView: View {
    @State private var isPlaying: Bool = false
    
    var body: some View {
        // ...
    }
}
```

Marking the property as state tells the framework to manage the underlying
storage. Your view reads and writes the data, found in the state’s
``wrappedValue`` property, by using the property name. When you change the
value, OpenSwiftUI updates the affected parts of the view. For example, you can
add a button to the PlayerView that toggles the stored value when tapped, and
that displays a different image depending on the stored value:

```
Button(action: {
    self.isPlaying.toggle()
}) {
    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
}
```

Limit the scope of state variables by declaring them as private. This ensures
that the variables remain encapsulated in the view hierarchy that declares them.

### Declare Swift properties to store immutable values

To provide a view with data that the view doesn’t modify, declare a standard
Swift property. For example, you can extend the podcast player to have an input
structure that contains strings for the episode title and the show name:

```
struct PlayerView: View {
    let episode: Episode // The queued episode.
    @State private var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            // Display information about the episode.
            Text(episode.title)
            Text(episode.showTitle)


            Button(action: {
                self.isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
            }
        }
    }
}
```

While the value of the episode property is a constant for PlayerView, it doesn’t
need to be constant in this view’s parent view. When the user selects a
different episode in the parent, OpenSwiftUI detects the state change and
recreates the PlayerView with a new input.

### Share access to state with bindings

If a view needs to share control of state with a child view, declare a property
in the child with the ``Binding`` property wrapper. A binding represents a
reference to existing storage, preserving a single source of truth for the
underlying data. For example, if you refactor the podcast player view’s button
into a child view called PlayButton, you can give it a binding to the isPlaying
property:

```
struct PlayButton: View {
    @Binding var isPlaying: Bool
    
    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
        }
    }
}
```

As shown above, you read and write the binding’s wrapped value by referring
directly to the property, just like state. But unlike a state property, the
binding doesn’t have its own storage. Instead, it references a state property
stored somewhere else, and provides a two-way connection to that storage.

When you instantiate PlayButton, provide a binding to the corresponding state
variable declared in the parent view by prefixing it with the dollar sign ($):

```
struct PlayerView: View {
    var episode: Episode
    @State private var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            Text(episode.title)
            Text(episode.showTitle)
            PlayButton(isPlaying: $isPlaying) // Pass a binding.
        }
    }
}
```

The $ prefix asks a wrapped property for its projectedValue, which for state is 
a binding to the underlying storage. Similarly, you can get a binding from a
binding using the $ prefix, allowing you to pass a binding through an arbitrary
number of levels of view hierarchy.

You can also get a binding to a scoped value within a state variable. For
example, if you declare episode as a state variable in the player’s parent view,
and the episode structure also contains an isFavorite Boolean that you want to
control with a toggle, then you can refer to $episode.isFavorite to get a
binding to the episode’s favorite status:

```
struct Podcaster: View {
    @State private var episode = Episode(title: "Some Episode",
                                         showTitle: "Great Show",
                                         isFavorite: false)
    var body: some View {
        VStack {
            Toggle("Favorite", isOn: $episode.isFavorite) // Bind to the Boolean.
            PlayerView(episode: episode)
        }
    }
}
```

### Animate state transitions

When the view state changes, OpenSwiftUI updates affected views right away. If
you want to smooth visual transitions, you can tell SwiftUI to animate them by
wrapping the state change that triggers them in a call to the
``withAnimation(_:_:)`` function. For example, you can animate changes
controlled by the isPlaying Boolean:

```
withAnimation(.easeInOut(duration: 1)) {
    self.isPlaying.toggle()
}
```

By changing isPlaying inside the animation function’s trailing closure, you tell
OpenSwiftUI to animate anything that depends on the wrapped value, like a scale
effect on the button’s image:

```
Image(systemName: isPlaying ? "pause.circle" : "play.circle")
    .scaleEffect(isPlaying ? 1 : 1.5)
```

OpenSwiftUI transitions the scale effect input over time between the given
values of 1 and 1.5, using the curve and duration that you specify, or
reasonable default values if you provide none. On the other hand, the image
content isn’t affected by the animation, even though the same Boolean dictates
which system image to display. That’s because OpenSwiftUI can’t incrementally
transition in a meaningful way between the two strings `pause.circle` and
`play.circle`.

You can add animation to a state property, or as in the above example, to a 
binding. Either way, OpenSwiftUI animates any view changes that happen when the
underlying stored value changes. For example, if you add a background color to 
the PlayerView — at a level of view hierarchy above the location of the 
animation block — OpenSwiftUI animates that as well:

```
VStack {
    Text(episode.title)
    Text(episode.showTitle)
    PlayButton(isPlaying: $isPlaying)
}
.background(isPlaying ? Color.green : Color.red) // Transitions with animation.
```

When you want to apply animations to specific views, rather than across all 
views triggered by a change in state, use the ``View/animation(_:value:)`` view 
modifier instead.
