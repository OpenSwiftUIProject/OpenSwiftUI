//
//  AppKitAppDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 4475FD12FD59DEBA453321BD91F6EA04 (SwiftUI)

#if os(macOS)
import AppKit

// MARK: - App Utils

func currentAppName() -> String {
    if let name = Bundle.main.localizedValue(for: "CFBundleDisplayName") {
        return name
    } else if let name = Bundle.main.localizedValue(for: "CFBundleName") {
        return name
    } else {
        return ProcessInfo.processInfo.processName
    }
}

extension Bundle {
    fileprivate func localizedValue(for key: String) -> String? {
        if let localizedInfoDictionary,
           let value = localizedInfoDictionary[key] as? String {
            return value
        } else if let infoDictionary,
                  let value = infoDictionary[key] as? String {
            return value
        } else {
            return nil
        }
    }
}

#endif
