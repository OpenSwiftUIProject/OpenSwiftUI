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
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let _ = binding.typeAnnotation?.type else {
            throw MacroExpansionErrorMessage("@Entry can only be applied to stored properties")
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
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = binding.typeAnnotation?.type,
              let initializer = binding.initializer else {
            throw MacroExpansionErrorMessage("@Entry requires a property with type annotation and initial value")
        }

        let identifierText = identifier.text
        let keyName = "__Key_\(identifierText)"
        let defaultValue = initializer.value

        let keyStruct = StructDeclSyntax(
            modifiers: [DeclModifierSyntax(name: .keyword(.private))],
            name: .identifier(keyName),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("OpenSwiftUICore.EnvironmentKey")))
            }
        ) {
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
                bindingSpecifier: .keyword(.var)
            ) {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("defaultValue")),
                    typeAnnotation: TypeAnnotationSyntax(
                        colon: .colonToken(),
                        type: type
                    ),
                    initializer: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: defaultValue
                    )
                )
            }
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
