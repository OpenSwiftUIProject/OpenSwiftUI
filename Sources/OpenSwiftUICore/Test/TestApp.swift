//
//  TestApp.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: A519B5B95CA8FF4E3445832668F0B2D2 (SwiftUI)
//  ID: E1A97A5CD5A5467396F8BB461CB26984 (SwiftUICore)

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
        // TODO
        return environment
    }()

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
        // TODO
    }

    package static func updateTestEnvironment(_ body: (inout EnvironmentValues) -> Void) {
        // TODO
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
