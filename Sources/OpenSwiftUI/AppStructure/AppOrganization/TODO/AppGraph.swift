//
//  AppGraph.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: A363922CEBDF47986D9772B903C8737A

#if canImport(Darwin)
@available(watchOS 7.0, *)
final class AppGraph: GraphHost {
    init(app _: some App) {}
    
    static var shared: AppGraph? = nil
    static var delegateBox: AnyFallbackDelegateBox? = nil
    
    func extendedLaunchTestName() -> String? { nil }

    func startProfilingIfNecessary() {}
}
#endif
