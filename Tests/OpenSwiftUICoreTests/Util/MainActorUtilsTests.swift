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

    @Test
    @MainActor
    func mainActorAssumeFail() {
        Self.assumeWithMaximal()
    }

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
