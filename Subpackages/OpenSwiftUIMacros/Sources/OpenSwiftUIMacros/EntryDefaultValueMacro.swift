//
//  EntryDefaultValueMacro.swift
//  OpenSwiftUIMacros

package import SwiftSyntax
package import SwiftSyntaxMacros

package struct EntryDefaultValueMacro: AccessorMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let initializer = binding.initializer else {
            throw MacroExpansionErrorMessage("@__EntryDefaultValue can only be applied to stored properties with initial values")
        }

        let defaultValue = initializer.value

        return [
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.get),
                body: CodeBlockSyntax {
                    "\(defaultValue)"
                }
            )
        ]
    }
}
