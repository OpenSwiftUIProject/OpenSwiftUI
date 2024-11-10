//
//  AnyShapeStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: ABC85937500395B09974756E9F651929

import Foundation
import OpenGraphShims

/// A type-erased ShapeStyle value.
@frozen
public struct AnyShapeStyle: ShapeStyle {
    @usableFromInline
    @frozen
    package struct Storage: Equatable {
        package var box: AnyShapeStyleBox
        
        @usableFromInline
        package static func == (lhs: Storage, rhs: Storage) -> Bool {
            if lhs.box === rhs.box {
                return true
            } else {
                return lhs.box.isEqual(to: rhs.box)
            }
        }
    }

    package var storage: Storage
    
    /// Create an instance from `style`.
    public init<S>(_ style: S) where S: ShapeStyle {
        storage = .init(box: ShapeStyleBox(style))
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        storage.box.apply(to: &shape)
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .none
    }
    
    #if OPENSWIFTUI_SUPPORT_2023_API
    public typealias Resolved = Never
    #endif
}

/// Abstract base class for type-erased ShapeStyle storage.
@usableFromInline
package class AnyShapeStyleBox {
    package func apply(to shape: inout _ShapeStyle_Shape) {}
    package func isEqual(to other: AnyShapeStyleBox) -> Bool { false }
}

// ID: ABC85937500395B09974756E9F651929
private final class ShapeStyleBox<S>: AnyShapeStyleBox where S: ShapeStyle {
    let base: S
    
    init(_ base: S) {
        self.base = base
    }
    
    override func apply(to shape: inout _ShapeStyle_Shape) {
        base._apply(to: &shape)
    }
    
    override func isEqual(to other: AnyShapeStyleBox) -> Bool {
        let otherBox = other as? Self
        return otherBox.map { compareValues(base, $0.base) } ?? false
    }
}
