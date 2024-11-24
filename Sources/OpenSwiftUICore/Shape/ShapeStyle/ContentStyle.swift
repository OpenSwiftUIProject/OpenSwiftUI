//
//  ContentStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by Material

import Foundation

package enum ContentStyle {
    package enum ID: Swift.Int8 {
        case primary
        case secondary
        case tertiary
        case quaternary
        case quinary
    }
    
    package enum Primitive {
        case fill
        case stroke
        case separator
        package init(_ role: ShapeRole) {
            switch role {
            case .fill: self = .fill
            case .stroke: self = .stroke
            case .separator: self = .separator
            }
        }
    }
    
    package struct Style: Hashable {
        package var id: ID
        package var primitive: Primitive
        package init(id: ID, primitive: Primitive) {
            self.id = id
            self.primitive = primitive
        }
    }
    
//    package struct MaterialStyle: Hashable {
//        package var material: Material.ResolvedMaterial
//        package var base: Style
//        package init(material: Material.ResolvedMaterial, base: Style) {
//            self.material = material
//            self.base = base
//        }
//    }
}
