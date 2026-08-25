//
//  PreviewMacroTests.swift
//  OpenSwiftUIMacrosTests

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(OpenSwiftUIMacros)
import OpenSwiftUIMacros

private let previewMacros: [String: Macro.Type] = [
    "Preview": PreviewMacro.self,
]

final class PreviewMacroTests: XCTestCase {
    func testPreviewExpansion() {
        assertMacroExpansion(
            """
            #Preview("HostingVC") {
                ContentView()
            }
            """,
            expandedSource:
            """
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    1
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview("HostingVC") {
                        OpenSwiftUI::Group {
                            ContentView()
                        }
                        ._previewVC()
                    }
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testPreviewExpansionPreservesViewBuilderBody() {
        assertMacroExpansion(
            """
            #Preview {
                Text("Primary")
                if showsSecondary {
                    Text("Secondary")
                }
            }
            """,
            expandedSource:
            """
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    1
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview {
                        OpenSwiftUI::Group {
                            Text("Primary")
                            if showsSecondary {
                                Text("Secondary")
                            }
                        }
                        ._previewVC()
                    }
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testPreviewExpansionPreservesTraits() {
        assertMacroExpansion(
            """
            #Preview(
                "Sized",
                traits: .sizeThatFitsLayout,
                .fixedLayout(width: 320, height: 200)
            ) {
                ContentView()
            }
            """,
            expandedSource:
            """
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    1
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview(
                        "Sized",
                        traits: .sizeThatFitsLayout,
                        .fixedLayout(width: 320, height: 200)
                    ) {
                        OpenSwiftUI::Group {
                            ContentView()
                        }
                        ._previewVC()
                    }
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testExplicitBodyArgumentExpansion() {
        assertMacroExpansion(
            """
            #Preview("Explicit", body: {
                ContentView()
            })
            """,
            expandedSource:
            """
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    1
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview("Explicit", body: {
                        OpenSwiftUI::Group {
                            ContentView()
                        }
                        ._previewVC()
                    })
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testBodyExpressionExpansionPreservesSourceLocation() {
        assertMacroExpansion(
            """
            let previewBody = makeContent

            #Preview("Expression", body: previewBody)
            """,
            expandedSource:
            """
            let previewBody = makeContent

            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    3
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview("Expression", body: {
                        OpenSwiftUI::AnyView((previewBody)())
                            ._previewVC()
                    })
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testEmptyViewBuilderBodyExpansion() {
        assertMacroExpansion(
            """
            #Preview {
            }
            """,
            expandedSource:
            """
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    1
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview {
                        OpenSwiftUI::Group {
                        }
                        ._previewVC()
                    }
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testMissingBodyDiagnostic() {
        assertMacroExpansion(
            """
            #Preview
            """,
            expandedSource:
            """
            #Preview
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "#Preview requires a view body",
                    line: 1,
                    column: 1
                )
            ],
            macros: previewMacros
        )
    }
}

#endif
