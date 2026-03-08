# README

## Pre-Requirements

Clone other components to the same directory of `OpenSwiftUI`

```shell
cd ..
git clone https://github.com/OpenSwiftUIProject/OpenAttributeGraph.git
git clone https://github.com/OpenSwiftUIProject/OpenRenderBox.git 
git clone https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git 
```

## Configure AttributeGraph Backend

Since OpenAttributeGraph is not yet completed, you need to configure an AG backend before building.

Use Apple's private AttributeGraph framework (Darwin only):

```shell
export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=1
```

Or use the Compute module:

```shell
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_USE_BINARY=1
```

## Example

A OpenSwiftUI/SwiftUI `App` lifecycle example.

- Choose `SwiftUIDebug` configuration to run with SwiftUI
- Choose `OpenSwiftUIDebug` configuration to run with OpenSwiftUI

## HostingExample

A UIKit/AppKit hosting example that manually sets up the application lifecycle and window using `UIHostingView` / `NSHostingView`.

- Choose `SwiftUIDebug` configuration to run with SwiftUI
- Choose `OpenSwiftUIDebug` configuration to run with OpenSwiftUI
