//
//  SemanticFeature.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

internal import COpenSwiftUICore

package protocol SemanticFeature: Feature {
    static var introduced: Semantics { get }
    static var requirement: SemanticRequirement { get }
}

extension SemanticFeature {
    @inlinable
    package static var requirement: SemanticRequirement { .linkedOnOrAfter }
    
    @inlinable
    package static var prior: Semantics { introduced.prior }
}

package struct _SemanticFeature_v2: SemanticFeature {
    package static let introduced = Semantics.v2
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v2_1: SemanticFeature {
    package static let introduced = Semantics.v2_1
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v2_3: SemanticFeature {
    package static let introduced = Semantics.v2_3
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v3: SemanticFeature {
    package static let introduced = Semantics.v3
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v4: SemanticFeature {
    package static let introduced = Semantics.v4
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v4_4: SemanticFeature {
    package static let introduced = Semantics.v4_4
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v5: SemanticFeature {
    package static let introduced = Semantics.v5
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v5_2: SemanticFeature {
    package static let introduced = Semantics.v5_2
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v6: SemanticFeature {
    package static let introduced = Semantics.v6
    
    @inlinable
    package init() {}
}
