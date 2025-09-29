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

        // Validate type inference for unsupported cases
        if !hasType, let initializer = binding.initializer {
            let initValue = initializer.value

            // Check if this is a member function call that we cannot handle
            if let functionCall = initValue.as(FunctionCallExprSyntax.self),
               let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self) {
                let memberName = memberAccess.declName.baseName.text
                if memberName.first?.isUppercase != true {
                    throw MacroExpansionErrorMessage("@Entry with member function calls requires explicit type annotation. Use: @Entry var p: ReturnType = A.b()")
                }
            }
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

        // Determine type and default value
        let type: TypeSyntax
        let defaultValue: ExprSyntax

        if let explicitType = binding.typeAnnotation?.type {
            // Case 1: Explicit type annotation
            type = explicitType
            if let initializer = binding.initializer {
                // Has both type and initializer - use the initializer value
                defaultValue = initializer.value
            } else {
                // Only type annotation, no initializer
                // Check if it's optional type - if so, default to nil
                let typeString = explicitType.description
                if typeString.contains("?") {
                    defaultValue = ExprSyntax(NilLiteralExprSyntax())
                } else {
                    throw MacroExpansionErrorMessage("@Entry requires an initial value for non-optional types")
                }
            }
        } else if let initializer = binding.initializer {
            // Case 2: Type inference from initializer
            // We need to infer the type from the initializer
            // For now, we'll use a simple approach and let Swift infer it
            let initValue = initializer.value

            // Try to infer basic types
            if initValue.is(IntegerLiteralExprSyntax.self) {
                type = TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))
            } else if initValue.is(FloatLiteralExprSyntax.self) {
                type = TypeSyntax(IdentifierTypeSyntax(name: .identifier("Double")))
            } else if initValue.is(StringLiteralExprSyntax.self) {
                type = TypeSyntax(IdentifierTypeSyntax(name: .identifier("String")))
            } else if initValue.is(BooleanLiteralExprSyntax.self) {
                type = TypeSyntax(IdentifierTypeSyntax(name: .identifier("Bool")))
            } else if let functionCall = initValue.as(FunctionCallExprSyntax.self) {
                // Handle different types of function calls
                if let identifierExpr = functionCall.calledExpression.as(DeclReferenceExprSyntax.self) {
                    // Simple function calls like CustomType()
                    let typeName = identifierExpr.baseName.text
                    type = TypeSyntax(IdentifierTypeSyntax(name: .identifier(typeName)))
                } else if let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self) {
                    // Member access function calls like A.b()
                    // We cannot determine the return type without type checking, but we can try
                    // to extract it from context or require explicit annotation

                    // For now, we'll look for a pattern where the function name suggests the return type
                    // This is heuristic-based and limited, but covers some common cases
                    let memberName = memberAccess.declName.baseName.text

                    // Try some heuristics: if function name matches a type (like A.c() -> C)
                    // This is a simplified approach for demonstration
                    if memberName.first?.isUppercase == true {
                        // Assume function name starting with uppercase is a type name
                        let capitalizedName = String(memberName.prefix(1).uppercased() + memberName.dropFirst())
                        type = TypeSyntax(IdentifierTypeSyntax(name: .identifier(capitalizedName)))
                    } else {
                        // For member access calls, we need explicit type annotation
                        // because we cannot reliably infer the return type
                        throw MacroExpansionErrorMessage("@Entry with member function calls requires explicit type annotation. Use: @Entry var p: ReturnType = A.b()")
                    }
                } else {
                    // Other complex function call expressions
                    throw MacroExpansionErrorMessage("@Entry with type inference requires explicit type for complex expressions. Use: @Entry var name: CustomType = CustomType()")
                }
            } else {
                // For other complex expressions, we cannot easily infer the type at compile time
                throw MacroExpansionErrorMessage("@Entry with type inference requires explicit type for complex expressions")
            }
            defaultValue = initValue
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
