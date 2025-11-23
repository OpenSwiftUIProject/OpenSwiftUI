//
//  FinishLaunchTestAction.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
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
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
}

extension EnvironmentValues {
    var finishLaunchTest: FinishLaunchTestAction {
        FinishLaunchTestAction()
    }
}
