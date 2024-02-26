//
//  SemanticFeature.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import COpenSwiftUI

protocol SemanticFeature: Feature {
    static var introduced: Semantics { get }
}

extension SemanticFeature {
    static var isEnable: Bool {
        if let forced = Semantics.forced {
            forced >= introduced
        } else {
            dyld_program_sdk_at_least(.init(semantics: introduced))
        }
    }
}

struct _SemanticFeature_v2: SemanticFeature {
    static var introduced: Semantics { .v2_3 }
}

struct _SemanticFeature_v3: SemanticFeature {
    static var introduced: Semantics { .v3_2 }
}
