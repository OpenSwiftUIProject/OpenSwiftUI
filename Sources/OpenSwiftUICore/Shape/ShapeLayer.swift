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
            // TBA
            requiredType = ShapeLayerHelper.layerType(
                for: shapeType,
                paint: paint
            )
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
        // TBA
        let shapeType = ShapeType(path)
        let requiredType = Self.layerType(for: shapeType, paint: paint)
        guard layerType == requiredType else {
            layerType = requiredType
            return
        }

        #if canImport(QuartzCore)
        let color = (paint as? Color.Resolved)
            ?? (paint as? AnchoredResolvedPaint<Color.Resolved>)?.paint
        guard let color else {
            layer.backgroundColor = nil
            layer.borderColor = nil
            layer.borderWidth = 0
            layer.contents = nil
            _openSwiftUIUnimplementedWarning()
            return
        }

        layer.contentsScale = contentsScale
        switch shapeType {
        case let .rect(_, radius, cornerStyle):
            layer.backgroundColor = color.cgColor
            layer.borderColor = nil
            layer.borderWidth = 0
            layer.cornerRadius = radius
            layer.cornerCurve = cornerStyle == .continuous ? .continuous : .circular
        case let .rectBorder(_, radius, cornerStyle, lineWidth):
            layer.backgroundColor = nil
            layer.borderColor = color.cgColor
            layer.borderWidth = lineWidth
            layer.cornerRadius = radius
            layer.cornerCurve = cornerStyle == .continuous ? .continuous : .circular
        case let .strokedPath(strokedPath, strokeStyle):
            guard let shapeLayer = layer as? CAShapeLayer else {
                return
            }
            let path = origin == .zero ? strokedPath : strokedPath.applying(
                CGAffineTransform(translationX: -origin.x, y: -origin.y)
            )
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = nil
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineWidth = strokeStyle.lineWidth
            shapeLayer.lineCap = switch strokeStyle.lineCap {
            case .round: .round
            case .square: .square
            default: .butt
            }
            shapeLayer.lineJoin = switch strokeStyle.lineJoin {
            case .round: .round
            case .bevel: .bevel
            default: .miter
            }
            shapeLayer.miterLimit = strokeStyle.miterLimit
            shapeLayer.lineDashPattern = strokeStyle.dash.map { NSNumber(value: Double($0)) }
            shapeLayer.lineDashPhase = strokeStyle.dashPhase
        case .empty:
            layer.backgroundColor = nil
            layer.borderColor = nil
            layer.borderWidth = 0
            layer.cornerRadius = 0
        case .other:
            guard let shapeLayer = layer as? CAShapeLayer else {
                return
            }
            let path = origin == .zero ? self.path : self.path.applying(
                CGAffineTransform(translationX: -origin.x, y: -origin.y)
            )
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = color.cgColor
            shapeLayer.fillRule = style.isEOFilled ? .evenOdd : .nonZero
            shapeLayer.strokeColor = nil
            shapeLayer.lineDashPattern = nil
            shapeLayer.lineWidth = 0
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    static func makeLayerBounds(
        size: CGSize,
        path: Path,
        layerType: CALayer.Type,
        contentsScale: CGFloat
    ) -> CGRect {
        // TBA
        #if canImport(QuartzCore)
        if layerType is CAShapeLayer.Type {
            return CGRect(origin: .zero, size: size)
        }
        #endif
        _ = contentsScale
        let bounds = path.boundingRect
        return bounds.isNull ? .zero : bounds
    }

    private static func layerType<P>(
        for shapeType: ShapeType,
        paint: P
    ) -> CALayer.Type where P: ResolvedPaint {
        // TBA
        let isColor = paint is Color.Resolved
            || paint is AnchoredResolvedPaint<Color.Resolved>
        guard isColor else {
            return CALayer.self
        }
        switch shapeType {
        case .rect, .rectBorder, .empty:
            return CALayer.self
        case .strokedPath, .other:
            #if canImport(QuartzCore)
            return CAShapeLayer.self
            #else
            return CALayer.self
            #endif
        }
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
        guard let newPaint = new.pointee.paint.as(type: P.self) else {
            return
        }
        // FIXME: PaintType
        _openSwiftUIUnimplementedWarning()
        let oldColor = (paint as? Color.Resolved)
            ?? (paint as? AnchoredResolvedPaint<Color.Resolved>)?.paint
        let newColor = (newPaint as? Color.Resolved)
            ?? (newPaint as? AnchoredResolvedPaint<Color.Resolved>)?.paint
        guard let oldColor, let newColor else {
            return
        }
        switch (ShapeType(old.pointee.path), ShapeType(new.pointee.path)) {
        case let (
            .rect(_, oldRadius, oldCornerStyle),
            .rect(_, newRadius, newCornerStyle)
        ):
            switch (oldCornerStyle, newCornerStyle) {
            case (.circular, .circular), (.continuous, .continuous):
                break
            default:
                return
            }
            layer.pointee.update(
                DisplayList.ViewUpdater.BackgroundColor.self,
                from: oldColor,
                to: newColor
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.CornerRadiusLayer.self,
                from: oldRadius,
                to: newRadius
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.ContentsScale.self,
                from: old.pointee.contentsScale,
                to: new.pointee.contentsScale
            )
            result = true
        default:
            return
        }
    }
}

private struct ShapeLayerAsyncShadowHelper: ResolvedPaintVisitor {
    var layer: UnsafeMutablePointer<DisplayList.ViewUpdater.AsyncLayer>
    var old: UnsafeMutablePointer<ShapeLayerShadowHelper>
    var new: UnsafeMutablePointer<ShapeLayerShadowHelper>
    var newPaint: AnyResolvedPaint
    var result: Bool

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        guard let newPaint = newPaint.as(type: P.self) else {
            return
        }
        // FIXME: PaintType
        _openSwiftUIUnimplementedWarning()
        let oldColor = (paint as? Color.Resolved)
            ?? (paint as? AnchoredResolvedPaint<Color.Resolved>)?.paint
        let newColor = (newPaint as? Color.Resolved)
            ?? (newPaint as? AnchoredResolvedPaint<Color.Resolved>)?.paint
        guard let oldColor, let newColor else {
            return
        }
        result = _updateShadowAsync(
            layer: &layer.pointee,
            oldShadow: old.pointee.shadow,
            newShadow: new.pointee.shadow,
            oldPaintOpacity: oldColor.opacity,
            newPaintOpacity: newColor.opacity
        )
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
        // TBA
        switch path.storage {
        case .empty:
            self = .empty
        case let .rect(rect):
            self = .rect(rect, radius: 0, style: .circular)
        case let .ellipse(rect):
            guard rect.width == rect.height else {
                self = .other
                return
            }
            self = .rect(rect, radius: rect.width / 2, style: .circular)
        case let .roundedRect(roundedRect):
            guard roundedRect.isUniform else {
                self = .other
                return
            }
            self = .rect(
                roundedRect.rect,
                radius: roundedRect.clampedCornerRadius,
                style: roundedRect.style
            )
        case .stroked, .trimmed:
            self = .other
        case .path:
            // FIXME: initFromFilled
            self = .other
        }
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
