//
//  ShapeLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: E19F490D25D5E0EC8A24903AF958E341 (SwiftUICore)

import Foundation
import OpenQuartzCoreShims
import OpenSwiftUI_SPI
import UIFoundation_Private
// import OpenRenderBoxShims

// MARK: - ShapeLayerHelper [WIP]

struct ShapeLayerHelper: ResolvedPaintVisitor {
    struct Visitor: ResolvedPaintVisitor {
        var shapeType: ShapeType
        var mayClip: Bool
        var requiredType: CALayer.Type?

        mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
            _openSwiftUIUnimplementedFailure()
        }
    }

    var layer: CALayer
    var layerType: CALayer.Type
    var path: Path
    var origin: CGPoint
    var paint: AnyResolvedPaint
    var paintBounds: CGRect
    var style: FillStyle
    var contentsScale: CGFloat
    var mayClip: Bool

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        _openSwiftUIUnimplementedFailure()
    }

    static func makeLayerBounds(
        size: CGSize,
        path: Path,
        layerType: CALayer.Type,
        contentsScale: CGFloat
    ) -> CGRect {
        _openSwiftUIUnimplementedFailure()
    }

    static func updateAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        old: UnsafeMutablePointer<ShapeLayerHelper>,
        new: UnsafeMutablePointer<ShapeLayerHelper>
    ) -> Bool {
        guard old.pointee.style.isEOFilled == new.pointee.style.isEOFilled,
              old.pointee.style.isAntialiased == new.pointee.style.isAntialiased,
              old.pointee.mayClip == new.pointee.mayClip
        else {
            return false
        }
        return withUnsafeMutablePointer(to: &layer) { layer in
            var helper = ShapeLayerAsyncHelper(layer: layer, old: old, new: new, result: false)
            old.pointee.paint.visit(&helper)
            return helper.result
        }
    }
}

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

    @inline(__always)
    static func updateAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        old: UnsafeMutablePointer<ShapeLayerShadowHelper>,
        new: UnsafeMutablePointer<ShapeLayerShadowHelper>,
        oldPaint: AnyResolvedPaint,
        newPaint: AnyResolvedPaint
    ) -> Bool {
        return withUnsafeMutablePointer(to: &layer) { layer in
            var helper = ShapeLayerAsyncShadowHelper(
                layer: layer,
                old: old,
                new: new,
                newPaint: newPaint,
                result: false
            )
            oldPaint.visit(&helper)
            return helper.result
        }
    }
}

func _updateShadowAsync(
    layer: inout DisplayList.ViewUpdater.AsyncLayer,
    oldShadow: ResolvedShadowStyle?,
    newShadow: ResolvedShadowStyle?,
    oldPaintOpacity: Float,
    newPaintOpacity: Float
) -> Bool {
    var oldShadow = oldShadow
    var newShadow = newShadow
    if var shadow = oldShadow {
        shadow.color = shadow.color.multiplyingOpacity(by: oldPaintOpacity)
        oldShadow = shadow
    }
    if var shadow = newShadow {
        shadow.color = shadow.color.multiplyingOpacity(by: newPaintOpacity)
        newShadow = shadow
    }
    return layer.updateShadowStyle(oldShadow: oldShadow, newShadow: newShadow)
}

// MARK: - Async Shape Helpers

private struct ShapeLayerAsyncHelper: ResolvedPaintVisitor {
    var layer: UnsafeMutablePointer<DisplayList.ViewUpdater.AsyncLayer>
    var old: UnsafeMutablePointer<ShapeLayerHelper>
    var new: UnsafeMutablePointer<ShapeLayerHelper>
    var result: Bool

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        _openSwiftUIUnimplementedFailure()
    }
}

private struct ShapeLayerAsyncShadowHelper: ResolvedPaintVisitor {
    var layer: UnsafeMutablePointer<DisplayList.ViewUpdater.AsyncLayer>
    var old: UnsafeMutablePointer<ShapeLayerShadowHelper>
    var new: UnsafeMutablePointer<ShapeLayerShadowHelper>
    var newPaint: AnyResolvedPaint
    var result: Bool

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - AsyncLayer + shadow

extension DisplayList.ViewUpdater.AsyncLayer {
    @discardableResult
    mutating func updateShadowStyle(
        oldShadow: ResolvedShadowStyle?,
        newShadow: ResolvedShadowStyle?
    ) -> Bool {
        switch (oldShadow, newShadow) {
        case (nil, nil):
            return true
        case let (oldShadow?, newShadow?) where oldShadow.kind == newShadow.kind:
            update(DisplayList.ViewUpdater.ShadowOffsetProperty.self, from: oldShadow.offset, to: newShadow.offset)
            update(DisplayList.ViewUpdater.ShadowRadiusProperty.self, from: oldShadow.radius, to: newShadow.radius)
            update(DisplayList.ViewUpdater.ShadowColorProperty.self, from: oldShadow.color, to: newShadow.color)
            return true
        default:
            return false
        }
    }
}

extension DisplayList.ViewUpdater {
    struct ShadowOffsetProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
        static let keyPath = "shadowOffset"

        static func boxValue(_ value: CGSize) -> NSObject {
            #if canImport(Darwin)
            NSValue(cgSize: value)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }
    
    struct ShadowRadiusProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
        static let keyPath = "shadowRadius"

        static func boxValue(_ value: Double) -> NSObject {
            NSNumber(value: value)
        }
    }

    struct ShadowColorProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
        static let keyPath = "shadowColor"

        static func boxValue(_ value: Color.Resolved) -> NSObject {
            #if canImport(Darwin)
            unsafeDowncast(value.cgColor, to: NSObject.self)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }
}

// MARK: - ShapeType [WIP]

enum ShapeType {
    case rect(CGRect, radius: CGFloat, style: RoundedCornerStyle)
    case rectBorder(CGRect, radius: CGFloat, style: RoundedCornerStyle, lineWidth: CGFloat)
    case strokedPath(Path, style: StrokeStyle)
    case empty
    case other

    init(_ path: Path) {
        _openSwiftUIUnimplementedFailure()
    }

//    private func initFromFilled(
//        type: ORBPathShapeType,
//        shape: UnsafePointer<ORBPathShape>
//    ) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    private func initFromStroked(
//        type: ORBPathShapeType,
//        shape: UnsafePointer<ORBPathShape>,
//        style: StrokeStyle
//    ) {
//        _openSwiftUIUnimplementedFailure()
//    }
}
