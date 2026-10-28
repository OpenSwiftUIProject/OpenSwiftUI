//
//  ShapeLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP (Path classification and GraphicsContext rendering)
//  ID: E19F490D25D5E0EC8A24903AF958E341 (SwiftUICore)

import Foundation
import OpenQuartzCoreShims
import OpenSwiftUI_SPI
import UIFoundation_Private
// import OpenRenderBoxShims

// MARK: - ColorShapeLayer

#if canImport(QuartzCore)
private final class ColorShapeLayer: CAShapeLayer {
    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - PaintShapeLayer

private final class PaintShapeLayer: CALayer {
    var path = Path()
    var origin = CGPoint.zero
    var paint: AnyResolvedPaint?
    var paintBounds = CGRect.zero
    var fillStyle = FillStyle()

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func draw(in context: CGContext) {
        GraphicsContext.renderingTo(
            cgContext: context,
            environment: EnvironmentValues(),
            deviceScale: nil
        ) { context in
            context.translateBy(x: -origin.x, y: -origin.y)
            paint!.draw(
                path: path,
                style: .fill(fillStyle),
                in: context,
                bounds: paintBounds.offsetBy(dx: origin.x, dy: origin.y)
            )
        }
    }
}

// MARK: - UnclippedGradientLayer

private final class UnclippedGradientLayer: CALayer {
    override init() {
        super.init()
        let gradientLayer = GradientLayer()
        gradientLayer.anchorPoint = .zero
        gradientLayer.setNoAnimationDelegate()
        sublayers = [gradientLayer]
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func layoutSublayers() {
        sublayers![0].frame = bounds
    }
}
#endif

// MARK: - ShapeLayerHelper

struct ShapeLayerHelper: ResolvedPaintVisitor {
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
        let shapeType = ShapeType(path)
        let paintType = PaintType(paint)
        let requiredType = contentLayerType(shapeType, paintType, mayClip: mayClip)
        guard layerType == requiredType else {
            layerType = requiredType
            return
        }

        #if canImport(QuartzCore)
        layer.allowsEdgeAntialiasing = style.isAntialiased
        if case let .rect(rect, radius, cornerStyle) = shapeType {
            switch paintType {
            case let .linear(gradient):
                updateGradient(
                    gradient.gradient,
                    function: .linear(startPoint: gradient.startPoint, endPoint: gradient.endPoint),
                    size: rect.size, radius: radius, style: cornerStyle
                )
                return
            case let .radial(gradient):
                updateGradient(
                    gradient.gradient,
                    function: .radial(
                        center: gradient.center,
                        startRadius: gradient.startRadius,
                        endRadius: gradient.endRadius
                    ),
                    size: rect.size, radius: radius, style: cornerStyle
                )
                return
            case let .elliptical(gradient):
                updateGradient(
                    gradient.gradient,
                    function: .elliptical(
                        center: gradient.center,
                        startRadiusFraction: gradient.startRadiusFraction,
                        endRadiusFraction: gradient.endRadiusFraction
                    ),
                    size: rect.size, radius: radius, style: cornerStyle
                )
                return
            case let .angular(gradient):
                let conic = ConicGradient(angular: gradient, bounds: paintBounds)
                updateGradient(
                    conic.gradient,
                    function: .conic(center: gradient.center, angle: conic.angle),
                    size: rect.size, radius: radius, style: cornerStyle
                )
                return
            case .color, .other:
                break
            }
        }
        if case .empty = shapeType {
            layer.backgroundColor = nil
            layer.borderColor = nil
            layer.contents = nil
            return
        }
        guard case let .color(color) = paintType else {
            updateContent(
                shapeLayer: layer as! PaintShapeLayer,
                path: path,
                origin: origin,
                paint: self.paint,
                paintBounds: paintBounds,
                style: style,
                contentsScale: contentsScale
            )
            return
        }
        switch shapeType {
        case let .rect(_, radius, cornerStyle):
            layer.backgroundColor = color.cgColor
            layer.borderColor = nil
            layer.contents = nil
            layer.cornerRadius = radius
            layer.cornerCurve = cornerStyle == .continuous ? .continuous : .circular
        case let .rectBorder(_, radius, cornerStyle, lineWidth):
            updateContent(
                layer: layer, color: color, radius: radius,
                style: cornerStyle, lineWidth: lineWidth
            )
        case let .strokedPath(strokedPath, strokeStyle):
            updateContent(
                shapeLayer: layer as! ColorShapeLayer,
                color: color, strokedPath: strokedPath,
                origin: origin, style: strokeStyle
            )
        case .empty:
            break
        case .other:
            updateContent(
                shapeLayer: layer as! ColorShapeLayer,
                color: color, path: path, origin: origin,
                eoFill: style.isEOFilled
            )
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    #if canImport(QuartzCore)
    @inline(__always)
    private func updateGradient(
        _ gradient: ResolvedGradient,
        function: GradientLayer.Function,
        size: CGSize,
        radius: CGFloat,
        style: RoundedCornerStyle
    ) {
        let gradientLayer = (mayClip ? layer : layer.sublayers![0]) as! GradientLayer
        gradientLayer.cornerRadius = radius
        gradientLayer.cornerCurve = style == .continuous ? .continuous : .circular
        gradientLayer.update(gradient: gradient, function: function, size: size, bounds: paintBounds)
    }
    #endif

    static func makeLayerBounds(
        size: CGSize,
        path: Path,
        layerType: CALayer.Type,
        contentsScale: CGFloat
    ) -> CGRect {
        #if canImport(QuartzCore)
        if layerType == ColorShapeLayer.self {
            return CGRect(origin: .zero, size: size)
        }
        #endif
        var bounds = path.boundingRect
        if bounds.isNull {
            bounds = .zero
        }
        #if canImport(QuartzCore)
        if layerType == PaintShapeLayer.self {
            bounds.roundCoordinatesToNearestOrUp(toMultipleOf: 1 / contentsScale)
        }
        #endif
        return bounds
    }

    static func layerType(
        _ path: Path,
        _ paint: AnyResolvedPaint,
        mayClip: Bool
    ) -> CALayer.Type {
        struct Visitor: ResolvedPaintVisitor {
            var shapeType: ShapeType
            var mayClip: Bool
            var requiredType: CALayer.Type?

            mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
                requiredType = contentLayerType(
                    shapeType,
                    PaintType(paint),
                    mayClip: mayClip
                )
            }
        }
        var visitor = Visitor(shapeType: ShapeType(path), mayClip: mayClip)
        paint.visit(&visitor)
        return visitor.requiredType!
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

// MARK: - PaintType

private enum PaintType {
    case color(Color.Resolved)
    case linear(LinearGradient._Paint)
    case radial(RadialGradient._Paint)
    case elliptical(EllipticalGradient._Paint)
    case angular(AngularGradient._Paint)
    case other

    init<P>(_ paint: P) where P: ResolvedPaint {
        switch paint {
        case let color as Color.Resolved:
            self = .color(color)
        case let gradient as LinearGradient._Paint:
            self = gradient.gradient.constantColor.map(Self.color) ?? .linear(gradient)
        case let gradient as RadialGradient._Paint:
            self = gradient.gradient.constantColor.map(Self.color) ?? .radial(gradient)
        case let gradient as EllipticalGradient._Paint:
            self = gradient.gradient.constantColor.map(Self.color) ?? .elliptical(gradient)
        case let gradient as AngularGradient._Paint:
            self = gradient.gradient.constantColor.map(Self.color) ?? .angular(gradient)
        default:
            self = .other
        }
    }

    var isOpaque: Bool {
        switch self {
        case let .color(color): color.isOpaque
        case let .linear(paint): paint.gradient.isOpaque
        case let .radial(paint): paint.gradient.isOpaque
        case let .elliptical(paint): paint.gradient.isOpaque
        case let .angular(paint): paint.gradient.isOpaque
        case .other: false
        }
    }
}

// MARK: - Layer Selection

private func contentLayerType(
    _ shapeType: ShapeType,
    _ paintType: PaintType,
    mayClip: Bool
) -> CALayer.Type {
    #if canImport(QuartzCore)
    switch (shapeType, paintType) {
    case (.empty, _), (.rect, .color), (.rectBorder, .color):
        return CALayer.self
    case (.rect, .linear), (.rect, .radial), (.rect, .elliptical), (.rect, .angular):
        return mayClip ? GradientLayer.self : UnclippedGradientLayer.self
    case (.strokedPath, .color), (.other, .color):
        return ColorShapeLayer.self
    default:
        return PaintShapeLayer.self
    }
    #else
    return CALayer.self
    #endif
}

// MARK: - Content Updates

#if canImport(QuartzCore)
private func updateContent(
    layer: CALayer,
    color: Color.Resolved,
    radius: CGFloat,
    style: RoundedCornerStyle,
    lineWidth: CGFloat
) {
    layer.backgroundColor = nil
    layer.borderWidth = lineWidth
    layer.borderColor = color.cgColor
    layer.contents = nil
    layer.cornerRadius = radius
    layer.cornerCurve = style == .continuous ? .continuous : .circular
}

private func updateContent(
    shapeLayer: ColorShapeLayer,
    color: Color.Resolved,
    strokedPath: Path,
    origin: CGPoint,
    style: StrokeStyle
) {
    let path = origin == .zero ? strokedPath : strokedPath.applying(
        CGAffineTransform(translationX: -origin.x, y: -origin.y)
    )
    shapeLayer.path = path.cgPath
    shapeLayer.fillColor = Color.Resolved.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = style.lineWidth
    shapeLayer.miterLimit = style.miterLimit
    shapeLayer.lineCap = switch style.lineCap {
    case .round: .round
    case .square: .square
    default: .butt
    }
    shapeLayer.lineJoin = switch style.lineJoin {
    case .round: .round
    case .bevel: .bevel
    default: .miter
    }
    shapeLayer.lineDashPhase = style.dashPhase
    shapeLayer.lineDashPattern = style.dash.map { NSNumber(value: Double($0)) }
}

private func updateContent(
    shapeLayer: ColorShapeLayer,
    color: Color.Resolved,
    path: Path,
    origin: CGPoint,
    eoFill: Bool
) {
    let path = origin == .zero ? path : path.applying(
        CGAffineTransform(translationX: -origin.x, y: -origin.y)
    )
    shapeLayer.path = path.cgPath
    shapeLayer.fillColor = color.cgColor
    shapeLayer.fillRule = eoFill ? .evenOdd : .nonZero
    shapeLayer.strokeColor = nil
}

private func updateContent(
    shapeLayer: PaintShapeLayer,
    path: Path,
    origin: CGPoint,
    paint: AnyResolvedPaint,
    paintBounds: CGRect,
    style: FillStyle,
    contentsScale: CGFloat
) {
    shapeLayer.path = path
    shapeLayer.origin = origin
    shapeLayer.paint = paint
    shapeLayer.paintBounds = paintBounds
    shapeLayer.fillStyle = style
    shapeLayer.contentsScale = contentsScale
    shapeLayer.setNeedsDisplay()
}
#endif

// MARK: - ShapeLayerShadowHelper

struct ShapeLayerShadowHelper: ResolvedPaintVisitor {
    var platform: DisplayList.ViewUpdater.Platform
    var layer: CALayer
    var path: Path
    var offset: CGPoint
    var shadow: ResolvedShadowStyle
    var updateShape: Bool

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        #if canImport(QuartzCore)
        let shapeType = ShapeType(path)
        let paintType = PaintType(paint)
        switch (shapeType, paintType) {
        case (.empty, _):
            platform.setShadow(nil, layer: layer)
        case let (.rect, .color(color)):
            layer.shadowPathIsBounds = true
            layer.shadowPath = nil
            var shadow = shadow
            shadow.color.opacity *= color.opacity
            platform.setShadow(shadow, layer: layer)
        case (.rect, .linear), (.rect, .radial), (.rect, .elliptical), (.rect, .angular):
            updateShadow(
                platform: platform,
                gradientLayer: layer as! UnclippedGradientLayer,
                shadow: shadow,
                opaque: paintType.isOpaque
            )
        case let (_, .color(color)):
            updateShadow(
                platform: platform, layer: layer, shadow: shadow,
                paintOpacity: color.opacity, path: path, offset: offset
            )
        default:
            if paintType.isOpaque {
                updateShadow(
                    platform: platform, layer: layer, shadow: shadow,
                    paintOpacity: 1, path: path, offset: offset
                )
            } else {
                layer.shadowPathIsBounds = false
                layer.shadowPath = nil
                platform.setShadow(shadow, layer: layer)
            }
        }
        if updateShape {
            if case let .rect(_, radius, style) = shapeType {
                layer.cornerRadius = radius
                layer.cornerCurve = style == .continuous ? .continuous : .circular
            } else {
                layer.cornerRadius = 0
            }
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
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

// MARK: - Shadow Updates

#if canImport(QuartzCore)
private func updateShadow(
    platform: DisplayList.ViewUpdater.Platform,
    layer: CALayer,
    shadow: ResolvedShadowStyle?,
    paintOpacity: Float,
    path: Path,
    offset: CGPoint
) {
    var shadow = shadow
    if var value = shadow {
        let path = offset == .zero ? path : path.applying(
            CGAffineTransform(translationX: -offset.x, y: -offset.y)
        )
        layer.shadowPath = path.cgPath
        value.color.opacity *= paintOpacity
        shadow = value
    }
    platform.setShadow(shadow, layer: layer)
}

private func updateShadow(
    platform: DisplayList.ViewUpdater.Platform,
    gradientLayer: UnclippedGradientLayer,
    shadow: ResolvedShadowStyle?,
    opaque: Bool
) {
    if shadow != nil {
        let contentLayer = gradientLayer.sublayers![0]
        gradientLayer.shadowPathIsBounds = opaque
        gradientLayer.cornerRadius = contentLayer.cornerRadius
        gradientLayer.cornerCurve = contentLayer.cornerCurve
    }
    platform.setShadow(shadow, layer: gradientLayer)
}
#endif

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
        shadow.color.opacity *= oldPaintOpacity
        oldShadow = shadow
    }
    if var shadow = newShadow {
        shadow.color.opacity *= newPaintOpacity
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
        #if canImport(QuartzCore)
        let oldPaintType = PaintType(paint)
        let newPaintType = PaintType(newPaint)
        switch (ShapeType(old.pointee.path), ShapeType(new.pointee.path)) {
        case let (.rect(oldRect, oldRadius, oldStyle), .rect(newRect, newRadius, newStyle)):
            guard oldStyle == newStyle, updateContentAsync(
                layer: &layer.pointee,
                oldSize: oldRect.size,
                newSize: newRect.size,
                oldPaintType: oldPaintType,
                newPaintType: newPaintType,
                old: old,
                new: new
            ) else {
                return
            }
            layer.pointee.update(
                DisplayList.ViewUpdater.CornerRadiusLayer.self,
                from: oldRadius, to: newRadius
            )
            if layer.pointee.layer is UnclippedGradientLayer {
                var child = layer.pointee
                child.layer = child.layer.sublayers![0]
                child.update(
                    DisplayList.ViewUpdater.CornerRadiusLayer.self,
                    from: oldRadius, to: newRadius
                )
                child.update(
                    DisplayList.ViewUpdater.BoundsLayer.self,
                    from: CGRect(origin: .zero, size: oldRect.size),
                    to: CGRect(origin: .zero, size: newRect.size)
                )
            }
        case let (
            .rectBorder(_, oldRadius, oldStyle, oldWidth),
            .rectBorder(_, newRadius, newStyle, newWidth)
        ):
            guard oldStyle == newStyle,
                  case let .color(oldColor) = oldPaintType,
                  case let .color(newColor) = newPaintType else {
                return
            }
            layer.pointee.update(
                DisplayList.ViewUpdater.BorderColor.self, from: oldColor, to: newColor
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.BorderWidth.self, from: oldWidth, to: newWidth
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.CornerRadiusLayer.self,
                from: oldRadius,
                to: newRadius
            )
        case let (.strokedPath(oldPath, oldStyle), .strokedPath(newPath, newStyle)):
            guard oldStyle.lineCap == newStyle.lineCap,
                  oldStyle.lineJoin == newStyle.lineJoin,
                  case let .color(oldColor) = oldPaintType,
                  case let .color(newColor) = newPaintType else {
                return
            }
            _ = layer.pointee.layer as! ColorShapeLayer
            layer.pointee.update(
                DisplayList.ViewUpdater.ShapeStrokeColor.self, from: oldColor, to: newColor
            )
            updatePath(from: oldPath, to: newPath)
            layer.pointee.update(
                DisplayList.ViewUpdater.ShapeLineWidth.self,
                from: oldStyle.lineWidth, to: newStyle.lineWidth
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.ShapeMiterLimit.self,
                from: oldStyle.miterLimit, to: newStyle.miterLimit
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.ShapeLineDashPhase.self,
                from: oldStyle.dashPhase, to: newStyle.dashPhase
            )
            layer.pointee.update(
                DisplayList.ViewUpdater.ShapeLineDashPattern.self,
                from: oldStyle.dash, to: newStyle.dash
            )
        case (.empty, .empty):
            break
        case (.other, .other):
            guard case let .color(oldColor) = oldPaintType,
                  case let .color(newColor) = newPaintType else {
                return
            }
            _ = layer.pointee.layer as! ColorShapeLayer
            layer.pointee.update(
                DisplayList.ViewUpdater.ShapeFillColor.self, from: oldColor, to: newColor
            )
            updatePath(from: old.pointee.path, to: new.pointee.path)
        default:
            return
        }
        result = true
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
    }

    #if canImport(QuartzCore)
    @inline(__always)
    private func updatePath(from oldPath: Path, to newPath: Path) {
        let oldOrigin = old.pointee.origin
        let newOrigin = new.pointee.origin
        let oldPath = oldOrigin == .zero ? oldPath : oldPath.applying(
            CGAffineTransform(translationX: -oldOrigin.x, y: -oldOrigin.y)
        )
        let newPath = newOrigin == .zero ? newPath : newPath.applying(
            CGAffineTransform(translationX: -newOrigin.x, y: -newOrigin.y)
        )
        layer.pointee.update(DisplayList.ViewUpdater.ShapePath.self, from: oldPath, to: newPath)
    }
    #endif
}

// MARK: - Gradient Content Async Update

#if canImport(QuartzCore)
private func updateContentAsync(
    layer: inout DisplayList.ViewUpdater.AsyncLayer,
    oldSize: CGSize,
    newSize: CGSize,
    oldPaintType: PaintType,
    newPaintType: PaintType,
    old: UnsafeMutablePointer<ShapeLayerHelper>,
    new: UnsafeMutablePointer<ShapeLayerHelper>
) -> Bool {
    let oldGradient: ResolvedGradient
    let newGradient: ResolvedGradient
    let oldFunction: GradientLayer.Function
    let newFunction: GradientLayer.Function
    switch (oldPaintType, newPaintType) {
    case let (.color(oldColor), .color(newColor)):
        layer.update(DisplayList.ViewUpdater.BackgroundColor.self, from: oldColor, to: newColor)
        return true
    case let (.linear(oldPaint), .linear(newPaint)):
        oldGradient = oldPaint.gradient
        newGradient = newPaint.gradient
        oldFunction = .linear(startPoint: oldPaint.startPoint, endPoint: oldPaint.endPoint)
        newFunction = .linear(startPoint: newPaint.startPoint, endPoint: newPaint.endPoint)
    case let (.radial(oldPaint), .radial(newPaint)):
        oldGradient = oldPaint.gradient
        newGradient = newPaint.gradient
        oldFunction = .radial(
            center: oldPaint.center,
            startRadius: oldPaint.startRadius,
            endRadius: oldPaint.endRadius
        )
        newFunction = .radial(
            center: newPaint.center,
            startRadius: newPaint.startRadius,
            endRadius: newPaint.endRadius
        )
    case let (.elliptical(oldPaint), .elliptical(newPaint)):
        oldGradient = oldPaint.gradient
        newGradient = newPaint.gradient
        oldFunction = .elliptical(
            center: oldPaint.center,
            startRadiusFraction: oldPaint.startRadiusFraction,
            endRadiusFraction: oldPaint.endRadiusFraction
        )
        newFunction = .elliptical(
            center: newPaint.center,
            startRadiusFraction: newPaint.startRadiusFraction,
            endRadiusFraction: newPaint.endRadiusFraction
        )
    case let (.angular(oldPaint), .angular(newPaint)):
        let oldConic = ConicGradient(angular: oldPaint, bounds: old.pointee.paintBounds)
        let newConic = ConicGradient(angular: newPaint, bounds: new.pointee.paintBounds)
        oldGradient = oldConic.gradient
        newGradient = newConic.gradient
        oldFunction = .conic(center: oldPaint.center, angle: oldConic.angle)
        newFunction = .conic(center: newPaint.center, angle: newConic.angle)
    default:
        return false
    }
    var gradientLayer = layer
    gradientLayer.layer = new.pointee.mayClip ? new.pointee.layer : new.pointee.layer.sublayers![0]
    return GradientLayer.updateAsync(
        layer: &gradientLayer,
        oldSize: oldSize, newSize: newSize,
        oldFunction: oldFunction, newFunction: newFunction,
        oldGradient: oldGradient, newGradient: newGradient,
        oldBounds: old.pointee.paintBounds, newBounds: new.pointee.paintBounds
    )
}
#endif

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
        let oldPaintType = PaintType(paint)
        let newPaintType = PaintType(newPaint)
        switch (ShapeType(old.pointee.path), ShapeType(new.pointee.path)) {
        case (.empty, .empty):
            result = true
        case (.rect, .rect):
            switch (oldPaintType, newPaintType) {
            case let (.color(oldColor), .color(newColor)):
                result = _updateShadowAsync(
                    layer: &layer.pointee,
                    oldShadow: old.pointee.shadow,
                    newShadow: new.pointee.shadow,
                    oldPaintOpacity: oldColor.opacity,
                    newPaintOpacity: newColor.opacity
                )
            case (.linear, .linear), (.radial, .radial), (.elliptical, .elliptical), (.angular, .angular):
                guard oldPaintType.isOpaque == newPaintType.isOpaque else {
                    return
                }
                result = layer.pointee.updateShadowStyle(
                    oldShadow: old.pointee.shadow,
                    newShadow: new.pointee.shadow
                )
            default:
                return
            }
        default:
            return
        }
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
            unsafeDowncast(value.cgColor, to: NSObject.self)
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
            // TODO: Classify RenderBox paths with initFromFilled.
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
