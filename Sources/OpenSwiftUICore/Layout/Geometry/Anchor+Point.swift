//
//  Anchor+Point.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims

extension CGPoint: AnchorProtocol {
    package static var defaultAnchor: CGPoint {
        .zero
    }

    package func prepare(geometry: AnchorGeometry) -> CGPoint {
        var point = self
        point.convert(to: .global, transform: geometry.transform)
        return point
    }

    package static func hashValue(_ value: CGPoint, into hasher: inout Hasher) {
        hasher.combine(value.x)
        hasher.combine(value.y)
    }
}

extension UnitPoint: AnchorProtocol {
    package static var defaultAnchor: CGPoint {
        .zero
    }

    package func prepare(geometry: AnchorGeometry) -> CGPoint {
        let point = `in`(geometry.size)
        return point.prepare(geometry: geometry)
    }

    package static func hashValue(_ value: CGPoint, into hasher: inout Hasher) {
        hasher.combine(value.x)
        hasher.combine(value.y)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Anchor.Source where Value == CGPoint {
    public static func point(_ p: CGPoint) -> Anchor<Value>.Source {
        .init(anchor: p)
    }

    public static func unitPoint(_ p: UnitPoint) -> Anchor<Value>.Source {
        .init(anchor: p)
    }

    public static var topLeading: Anchor<CGPoint>.Source {
        unitPoint(.topLeading)
    }

    public static var top: Anchor<CGPoint>.Source {
        unitPoint(.top)
    }

    public static var topTrailing: Anchor<CGPoint>.Source {
        unitPoint(.topTrailing)
    }

    public static var leading: Anchor<CGPoint>.Source {
        unitPoint(.leading)
    }

    public static var center: Anchor<CGPoint>.Source {
        unitPoint(.center)
    }

    public static var trailing: Anchor<CGPoint>.Source {
        unitPoint(.trailing)
    }

    public static var bottomLeading: Anchor<CGPoint>.Source {
        unitPoint(.bottomLeading)
    }

    public static var bottom: Anchor<CGPoint>.Source {
        unitPoint(.bottom)
    }

    public static var bottomTrailing: Anchor<CGPoint>.Source {
        unitPoint(.bottomTrailing)
    }
}
