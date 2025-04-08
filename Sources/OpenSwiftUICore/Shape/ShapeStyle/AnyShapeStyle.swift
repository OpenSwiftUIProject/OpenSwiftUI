//
//  AnyShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: ABC85937500395B09974756E9F651929 (SwiftUI)
//  ID: C5308685324599C90E2F7A588812BB29 (SwiftUICore)

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
        type.result = .bool(true)
    }
    
    public typealias Resolved = Never
}

extension AnyShapeStyle.Storage: @unchecked Sendable {}

/// Abstract base class for type-erased ShapeStyle storage.
@usableFromInline
package class AnyShapeStyleBox {
    package func apply(to shape: inout _ShapeStyle_Shape) {}
    package func isEqual(to other: AnyShapeStyleBox) -> Bool { false }
}

@available(*, unavailable)
extension AnyShapeStyleBox: Sendable {}

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
