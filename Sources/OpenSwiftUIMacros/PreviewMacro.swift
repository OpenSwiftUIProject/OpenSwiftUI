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
            arguments[bodyIndex].expression = wrappedBody(arguments[bodyIndex].expression)
            trailingClosure = nil
        } else {
            throw MacroExpansionErrorMessage("#Preview requires a view body")
        }

        guard let sourceLocation = context.location(
            of: node.pound,
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

    private static func wrappedBody(_ body: ExprSyntax) -> ExprSyntax {
        // A referenced body already matches the OpenSwiftUI Preview initializer.
        guard let closure = body.as(ClosureExprSyntax.self) else {
            return body
        }
        return ExprSyntax(wrappedBody(closure))
    }

    private static func wrappedBody(_ body: ClosureExprSyntax) -> ClosureExprSyntax {
        // Apply the view builder to the statements without an extra root view.
        let buildView: DeclSyntax =
            """
            func __b_buildView(@OpenSwiftUI::ViewBuilder body: () -> any OpenSwiftUI::View) -> any OpenSwiftUI::View {
                body()
            }
            """
        let content = ClosureExprSyntax(statements: body.statements)
        let returnBuiltView = ReturnStmtSyntax(
            expression: FunctionCallExprSyntax(
                callee: DeclReferenceExprSyntax(baseName: .identifier("__b_buildView")),
                trailingClosure: content
            )
        )
        var wrappedBody = body
        wrappedBody.statements = CodeBlockItemListSyntax([
            CodeBlockItemSyntax(item: .decl(buildView)),
            CodeBlockItemSyntax(item: .stmt(StmtSyntax(returnBuiltView))),
        ])
        return wrappedBody.formatted().cast(ClosureExprSyntax.self)
    }
}
