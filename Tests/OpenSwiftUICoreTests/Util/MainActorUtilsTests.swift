//
//  MainActorUtilsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct MainActorUtilsTests {
    @MainActor
    final class A {
        func foo() {}
    }

    private static func assumeWithFirstRelease() {
        MainActor.assumeIsolatedIfLinkedOnOrAfter(.firstRelease) {
            let a = A()
            a.foo()
        }
    }

    private static func assumeWithMaximal() {
        MainActor.assumeIsolatedIfLinkedOnOrAfter(.maximal) {
            let a = A()
            a.foo()
        }
    }

    @Test
    @MainActor
    func mainActorAssumePass() {
        Self.assumeWithFirstRelease()
    }

    // On non-Darwin platforms, Swift Testing may run @MainActor tests on a
    // Swift executor that is not Thread.isMainThread, which intentionally
    // records a runtime issue in the fallback path.
    #if canImport(Darwin)
    @Test
    @MainActor
    func mainActorAssumeFail() {
        Self.assumeWithMaximal()
    }
    #endif

    #if !os(iOS) && !os(visionOS)
    @Test
    func nonMainActorAssumePassWithFailure() async {
        await #expect(processExitsWith: .failure) {
            Self.assumeWithFirstRelease()
        }
    }
    #endif

    @Test(containsRuntimeIssue("%s This warning will become a runtime crash in a future version of OpenSwiftUI."))
    func nonMainActorAssumeFailWithRuntimeIssue() async {
        Self.assumeWithMaximal()
    }
}
