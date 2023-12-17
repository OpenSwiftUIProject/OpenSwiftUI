# System events

React to system events, like opening a URL.

## Overview

Specify view and scene modifiers to indicate how your app responds to certain
system events. For example, you can use the ``onOpenURL(perform:)`` view
modifier to define an action to take when your app receives a universal link,
or use the ``backgroundTask(_:action:)`` scene modifier to specify an
asynchronous task to carry out in response to a background task event, like the 
completion of a background URL session.

## Topics

### Handling URLs

- ``OpenURLAction``
