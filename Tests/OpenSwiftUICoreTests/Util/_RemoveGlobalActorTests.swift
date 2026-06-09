//
//  _RemoveGlobalActorTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

// MARK: - _RemoveGlobalActorTests

struct _RemoveGlobalActorTests {
    @MainActor
    protocol P {}

    @Test
    func removeGlobalActorIsolation() {
        struct A: P, _RemoveGlobalActorIsolation {
            static func p() {}
        }
        A.p()
    }

    // NOTE: iOS and some platform do not support exit test. Use varibale to enable/disable such test case in the future
    #if !os(iOS) && !os(visionOS)
    @Test
    func standaloneConstraintCrash() async {
        struct B: _RemoveGlobalActorIsolation {
            static func p() {}
        }
        await #expect(processExitsWith: .failure) {
            await B.p()
        }
    }
    #endif
}
