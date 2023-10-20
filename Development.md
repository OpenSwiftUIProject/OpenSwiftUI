# Development

## Reverse Engineer SwiftUI Tip

### Required Files

- SwiftUI framework
- AttributeGraph framework

eg. iOS Simulator

- SwiftUI

| category       | path                                                                                                                                                                                                                    |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| swiftinterface | /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64-apple-ios.swiftinterface |
| tbd            | /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/SwiftUI.framework/SwiftUI.tbd                                                |
| 15.5 binary    | /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 15.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/SwiftUI.framework/SwiftUI                                                               |
| 17.0 binary    | /Library/Developer/CoreSimulator/Volumes/iOS_21A328/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 17.0.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/SwiftUI.framework/SwiftUI            |

- AttributeGraph

| category    | path                                                                                                                                                                                                                              |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| tbd         | /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/PrivateFrameworks/AttributeGraph.framework/AttributeGraph.tbd                                     |
| 15.5 binary | /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 15.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AttributeGraph.framework/AttributeGraph                                                    |
| 17.0 binary | /Library/Developer/CoreSimulator/Volumes/iOS_21A328/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 17.0.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AttributeGraph.framework/AttributeGraph |

> If you do not have the SDK you'd like to investigate, you can also download the swiftinterface file or tbd file from the Internet eg. https://github.com/xybp888/iOS-SDKs

### Tools

- Hopper Disassembler
    - Analysze binary of SwiftUI and AttributeGraph

- swift-reflection-dump
    - Produce swiftui-reflection-dump.txt to simplify our work
    > See https://gist.github.com/ole/7a08561a4258bd2f82a92bc21a7b2355

- ARM Instruction Reference
    - https://developer.arm.com/documentation/dui0068/latest/ARM-Instruction-Reference

## Other

Base implementation is aligned with Xcode 13.4.1
Base documentation is aligned with Xcode 15.0