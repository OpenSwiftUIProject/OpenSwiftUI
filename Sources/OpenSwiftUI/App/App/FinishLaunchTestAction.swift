//
//  FinishLaunchTestAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 71E21E30634D2453CAA80C5CA9EF3E2C (SwiftUI?)

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - App/Scene + extendedLaunchTestName

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
extension Scene {
    nonisolated public func extendedLaunchTestName(_ name: String?) -> some Scene {
        preference(
            key: ExtendedLaunchTestNameKey.self,
            value: name
        )
    }
}

extension AppGraph {
    func extendedLaunchTestName() -> String? {
        Update.ensure {
            preferenceValue(ExtendedLaunchTestNameKey.self)
        }
    }
}

// MARK: - FinishLaunchTestAction

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
public struct FinishLaunchTestAction {
    public func callAsFunction() {
        AppGraph.shared?.stopProfilingIfNecessary()
        #if os(iOS) || os(visionOS)
        UIApplication.shared.finishedTest(UIApplication.shared._launchTestName())
        #elseif os(macOS)
        NSApp.markAppLaunchComplete()
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }
}
@_spi(Private)
@available(*, unavailable)
extension FinishLaunchTestAction: Sendable {}

// MARK: - EnvironmentValues + FinishLaunchTestAction

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    public var finishLaunchTest: FinishLaunchTestAction {
        FinishLaunchTestAction()
    }
}

// MARK: - ExtendedLaunchTestNameKey

private struct ExtendedLaunchTestNameKey: HostPreferenceKey {
    typealias Value = String?

    static var defaultValue: String? { nil }

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = value ?? nextValue()
    }
}
