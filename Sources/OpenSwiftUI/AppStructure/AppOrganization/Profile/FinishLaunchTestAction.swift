//
//  FinishLaunchTestAction.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/25.
//  Lastest Version: iOS 15.5
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
