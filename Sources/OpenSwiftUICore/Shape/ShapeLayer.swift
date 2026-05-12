//
//  ShapeLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: E19F490D25D5E0EC8A24903AF958E341 (SwiftUICore)

import OpenQuartzCoreShims

// MARK: - ShapeLayerShadowHelper [WIP]

struct ShapeLayerShadowHelper: ResolvedPaintVisitor {
    var platform: DisplayList.ViewUpdater.Platform
    var layer: CALayer
    var path: Path
    var offset: CGPoint
    var shadow: ResolvedShadowStyle
    var updateShape: Bool

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        _openSwiftUIUnimplementedFailure()
    }
}
