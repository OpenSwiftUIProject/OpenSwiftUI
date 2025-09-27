//
//  EntryMacroTests.swift
//  OpenSwiftUIMacrosTests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(OpenSwiftUIMacros)
import OpenSwiftUIMacros

private let testMacros: [String: Macro.Type] = [
    "Entry": EntryMacro.self,
    "__EntryDefaultValue": EntryDefaultValueMacro.self,
]

final class EntryMacroTests: XCTestCase {
    func testEntryMacroExpansion() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var myCustomValue: String = "Default value"
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var myCustomValue: String {
                    get {
                        self[__Key_myCustomValue.self]
                    }
                    set {
                        self[__Key_myCustomValue.self] = newValue
                    }
                }
            }

            private struct __Key_myCustomValue: OpenSwiftUICore.EnvironmentKey {
                @__EntryDefaultValue
                static var defaultValue: String = "Default value"
            }
            """,
            macros: testMacros
        )
    }

    func testEntryMacroExpansionWithIntType() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var intValue: Int = 42
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var intValue: Int {
                    get {
                        self[__Key_intValue.self]
                    }
                    set {
                        self[__Key_intValue.self] = newValue
                    }
                }
            }

            private struct __Key_intValue: OpenSwiftUICore.EnvironmentKey {
                @__EntryDefaultValue
                static var defaultValue: Int = 42
            }
            """,
            macros: testMacros
        )
    }

    func testEntryDefaultValueMacroExpansion() {
        assertMacroExpansion(
            """
            @__EntryDefaultValue
            static var defaultValue: String = "Default value"
            """,
            expandedSource:
            """
            static var defaultValue: String {
                get {
                    "Default value"
                }
            }
            """,
            macros: testMacros
        )
    }
}

#endif
