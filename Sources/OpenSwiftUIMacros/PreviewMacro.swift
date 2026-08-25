//
//  PreviewMacro.swift
//  OpenSwiftUIMacros

package import SwiftSyntax
import SwiftSyntaxBuilder
package import SwiftSyntaxMacros

package struct PreviewMacro: DeclarationMacro {
    package static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var arguments = Array(node.arguments)
        let trailingClosure: ClosureExprSyntax?

        if let body = node.trailingClosure {
            trailingClosure = wrappedBody(body)
        } else if let bodyIndex = arguments.lastIndex(where: { $0.label?.text == "body" }) {
            arguments[bodyIndex].expression = ExprSyntax(wrappedBody(arguments[bodyIndex].expression))
            trailingClosure = nil
        } else {
            throw MacroExpansionErrorMessage("#Preview requires a view body")
        }

        guard let sourceLocation = context.location(
            of: node,
            at: .afterLeadingTrivia,
            filePathMode: .fileID
        ) else {
            throw MacroExpansionErrorMessage("#Preview could not determine its source location")
        }

        let preview = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(
                moduleSelector: ModuleSelectorSyntax(
                    moduleName: .identifier("DeveloperToolsSupport")
                ),
                baseName: .identifier("Preview")
            ),
            leftParen: node.leftParen,
            arguments: LabeledExprListSyntax(arguments),
            rightParen: node.rightParen,
            trailingClosure: trailingClosure,
            additionalTrailingClosures: node.additionalTrailingClosures
        )

        // Xcode matches the registry to the source-level #Preview expansion.
        // A nested platform #Preview gives the registry a different expansion
        // identity, so emit the registry from this first expansion instead.
        let registryName = context.makeUniqueName("PreviewRegistry")
        let registry: DeclSyntax =
            """
            @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
            struct \(registryName): DeveloperToolsSupport::PreviewRegistry {
                static var fileID: Swift::String {
                    \(sourceLocation.file)
                }
                static var line: Swift::Int {
                    \(sourceLocation.line)
                }
                static var column: Swift::Int {
                    \(sourceLocation.column)
                }

                static func makePreview() throws -> DeveloperToolsSupport::Preview {
                    \(preview)
                }
            }
            """
        return [registry]
    }

    private static func wrappedBody(_ body: ExprSyntax) -> ClosureExprSyntax {
        guard let closure = body.as(ClosureExprSyntax.self) else {
            // A referenced body returns an existential View, so erase its
            // result to a concrete root before creating the hosting controller.
            let wrappedBody: ExprSyntax = """
                {
                    OpenSwiftUI::AnyView((\(body))())
                        ._previewVC()
                }
                """
            return wrappedBody.as(ClosureExprSyntax.self)!
        }
        return wrappedBody(closure)
    }

    private static func wrappedBody(_ body: ClosureExprSyntax) -> ClosureExprSyntax {
        let content = ClosureExprSyntax(statements: body.statements)
        let group = FunctionCallExprSyntax(
            callee: DeclReferenceExprSyntax(
                moduleSelector: ModuleSelectorSyntax(moduleName: .identifier("OpenSwiftUI")),
                baseName: .identifier("Group")
            ),
            trailingClosure: content
        )
        let previewVC = FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                base: group,
                period: .periodToken(leadingTrivia: .newline),
                declName: DeclReferenceExprSyntax(baseName: .identifier("_previewVC"))
            )
        )
        var wrappedBody = body
        wrappedBody.statements = CodeBlockItemListSyntax([
            CodeBlockItemSyntax(item: .expr(ExprSyntax(previewVC)))
        ])
        return wrappedBody
    }
}
