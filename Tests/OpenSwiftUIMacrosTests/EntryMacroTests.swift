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

                private struct __Key_myCustomValue: OpenSwiftUICore.EnvironmentKey {
                    static var defaultValue: String {
                        get {
                            "Default value"
                        }
                    }
                }
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

                private struct __Key_intValue: OpenSwiftUICore.EnvironmentKey {
                    static var defaultValue: Int {
                        get {
                            42
                        }
                    }
                }
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

    func testEntryMacroWithInferredType() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var inferType = 0
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var inferType {
                    get {
                        self[__Key_inferType.self]
                    }
                    set {
                        self[__Key_inferType.self] = newValue
                    }
                }

                private struct __Key_inferType: OpenSwiftUICore.EnvironmentKey {
                    static var defaultValue: Int {
                        get {
                            0
                        }
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testEntryMacroWithOptionalType() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var optionalType: Int?
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var optionalType: Int? {
                    get {
                        self[__Key_optionalType.self]
                    }
                    set {
                        self[__Key_optionalType.self] = newValue
                    }
                }

                private struct __Key_optionalType: OpenSwiftUICore.EnvironmentKey {
                    static var defaultValue: Int? {
                        get {
                            nil
                        }
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

    func testEntryMacroWithCustomTypeInference() {
        assertMacroExpansion(
            """
            struct CustomType {}

            extension EnvironmentValues {
                @Entry var inferCustomType = CustomType()
            }
            """,
            expandedSource:
            """
            struct CustomType {}

            extension EnvironmentValues {
                var inferCustomType {
                    get {
                        self[__Key_inferCustomType.self]
                    }
                    set {
                        self[__Key_inferCustomType.self] = newValue
                    }
                }

                private struct __Key_inferCustomType: OpenSwiftUICore.EnvironmentKey {
                    static var defaultValue: CustomType {
                        get {
                            CustomType()
                        }
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
}

#endif
