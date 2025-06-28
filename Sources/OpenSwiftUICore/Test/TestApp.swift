//
//  TestApp.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: A519B5B95CA8FF4E3445832668F0B2D2 (SwiftUI)
//  ID: E1A97A5CD5A5467396F8BB461CB26984 (SwiftUICore)

package import Foundation

// MARK: _TestApp [6.4.41] [WIP for defaultEnvironment]

@available(OpenSwiftUI_v1_0, *)
public struct _TestApp {
    package static var rootViewIdentifier: some Hashable { 0 }

    package static var comparisonViewIdentifier: some Hashable { 1 }

    package struct RootView: View {
        package struct StateType {
            package private(set) var id: Int
            package private(set) var testView: AnyView

            package init() {
                id = 0
                testView = AnyView(EmptyView().testID(0))
            }

            package mutating func setTestView<V>(_ view: V) where V: View {
                id += 1
                testView = AnyView(view.testID(id))
            }
        }

        @State private var state = StateType()
        @Namespace var rootFocusScope

        package init() {}

        package var body: some View {
            CoreGlue2.shared.makeRootView(
                base: state.testView,
                rootFocusScope: rootFocusScope
            )
        }
    }

    package static let defaultEnvironment: EnvironmentValues = {
        var environment = EnvironmentValues()
        CoreGlue2.shared.configureDefaultEnvironment(&environment)
        // TODO: Font: "HelveticaNeue"
        environment.displayScale = 2.0
        environment.setTestSystemColorDefinition()
        // TODO
        return environment
    }()

    package static var renderOptions: TestRenderOptions = .default

    /// Initialize a `_TestApp` for running tests.
    public init() {
        CoreGlue2.shared.initializeTestApp()
    }

    package static var host: (any TestHost)?

    package static var comparisonHost: (any TestHost)?

    private static var testIntents: TestIntents = []

    package static func setIntents(_ intents: TestIntents) {
        let before = testIntents
        testIntents = intents
        host?.testIntentsChanged(before: before, after: intents)
    }

    package static func isIntending(to intents: TestIntents) -> Bool {
        !testIntents.isDisjoint(with: intents)
    }

    package static var environmentOverride: EnvironmentValues?

    package static func setTestEnvironment(_ environment: EnvironmentValues?) {
        if let environment {
            var env = defaultEnvironment
            env.plist.override(with: environment.plist)
            environmentOverride = env
        } else {
            environmentOverride = nil
        }
        host?.invalidateProperties(.environment, mayDeferUpdate: true)
        comparisonHost?.invalidateProperties(.environment, mayDeferUpdate: true)
    }

    package static func updateTestEnvironment(_ body: (inout EnvironmentValues) -> Void) {
        var environment = EnvironmentValues()
        body(&environment)
        setTestEnvironment(environment)
    }

    package func setSemantics(_ version: String) {
        switch version {
        case "lastest": Semantics.forced.sdk = .latest
        case "maximal": Semantics.forced.sdk = .maximal
        case "system": break
        default: preconditionFailure("Invalid --semantics argument: \(version))")
        }
    }
}

@available(*, unavailable)
extension _TestApp: Sendable {}

extension _TestApp {
    package static func date(for time: Time) -> Date {
        Date.now
    }

    package static var dateIsSynchronizedWithTime: Bool {
        false
    }
}
