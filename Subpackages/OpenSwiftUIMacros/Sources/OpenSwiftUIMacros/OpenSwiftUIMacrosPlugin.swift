//
//  OpenSwiftUIMacrosPlugin.swift
//  OpenSwiftUIMacros

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct OpenSwiftUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EntryMacro.self,
        EntryDefaultValueMacro.self,
    ]
}
