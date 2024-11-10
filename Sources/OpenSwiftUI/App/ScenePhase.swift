//
//  ScenePhase.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 130BB08D98602D712FD59CAC6992C14A

public enum ScenePhase: Comparable, Hashable {
    case background
    case inactive
    case active
}

private struct ScenePhaseKey: EnvironmentKey {
    static let defaultValue: ScenePhase = .background
}

extension EnvironmentValues {
    public var scenePhase: ScenePhase {
        get { self[ScenePhaseKey.self] }
        set { self[ScenePhaseKey.self] = newValue }
    }
}
