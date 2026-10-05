//
//  AppIntentAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import COpenSwiftUI
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

    enum Error: Swift.Error {
        case missingLNAction
    }

    enum CodingKeys: String, CodingKey {
        case lnAction
    }
}

// MARK: - AppIntentAction + Codable

extension AppIntentAction: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .lnAction)
        guard let lnAction = try NSKeyedUnarchiver.openswiftui_unarchiveTopLevelLNAction(with: data) else {
            throw Error.missingLNAction
        }
        self.lnAction = lnAction
        defaultExecutor = {
            Self.logger.error("Executing an AppIntent using the default executor is not supported with archiving.")
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try NSKeyedArchiver.archivedData(withRootObject: lnAction, requiringSecureCoding: true)
        try container.encode(data, forKey: .lnAction)
    }
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
