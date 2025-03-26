//
//  InsettableShape.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

public import Foundation

// MARK: - InsettableShape

/// A shape type that is able to inset itself to produce another shape.
public protocol InsettableShape: Shape {
    
    /// The type of the inset shape.
    associatedtype InsetShape: InsettableShape
    
    /// Returns `self` inset by `amount`.
    func inset(by amount: CGFloat) -> InsetShape
}

// MARK: - InsettableShape + Extension

extension InsettableShape {
    /// Returns a view that is the result of insetting `self` by
    /// `style.lineWidth / 2`, stroking the resulting shape with
    /// `style`, and then filling with `content`.
    @inlinable
    @_disfavoredOverload
    public func strokeBorder<S>(_ content: S, style: StrokeStyle, antialiased: Bool = true) -> some View where S: ShapeStyle {
        inset(by: style.lineWidth * 0.5)
             .stroke(style: style)
             .fill(content, style: FillStyle(antialiased: antialiased))
    }

    /// Returns a view that is the result of insetting `self` by
    /// `style.lineWidth / 2`, stroking the resulting shape with
    /// `style`, and then filling with the foreground color.
    @inlinable
    @_disfavoredOverload
    public func strokeBorder(style: StrokeStyle, antialiased: Bool = true) -> some View {
        inset(by: style.lineWidth * 0.5)
             .stroke(style: style)
             .fill(style: FillStyle(antialiased: antialiased))
    }

    /// Returns a view that is the result of filling the `lineWidth`-sized
    /// border (aka inner stroke) of `self` with `content`. This is
    /// equivalent to insetting `self` by `lineWidth / 2` and stroking the
    /// resulting shape with `lineWidth` as the line-width.
    @inlinable
    @_disfavoredOverload
    public func strokeBorder<S>(_ content: S, lineWidth: CGFloat = 1, antialiased: Bool = true) -> some View where S: ShapeStyle {
        strokeBorder(
            content,
            style: StrokeStyle(lineWidth: lineWidth),
            antialiased: antialiased
        )
    }

    /// Returns a view that is the result of filling the `lineWidth`-sized
    /// border (aka inner stroke) of `self` with the foreground color.
    /// This is equivalent to insetting `self` by `lineWidth / 2` and
    /// stroking the resulting shape with `lineWidth` as the line-width.
    @inlinable
    @_disfavoredOverload
    public func strokeBorder(lineWidth: CGFloat = 1, antialiased: Bool = true) -> some View {
        strokeBorder(
            style: StrokeStyle(lineWidth: lineWidth),
            antialiased: antialiased
        )
    }
}

// MARK: - Retangle + InsettableShape [TODO]
