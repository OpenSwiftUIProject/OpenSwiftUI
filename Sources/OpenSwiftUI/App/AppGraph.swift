//
//  AppGraph.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: A363922CEBDF47986D9772B903C8737A

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif
import OpenGraphShims
@_spi(ForOpenSwiftUIOnly) package import OpenSwiftUICore

package final class AppGraph: GraphHost {
    static var shared: AppGraph? = nil
    static var delegateBox: AnyFallbackDelegateBox? = nil
    
    private struct LaunchProfileOptions: OptionSet {
        let rawValue: Int32
        static var profile: LaunchProfileOptions { .init(rawValue: 1 << 1) }
    }
    
    private lazy var launchProfileOptions = LaunchProfileOptions(
        rawValue: EnvironmentHelper.int32(for: "OPENSWIFTUI_PROFILE_LAUNCH")
    )
    
    var didCollectLaunchProfile: Bool = false

    // TODO
    init(app: some App) {
        let data = GraphHost.Data()
        super.init(data: data)
    }
    
    // MARK: - Override Methods

    // MARK: - Profile related
    
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

private struct AppBodyAccessor<Container: App>: BodyAccessor {
    typealias Body = Container.Body
    
    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body
        }
    }
}
