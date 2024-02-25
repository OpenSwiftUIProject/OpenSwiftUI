//
//  AppGraph.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: A363922CEBDF47986D9772B903C8737A

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif
internal import OpenGraphShims

final class AppGraph: GraphHost {
    static var shared: AppGraph? = nil
    static var delegateBox: AnyFallbackDelegateBox? = nil
    
    private struct LaunchProfileOptions: OptionSet {
        let rawValue: Int32
        static var profile: LaunchProfileOptions { .init(rawValue: 1 << 1) }
    }
    
    private lazy var launchProfileOptions: LaunchProfileOptions = {
        let env = getenv("OPENSWIFTUI_PROFILE_LAUNCH")
        if let env {
            return .init(rawValue: atoi(env))
        } else {
            return []
        }
    }()
    
    var didCollectLaunchProfile: Bool = false
    
    init(app _: some App) {}
    
    func extendedLaunchTestName() -> String? { nil }
    
    func startProfilingIfNecessary() {
        guard !didCollectLaunchProfile else {
            return
        }
        if launchProfileOptions.contains(.profile) {
            OGGraph.startProfiling()
        }
    }
    
    func stopProfilingIfNecessary() {
        guard !didCollectLaunchProfile else {
            return
        }
        didCollectLaunchProfile = true
        if launchProfileOptions.contains(.profile) {
            OGGraph.stopProfiling()
        }
        if !launchProfileOptions.isEmpty {
            // /tmp/graph.ag-gzon
            OGGraph.archiveJSON(name: nil)
        }
    }
}
