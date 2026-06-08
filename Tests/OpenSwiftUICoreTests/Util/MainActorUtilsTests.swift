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
    func mainActorOperation() {
        Self.assumeWithFirstRelease()
        Self.assumeWithMaximal()
    }

    @Test
    func nonMainActorFailure() async {
        await #expect(processExitsWith: .failure) {
            Self.assumeWithFirstRelease()
        }
    }

    @Test(containsRuntimeIssue("%s This warning will become a runtime crash in a future version of OpenSwiftUI."))
    func nonMainActorRuntimeIssue() async {
        Self.assumeWithMaximal()
    }
}
