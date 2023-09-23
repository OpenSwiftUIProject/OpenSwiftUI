//
//  SemanticFeature.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/23.
//  Lastest Version: iOS 15.5
//  Status: WIP

import Foundation

protocol SemanticFeature: Feature {
    static var introduced: Semantics { get }
}

extension SemanticFeature {
    static var isEnable: Bool { true }
}

struct _SemanticFeature_v2: SemanticFeature {
    static var introduced: Semantics { .v2_3 }
}

struct _SemanticFeature_v3: SemanticFeature {
    static var introduced: Semantics { .v3_2 }
}
