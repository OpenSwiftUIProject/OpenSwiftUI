//
//  ToolbarSafeAreaInset.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C764A51E18F00BD2239CE85BD2E25F3B (SwiftUI)

import OpenSwiftUICore

// MARK: - CreatesToolbarSafeAreaInsetPredicate

struct CreatesToolbarSafeAreaInsetPredicate: ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        CreatesToolbarSafeAreaInsetInput.evaluate(inputs: inputs)
    }
}

// TODO: ToolbarSafeAreaInsetModifier

// MARK: - CreatesToolbarSafeAreaInsetInput

struct CreatesToolbarSafeAreaInsetInput: ViewInputBoolFlag {}
