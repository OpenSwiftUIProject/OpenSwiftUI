//
//  EntryMacroTests.swift
//  OpenSwiftUI
//
//  Created by OpenSwiftUI on [Date].
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(OpenSwiftUIMacros)
import OpenSwiftUIMacros

@Test func entryMacroExpansion() {
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

        private struct __Key_myCustomValue: SwiftUICore.EnvironmentKey {
            @__EntryDefaultValue
            static var defaultValue: String = "Default value"
        }
        """,
        macros: testMacros
    )
}

@Test func entryMacroExpansionWithIntType() {
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

        private struct __Key_intValue: SwiftUICore.EnvironmentKey {
            @__EntryDefaultValue
            static var defaultValue: Int = 42
        }
        """,
        macros: testMacros
    )
}

@Test func entryDefaultValueMacroExpansion() {
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

private let testMacros: [String: Macro.Type] = [
    "Entry": EntryMacro.self,
    "__EntryDefaultValue": EntryDefaultValueMacro.self,
]
#endif