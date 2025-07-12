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

    #if compiler(>=6.2)
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
