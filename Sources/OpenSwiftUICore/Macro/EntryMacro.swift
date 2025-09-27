//
//  EntryMacro.swift
//  OpenSwiftUICore

@attached(accessor) @attached(peer, names: prefixed(__Key_)) public macro Entry() = #externalMacro(
    module: "OpenSwiftUIMacros", type: "EntryMacro"
)

@attached(accessor) public macro __EntryDefaultValue() = #externalMacro(
    module: "OpenSwiftUIMacros", type: "EntryDefaultValueMacro"
)