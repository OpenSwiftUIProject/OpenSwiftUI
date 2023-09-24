# Reverse Engineer SwiftUI Tip

## Required Files

- SwiftUI framework
- AttributeGraph framework

eg. iOS + SwiftUI
Interface File: /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64-apple-ios.swiftinterface
Binary File: /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/SwiftUI.framework/SwiftUI

## Tools

- Hopper Disassembler
    - Analysze binary of SwiftUI and AttributeGraph

- swift-reflection-dump
    - Produce swiftui-reflection-dump.txt to simplify our work
    > See https://gist.github.com/ole/7a08561a4258bd2f82a92bc21a7b2355

- ARM Instruction Reference
    - https://developer.arm.com/documentation/dui0068/latest/ARM-Instruction-Reference