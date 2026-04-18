//
//  OpenSwiftUIMacrosPlugin.swift
//  OpenSwiftUIMacros

package import SwiftCompilerPlugin
package import SwiftSyntax
package import SwiftSyntaxBuilder
package import SwiftSyntaxMacros

@main
struct OpenSwiftUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EntryMacro.self,
        EntryDefaultValueMacro.self,
    ]
}
