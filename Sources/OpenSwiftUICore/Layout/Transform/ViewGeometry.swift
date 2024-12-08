//
//  ViewGeometry.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation
package import OpenGraphShims

package struct ViewGeometry: Equatable {
    package var origin: ViewOrigin
    package var dimensions: ViewDimensions
    
    package init(origin: ViewOrigin, dimensions: ViewDimensions) {
        self.origin = origin
        self.dimensions = dimensions
    }
    
    package init(dimensions: ViewDimensions) {
        self.init(origin: ViewOrigin(), dimensions: dimensions)
    }
    
    package init(origin: CGPoint, dimensions: ViewDimensions) {
        self.init(origin: ViewOrigin(origin), dimensions: dimensions)
    }
    
    package init(placement p: _Placement, dimensions d: ViewDimensions) {
        self.origin = ViewOrigin(p.frameOrigin(childSize: d.size.value))
        self.dimensions = d
    }
    
    package subscript(guide: HorizontalAlignment) -> CGFloat { dimensions[guide] }
    package subscript(guide: VerticalAlignment) -> CGFloat { dimensions[guide] }
    package subscript(explicit guide: HorizontalAlignment) -> CGFloat? { dimensions[explicit: guide] }
    package subscript(explicit guide: VerticalAlignment) -> CGFloat? { dimensions[explicit: guide] }
}

extension Attribute where Value == ViewGeometry {
    package func origin() -> Attribute<ViewOrigin> { self[keyPath: \.origin] }
    package func size() -> Attribute<ViewSize> { self[keyPath: \.dimensions.size] }
}

extension ViewGeometry {
    package var frame: CGRect {
        CGRect(origin: origin.value, size: dimensions.size.value)
    }
    
    package static let invalidValue = ViewGeometry(origin: ViewOrigin(invalid: ()), dimensions: .invalidValue)
    
    package var isInvalid: Bool { origin.x.isNaN }
    
    package static let zero = ViewGeometry(origin: CGPoint.zero, dimensions: .zero)
    
    package subscript(key: AlignmentKey) -> CGFloat { dimensions[key] }
    
    package subscript(explicit key: AlignmentKey) -> CGFloat? { dimensions[explicit: key] }
    
    package mutating func finalizeLayoutDirection(_ layoutDirection: LayoutDirection, parentSize: CGSize) {
        guard layoutDirection == .rightToLeft else { return }
        origin.x = parentSize.width - frame.maxX
    }
}
