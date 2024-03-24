//
//  ViewGeometry.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation
internal import OpenGraphShims

struct ViewGeometry: Equatable {
    var origin: ViewOrigin
    var dimensions: ViewDimensions
    
    @inline(__always)
    static var zero: ViewGeometry { ViewGeometry(origin: .zero, dimensions: .zero) }
}

extension Attribute where Value == ViewGeometry {
    func origin() -> Attribute<ViewOrigin> {
        self[keyPath: \.origin]
    }
    
    func size() -> Attribute<ViewSize> {
        self[keyPath: \.dimensions.size]
    }
}
