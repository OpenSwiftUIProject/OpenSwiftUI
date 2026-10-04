//
//  AppIntentAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import Foundation
import OpenSwiftUICore
#if OPENSWIFTUI_SWIFT_LOG
import Logging
#else
import os.log
#endif

// MARK: - AppIntentAction [TODO]

struct AppIntentAction {
    @Environment(\.appIntentExecutor) private var appIntentExecutor
    var lnAction: NSObject
    var defaultExecutor: @MainActor () -> Void

    static let logger = Logger(subsystem: "org.openswiftuiproject.openswiftui", category: "appintent")
}

// MARK: - AppIntentExecutor

struct AppIntentExecutor {
    let perform: @MainActor (NSObject) -> Void

    struct Key: EnvironmentKey {
        static let defaultValue: AppIntentExecutor? = nil
    }
}

extension EnvironmentValues {
    var appIntentExecutor: AppIntentExecutor? {
        get { self[AppIntentExecutor.Key.self] }
        set { self[AppIntentExecutor.Key.self] = newValue }
    }
}
