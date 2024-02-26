//
//  FinishLaunchTestAction.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct FinishLaunchTestAction {
    func callAsFunction() {
        AppGraph.shared?.stopProfilingIfNecessary()
        #if os(iOS)
        UIApplication.shared.finishedTest(UIApplication.shared._launchTestName())
        #else
        fatalError("Unimplemented for other platform")
        #endif
    }
}

extension EnvironmentValues {
    var finishLaunchTest: FinishLaunchTestAction {
        FinishLaunchTestAction()
    }
}
