//
//  StrokeStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenCoreGraphicsShims
package import OpenRenderBoxShims

// MARK: - StrokeStyle

/// The characteristics of a stroke that traces a path.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct StrokeStyle: Equatable {
    /// The width of the stroked path.
    public var lineWidth: CGFloat

    /// The endpoint style of a line.
    public var lineCap: CGLineCap

    /// The join type of a line.
    public var lineJoin: CGLineJoin

    /// A threshold used to determine whether to use a bevel instead of a
    /// miter at a join.
    public var miterLimit: CGFloat

    /// The lengths of painted and unpainted segments used to make a dashed line.
    public var dash: [CGFloat]

    /// How far into the dash pattern the line starts.
    public var dashPhase: CGFloat

    /// Creates a new stroke style from the given components.
    ///
    /// - Parameters:
    ///   - lineWidth: The width of the segment.
    ///   - lineCap: The endpoint style of a segment.
    ///   - lineJoin: The join type of a segment.
    ///   - miterLimit: The threshold used to determine whether to use a bevel
    ///     instead of a miter at a join.
    ///   - dash: The lengths of painted and unpainted segments used to make a
    ///     dashed line.
    ///   - dashPhase: How far into the dash pattern the line starts.
    public init(lineWidth: CGFloat = 1, lineCap: CGLineCap = .butt, lineJoin: CGLineJoin = .miter, miterLimit: CGFloat = 10, dash: [CGFloat] = [CGFloat](), dashPhase: CGFloat = 0) {
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.lineJoin = lineJoin
        self.miterLimit = miterLimit
        self.dash = dash
        self.dashPhase = dashPhase
    }
}

// MARK: - StrokeStyle + Animatable

@available(OpenSwiftUI_v1_0, *)
extension StrokeStyle: Animatable {
    public var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(lineWidth, AnimatablePair(miterLimit, dashPhase))
        }
        set {
            lineWidth = newValue.first
            miterLimit = newValue.second.first
            dashPhase = newValue.second.second
        }
    }
}

// MARK: - StrokeStyle + ORB

extension StrokeStyle {
    @inline(__always)
    package init(_ style: ORBPathStrokeStyle) {
        var dash: [CGFloat] = []
        for i in 0 ..< Int(style.dashCount) {
            dash.append(style.dash![i])
        }
        self.init(
            lineWidth: style.lineWidth,
            lineCap: style.lineCap,
            lineJoin: style.lineJoin,
            miterLimit: style.miterLimit,
            dash: dash,
            dashPhase: style.dashPhase
        )
    }
}
