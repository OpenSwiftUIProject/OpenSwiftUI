//
//  Anchor+Rect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims

// MARK: - CGRect + AnchorProtocol [TBA]

extension CGRect: AnchorProtocol {
    package static var defaultAnchor: CGRect {
        .zero
    }

    package func prepare(geometry: AnchorGeometry) -> CGRect {
        var rect = self
        rect.convert(to: .global, transform: geometry.transform)
        return rect
    }

    package static func hashValue(_ value: CGRect, into hasher: inout Hasher) {
        hasher.combine(value.origin.x)
        hasher.combine(value.origin.y)
        hasher.combine(value.size.width)
        hasher.combine(value.size.height)
    }
}

// MARK: - UnitRect + AnchorProtocol [TBA]

extension UnitRect: AnchorProtocol {
    package static var defaultAnchor: CGRect {
        .zero
    }

    package func prepare(geometry: AnchorGeometry) -> CGRect {
        let rect = `in`(geometry.size)
        return rect.prepare(geometry: geometry)
    }

    package static func hashValue(_ value: CGRect, into hasher: inout Hasher) {
        CGRect.hashValue(value, into: &hasher)
    }
}

// MARK: - Anchor.Source + CGRect [TBA]

@available(OpenSwiftUI_v1_0, *)
extension Anchor.Source where Value == CGRect {
    public static func rect(_ rect: CGRect) -> Anchor<Value>.Source {
        .init(anchor: rect)
    }

    public static var bounds: Anchor<CGRect>.Source {
        .init(anchor: UnitRect.one)
    }

    public static func unitPoint(_ point: UnitPoint) -> Anchor<Value>.Source {
        .init(anchor: UnitRect(point: point))
    }
}
