//
//  EntryMacro.swift
//  OpenSwiftUIMacros

package import SwiftSyntax
package import SwiftSyntaxMacros

package struct EntryMacro: AccessorMacro, PeerMacro {
    package static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw MacroExpansionErrorMessage("@Entry can only be applied to stored properties")
        }

        // Check that we have either a type annotation OR an initializer (for type inference)
        let hasType = binding.typeAnnotation?.type != nil
        let hasInitializer = binding.initializer != nil

        guard hasType || hasInitializer else {
            throw MacroExpansionErrorMessage("@Entry requires either a type annotation or an initial value")
        }


        let identifierText = identifier.text
        let keyName = "__Key_\(identifierText)"

        return [
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.get),
                body: CodeBlockSyntax {
                    "self[\(raw: keyName).self]"
                }
            ),
            AccessorDeclSyntax(
                accessorSpecifier: .keyword(.set),
                body: CodeBlockSyntax {
                    "self[\(raw: keyName).self] = newValue"
                }
            )
        ]
    }

    package static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw MacroExpansionErrorMessage("@Entry requires a property with valid identifier")
        }

        let identifierText = identifier.text
        let keyName = "__Key_\(identifierText)"

        // Determine default value
        let defaultValue: ExprSyntax

        if let initializer = binding.initializer {
            // Has initializer - use the initializer value
            defaultValue = initializer.value
        } else if let explicitType = binding.typeAnnotation?.type {
            // Only type annotation, no initializer
            // Check if it's optional type - if so, default to nil
            let typeString = explicitType.description
            if typeString.contains("?") {
                defaultValue = ExprSyntax(NilLiteralExprSyntax())
            } else {
                throw MacroExpansionErrorMessage("@Entry requires an initial value for non-optional types")
            }
        } else {
            throw MacroExpansionErrorMessage("@Entry requires either a type annotation or an initial value")
        }

        let keyStruct = StructDeclSyntax(
            modifiers: [DeclModifierSyntax(name: .keyword(.private))],
            name: .identifier(keyName),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("OpenSwiftUICore.EnvironmentKey")))
            }
        ) {
            // Create the variable declaration
            let patternBinding = PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("defaultValue")),
                typeAnnotation: binding.typeAnnotation,
                initializer: InitializerClauseSyntax(
                    equal: .equalToken(),
                    value: defaultValue
                )
            )

            VariableDeclSyntax(
                attributes: AttributeListSyntax([
                    AttributeListSyntax.Element(
                        AttributeSyntax(
                            atSign: .atSignToken(),
                            attributeName: IdentifierTypeSyntax(name: .identifier("__EntryDefaultValue"))
                        )
                    )
                ]),
                modifiers: [DeclModifierSyntax(name: .keyword(.static))],
                bindingSpecifier: .keyword(.var),
                bindings: PatternBindingListSyntax([patternBinding])
            )
        }

        return [DeclSyntax(keyStruct)]
    }
}

package struct MacroExpansionErrorMessage: Error, CustomStringConvertible {
    package let description: String

    package init(_ description: String) {
        self.description = description
    }
}
