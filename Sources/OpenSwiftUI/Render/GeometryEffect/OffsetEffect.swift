//
//  OffsetEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims
public import OpenSwiftUICore

// MARK: - VisualEffect + offset

@available(OpenSwiftUI_v5_0, *)
extension VisualEffect {
    /// Offsets the view by the horizontal and vertical amount specified in the
    /// offset parameter.
    ///
    /// - Parameter offset: The distance to offset the view.
    ///
    /// - Returns: An effect that offsets the view by `offset`.
    public func offset(_ offset: CGSize) -> some VisualEffect {
        geometryEffect(_OffsetEffect(offset: offset))
    }

    /// Offsets the view by the specified horizontal and vertical distances.
    ///
    /// - Parameters:
    ///   - x: The horizontal distance to offset the view.
    ///   - y: The vertical distance to offset the view.
    ///
    /// - Returns: An effect that offsets the view by `x` and `y`.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some VisualEffect {
        offset(CGSize(width: x, height: y))
    }
}

// MARK: - HoverEffectContent + offset

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    /// Offsets the view by the horizontal and vertical amount specified in the
    /// offset parameter.
    ///
    /// - Parameter offset: The distance to offset the view.
    ///
    /// - Returns: An effect that offsets the view by `offset`.
    public func offset(_ offset: CGSize) -> some HoverEffectContent {
        geometryEffect(_OffsetEffect(offset: offset))
    }

    /// Offsets the view by the specified horizontal and vertical distances.
    ///
    /// - Parameters:
    ///   - x: The horizontal distance to offset the view.
    ///   - y: The vertical distance to offset the view.
    ///
    /// - Returns: An effect that offsets the view by `x` and `y`.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> some HoverEffectContent {
        offset(CGSize(width: x, height: y))
    }
}
