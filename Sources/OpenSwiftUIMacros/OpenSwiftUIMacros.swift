//
//  OpenSwiftUIMacros.swift
//  OpenSwiftUI
//
//  Created by OpenSwiftUI on [Date].
//

@_exported import SwiftCompilerPlugin
@_exported import SwiftSyntax
@_exported import SwiftSyntaxBuilder
@_exported import SwiftSyntaxMacros

@main
struct OpenSwiftUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EntryMacro.self,
        EntryDefaultValueMacro.self,
    ]
}