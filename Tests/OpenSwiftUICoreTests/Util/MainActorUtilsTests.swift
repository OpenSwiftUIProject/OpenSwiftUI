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

    @Test
    @MainActor
    func mainActorOperation() {
        Semantics.v6.test {
            MainActor.assumeIsolatedIfLinkedOnOrAfterV6 {
                let a = A()
                a.foo()
            }
        }
        Semantics.v5.test {
            MainActor.assumeIsolatedIfLinkedOnOrAfterV6 {
                let a = A()
                a.foo()
            }
        }
    }

    @Test
    func nonMainActorOperation() {
        // TODO: swift-testing does not exist yet
        // Expect crash
//        Semantics.v6.test {
//            MainActor.assumeIsolatedIfLinkedOnOrAfterV6 {
//                let a = A()
//                a.foo()
//            }
//        }
        Semantics.v5.test {
            MainActor.assumeIsolatedIfLinkedOnOrAfterV6 {
                let a = A()
                a.foo()
            }
        }
    }
}
