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

// FIXME: ShapeLayerShadowHelper & ShapeLayerAsyncShadowHelper

extension DisplayList.ViewUpdater.AsyncLayer {
    @discardableResult
    mutating func updateShadowStyle(
        oldShadow: ResolvedShadowStyle?,
        newShadow: ResolvedShadowStyle?
    ) -> Bool {
        switch (oldShadow, newShadow) {
        case (nil, nil):
            return true
        case let (oldShadow?, newShadow?):
            guard oldShadow.kind == newShadow.kind else {
                return false
            }
            update(ShadowOffsetProperty.self, from: oldShadow.offset, to: newShadow.offset)
            update(ShadowRadiusProperty.self, from: oldShadow.radius, to: newShadow.radius)
            update(ShadowColorProperty.self, from: oldShadow.color, to: newShadow.color)
            return !isInvalid
        default:
            return false
        }
    }

    private mutating func update<P>(
        _ property: P.Type,
        from oldValue: P.Value,
        to newValue: P.Value
    ) where P: Property, P.Value: Equatable {
        guard oldValue != newValue else {
            return
        }
        setValue(newValue, for: property)
    }

    private mutating func setValue<P>(
        _ value: P.Value,
        for property: P.Type
    ) where P: Property {
        guard !isInvalid else {
            return
        }
        cache.pointee.setAsyncValue(
            P.boxValue(value),
            for: P.keyPath,
            in: layer,
            usingPresentationModifier: P.supportsPresentationModifier
        )
    }
}

private struct ShadowColorProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
    static let keyPath = "shadowColor"

    static func boxValue(_ value: Color.Resolved) -> NSObject {
        #if canImport(Darwin)
        return value.cgColor as! NSObject
        #else
        return NSObject()
        #endif
    }
}

private struct ShadowRadiusProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
    static let keyPath = "shadowRadius"

    static func boxValue(_ value: CGFloat) -> NSObject {
        NSNumber(value: Double(value))
    }
}

private struct ShadowOffsetProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
    static let keyPath = "shadowOffset"

    static func boxValue(_ value: CGSize) -> NSObject {
        #if canImport(Darwin)
//        return NSValue(size: value)
        // FIXME
        return NSObject()
        #else
        return NSObject()
        #endif
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
