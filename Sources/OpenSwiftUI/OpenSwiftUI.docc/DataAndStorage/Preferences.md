# Preferences

Indicate configuration preferences from views to their container views.

## Overview

Whereas you use the environment to configure the subviews of a view, you use preferences to send configuration information from subviews toward their container. However, unlike configuration information that flows down a view hierarchy from one container to many subviews, a single container needs to reconcile potentially conflicting preferences flowing up from its many subviews.

When you use the ``OpenSwiftUI/PreferenceKey`` protocol to define a custom preference, you indicate how to merge preferences from multiple subviews. You can then set a value for the preference on a view using the ``OpenSwiftUI/View/preference(key:value:)`` view modifier. Many built-in modifiers, like ``OpenSwiftUI/View/navigationTitle(_:)``, rely on preferences to send configuration information to their container.

## Topics

### Setting preferences

- ``OpenSwiftUI/View/preference(key:value:)``
- ``OpenSwiftUI/View/transformPreference(_:_:)``

### Creating custom preferences

- ``OpenSwiftUI/PreferenceKey``
