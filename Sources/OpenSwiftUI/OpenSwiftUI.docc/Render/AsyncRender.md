# Async Rendering in UIKit Integration

Understand how OpenSwiftUI performs asynchronous rendering when hosted in UIKit views.

## Overview

OpenSwiftUI can perform view graph updates and display list rendering on a background thread to improve frame rates and reduce main thread blocking. This async rendering capability is particularly important for smooth animations.

## Architecture

The async rendering pipeline involves several key components:

1. DisplayLink: Manages the render loop and switches between main thread and async thread rendering
2. ViewGraph: Provides `updateOutputsAsync` to update the view graph on a background thread
3. UIHostingViewBase: Coordinates the rendering process and manages the display link
4. ViewRendererHost: Protocol that provides `render` and `renderAsync` methods

## How Async Rendering Works

### The Rendering Flow

When a view needs to update, the following sequence occurs:

1. `DisplayLink` fires on a CADisplayLink callback
2. `UIHostingViewBase.displayLinkTimer` is called with the current timestamp
3. If `isAsyncThread` is true, `ViewRendererHost.renderAsync` is invoked
4. `ViewGraph.updateOutputsAsync` attempts to update outputs on the async thread
5. If successful, the display list is rendered asynchronously
6. If async update fails, rendering falls back to the main thread

### The Async Thread

OpenSwiftUI creates a dedicated async rendering thread:

    thread.name = "org.OpenSwiftUIProject.OpenSwiftUI.AsyncRenderer"
    thread.qualityOfService = .userInteractive

This thread runs a separate RunLoop and processes display link callbacks when async rendering is enabled.

## Conditions for Async Rendering

Async rendering is only possible when specific conditions are met. The `updateOutputsAsync` method checks:

    guard _rootDisplayList.allowsAsyncUpdate(),
          hostPreferenceValues.allowsAsyncUpdate(),
          sizeThatFitsObservers.isEmpty || _rootLayoutComputer.allowsAsyncUpdate()
    else {
        return nil
    }

### Key Requirements

1. hostPreferenceValues must be non-nil: This attribute is set during `instantiateOutputs` when the view contains dynamic containers like `ForEach` or conditional views (`if`/`else`)

2. Attributes must allow async updates: An attribute allows async update when its value state does not contain both `dirty` and `mainThread` flags

3. No pending properties needing update: The host's `propertiesNeedingUpdate` must be empty

4. No pending transactions: The view graph must not have pending transactions

### The hostPreferenceValues Requirement

The `hostPreferenceValues` is set during `ViewGraph.instantiateOutputs`:

    hostPreferenceValues = WeakAttribute(outputs.preferences[HostPreferencesKey.self])

This only works when the view hierarchy contains a `DynamicContainer`. Dynamic containers are created by:

- `ForEach` views
- Conditional content (`if`/`else` statements)
- Optional view unwrapping

Without these dynamic elements, `hostPreferenceValues` remains nil and `allowsAsyncUpdate()` returns false.

## Examples

### Views That Support Async Rendering

Views with dynamic content like `ForEach` enable async rendering:

    struct AsyncRenderExample: View {
        @State private var items = [6]

        var body: some View {
            VStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    Color.blue.opacity(Double(item) / 6.0)
                        .frame(height: 50)
                        .transition(.slide)
                }
            }
            .animation(.easeInOut(duration: 2), value: items)
            .onAppear {
                items.removeAll { $0 == 6 }
            }
        }
    }

In this example, the `ForEach` creates a `DynamicContainer`, which sets up the `hostPreferenceValues` attribute, enabling async rendering during the animation.

### Views That Cannot Use Async Rendering

Views without dynamic containers cannot use async rendering:

    struct NoAsyncRenderExample: View {
        @State private var showRed = false

        var body: some View {
            VStack {
                Color(platformColor: showRed ? .red : .blue)
                    .onAppear {
                        let animation = Animation.linear(duration: 5)
                            .logicallyComplete(after: 1)
                        withAnimation(animation, completionCriteria: .logicallyComplete) {
                            showRed.toggle()
                        } completion: {
                            print("Complete")
                        }
                    }
            }
        }
    }

This view has no `ForEach` or conditional view structure. The color interpolation happens within a single view, so no `DynamicContainer` is created and `hostPreferenceValues` remains nil.

## Debugging Tips

To understand why async rendering is not enabled:

1. Check if your view hierarchy contains `ForEach` or conditional views
2. Verify that animations are not using completion handlers that require main thread coordination
3. Use the environment variable `OPENSWIFTUI_PRINT_TREE=1` to inspect the display list structure

## Topics

### Related Types

- ``_UIHostingView``
- ``ViewGraph``

