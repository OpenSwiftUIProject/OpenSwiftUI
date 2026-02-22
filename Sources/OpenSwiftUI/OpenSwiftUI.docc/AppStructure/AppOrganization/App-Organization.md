# App organization

Define the entry point and top-level structure of your app.

## Overview

Describe your app’s structure declaratively, much like you declare a view’s
appearance. Create a type that conforms to the App protocol and use it to
enumerate the Scenes that represent aspects of your app’s user interface.

OpenSwiftUI enables you to write code that works across all of Apple’s
platforms, Linux and Windows. However, it also enables you to tailor your app to
the specific capabilities of each platform. For example, if you need to respond
to the callbacks that the system traditionally makes on a UIKit, AppKit, or
WatchKit app’s delegate, define a delegate object and instantiate it in your app
structure using an appropriate delegate adaptor property wrapper, like
``UIApplicationDelegateAdaptor``.

For platform-specific design guidance, see
 [Getting started](https://developer.apple.com/design/human-interface-guidelines/getting-started)
in the Human Interface Guidelines for Apple Platform and
[Windows Design Documentation](https://learn.microsoft.com/windows/apps/design)
for Windows.

## Topics

### Creating an app

- [UILaunchScreen](https://developer.apple.com/documentation/bundleresources/information-property-list/uilaunchscreen)
- [UILaunchScreens](https://developer.apple.com/documentation/bundleresources/information-property-list/uilaunchscreens)
- ``App``

### Targeting iOS and iPadOS

- ``UIApplicationDelegateAdaptor``

### Targeting macOS

- ``NSApplicationDelegateAdaptor``
