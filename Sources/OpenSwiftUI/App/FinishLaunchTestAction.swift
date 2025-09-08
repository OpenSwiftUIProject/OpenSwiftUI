//
//  FinishLaunchTestAction.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct FinishLaunchTestAction {
    func callAsFunction() {
        AppGraph.shared?.stopProfilingIfNecessary()
        #if os(iOS) || os(visionOS)
        UIApplication.shared.finishedTest(UIApplication.shared._launchTestName())
        #else
        preconditionFailure("Unimplemented for other platform")
        #endif
    }
}

extension EnvironmentValues {
    var finishLaunchTest: FinishLaunchTestAction {
        FinishLaunchTestAction()
    }
}
