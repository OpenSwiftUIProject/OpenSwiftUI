//
//  SafeAreaRegions.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: C4DC82F2A500E9B6DEA3064A36584B42 (SwiftUICore)

package struct SafeAreaInsets: Equatable {
    package enum OptionalValue: Equatable {
        case empty
        indirect case insets(SafeAreaInsets)
    }
    
    package struct Element: Equatable {
        package var regions: SafeAreaRegions
        package var insets: EdgeInsets
        
        package init(regions: SafeAreaRegions, insets: EdgeInsets) {
            self.regions = regions
            self.insets = insets
        }
    }
    
    package var space: CoordinateSpace.ID
    package var elements: [Element]
    package var next: OptionalValue
    
    package init(space: CoordinateSpace.ID, elements: [Element]) {
        self.space = space
        self.elements = elements
        self.next = .empty
    }
    
    package init(space: CoordinateSpace.ID, elements: [Element], next: OptionalValue) {
        self.space = space
        self.elements = elements
        self.next = next
    }
    
    package func resolve(regions: SafeAreaRegions, in ctx: _PositionAwarePlacementContext) -> EdgeInsets {
        preconditionFailure("TODO")
    }
}
