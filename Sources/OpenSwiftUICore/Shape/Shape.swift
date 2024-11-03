//
//  Shape.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

public import Foundation

/// A 2D shape that you can use when drawing a view.
///
/// Shapes without an explicit fill or stroke get a default fill based on the
/// foreground color.
///
/// You can define shapes in relation to an implicit frame of reference, such as
/// the natural size of the view that contains it. Alternatively, you can define
/// shapes in terms of absolute coordinates.
public protocol Shape: Animatable, View {
    /// Describes this shape as a path within a rectangular frame of reference.
    ///
    /// - Parameter rect: The frame of reference for describing this shape.
    ///
    /// - Returns: A path that describes this shape.
    func path(in rect: CGRect) -> Path
    
    #if OPENSWIFTUI_SUPPORT_2021_API
    /// An indication of how to style a shape.
    ///
    /// OpenSwiftUI looks at a shape's role when deciding how to apply a
    /// ``ShapeStyle`` at render time. The ``Shape`` protocol provides a
    /// default implementation with a value of ``ShapeRole/fill``. If you
    /// create a composite shape, you can provide an override of this property
    /// to return another value, if appropriate.
    static var role: ShapeRole { get }
    #endif
}

extension Shape {
    public var body: _ShapeView<Self, ForegroundStyle> {
        _ShapeView(shape: self, style: ForegroundStyle())
    }
}

#if OPENSWIFTUI_SUPPORT_2021_API

extension Shape {
    public static var role: ShapeRole {
        .fill
    }
}
#endif
