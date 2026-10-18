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
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                            ContentView()
                        }
                    }
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testPreviewExpansionPreservesSourceLineAfterAvailability() {
        assertMacroExpansion(
            """
            @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
            #Preview {
                CounterView()
            }
            """,
            expandedSource:
            """
            @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    2
                }
                static var column: Swift::Int {
                    1
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview {
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                            CounterView()
                        }
                    }
                }
            }
            """,
            macros: previewMacros
        )
    }

    func testPreviewExpansionPreservesSourceColumnAfterAvailability() {
        assertMacroExpansion(
            """
            @available(macOS 14.0, *) #Preview {
                ContentView()
            }
            """,
            expandedSource:
            """
            @available(macOS 14.0, *) @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct __macro_local_15PreviewRegistryfMu_: DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    "TestModule/test.swift"
                }
                static var line: Swift::Int {
                    1
                }
                static var column: Swift::Int {
                    27
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    DeveloperToolsSupport::Preview {
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                            ContentView()
                        }
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
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                            Text("Primary")
                            if showsSecondary {
                                Text("Secondary")
                            }
                        }
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
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                            ContentView()
                        }
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
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                            ContentView()
                        }
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
                    DeveloperToolsSupport::Preview("Expression", body: previewBody)
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
                        func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                            body()
                        }
                        return __b_buildView {
                        }
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
