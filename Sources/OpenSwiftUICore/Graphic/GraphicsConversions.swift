//
//  GraphicsConversions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 07401C2C9845FAA2984B0D65D34F2B64 (SwiftUICore)

import Foundation
#if canImport(QuartzCore)
import QuartzCore_Private
#endif

extension [GraphicsFilter] {
    @inline(__always)
    package func caFilters() -> [Any]? {
        #if canImport(QuartzCore)
        let caFilters = CAFilterArrayCreate()
        for filter in self {
            guard let caFilter = filter.makeCAFilter() else {
                continue
            }
            CAFilterArrayAppend(caFilters, caFilter)
        }
        return caFilters as? [Any]
        #else
        return nil
        #endif
    }
}

#if canImport(QuartzCore)
extension GraphicsFilter {
    fileprivate func makeCAFilter() -> CAFilter? {
        switch self {
        case let .blur(style):
            let filter = CAFilterCreate(.gaussianBlur)
            CAFilterSetInput(filter, NSNumber(value: style.radius), .radius)
            CAFilterSetInput(filter, NSNumber(value: style.isOpaque), .normalizeEdges)
            CAFilterSetInput(filter, NSNumber(value: style.dither), .dither)
            return filter
        case let .variableBlur(style):
            let filter = CAFilterCreate(.variableBlur)
            CAFilterSetInput(filter, NSNumber(value: style.caFilterRadius), .radius)
            CAFilterSetInput(filter, NSNumber(value: style.isOpaque), .normalizeEdges)
            CAFilterSetInput(filter, NSNumber(value: style.dither), .dither)
            if case let .image(image) = style.mask,
               let mask = image.render(at: image.size) {
                CAFilterSetInput(filter, mask, .maskImage)
            }
            return filter
        case .averageColor:
            return CAFilterCreate(.averageColor)
        case let .colorMatrix(matrix, premultiplied):
            let filter = CAFilterCreate(.colorMatrix)
            CAFilterSetInput(filter, NSValue(caColorMatrix: matrix.caColorMatrix), .colorMatrix)
            CAFilterSetInput(filter, NSNumber(value: premultiplied), .premultipliedValues)
            return filter
        case let .colorMultiply(color):
            let filter = CAFilterCreate(.multiplyColor)
            CAFilterSetInput(filter, color.cgColor, .color)
            return filter
        case let .hueRotation(angle):
            let filter = CAFilterCreate(.colorHueRotate)
            CAFilterSetInput(filter, NSNumber(value: angle.radians), .angle)
            return filter
        case let .saturation(amount):
            let filter = CAFilterCreate(.colorSaturate)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case let .brightness(amount):
            let filter = CAFilterCreate(.colorBrightness)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case let .contrast(amount):
            let filter = CAFilterCreate(.colorContrast)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case .luminanceToAlpha:
            return CAFilterCreate(.luminanceToAlpha)
        case .colorInvert:
            return CAFilterCreate(.colorInvert)
        case let .grayscale(amount):
            let filter = CAFilterCreate(.colorMonochrome)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case let .colorMonochrome(monochrome):
            let filter = CAFilterCreate(.colorMonochrome)
            CAFilterSetInput(filter, monochrome.color.cgColor, .color)
            CAFilterSetInput(filter, NSNumber(value: monochrome.amount), .amount)
            CAFilterSetInput(filter, NSNumber(value: monochrome.bias), .bias)
            return filter
        case let .vibrantColorMatrix(matrix):
            let filter = CAFilterCreate(.vibrantColorMatrix)
            CAFilterSetInput(filter, NSValue(caColorMatrix: matrix.caColorMatrix), .colorMatrix)
            return filter
        case let .luminanceCurve(curve):
            let filter = CAFilterCreate(.luminanceCurveMap)
            CAFilterSetInput(filter, curve.curve.caFilterValues, .values)
            CAFilterSetInput(filter, NSNumber(value: curve.amount), .amount)
            return filter
        case let .colorCurves(curves):
            let filter = CAFilterCreate(.curves)
            CAFilterSetInput(filter, curves.redCurve.caFilterValues, .redValues)
            CAFilterSetInput(filter, curves.greenCurve.caFilterValues, .greenValues)
            CAFilterSetInput(filter, curves.blueCurve.caFilterValues, .blueValues)
            CAFilterSetInput(filter, curves.opacityCurve.caFilterValues, .alphaValues)
            return filter
        case let .alphaThreshold(threshold):
            let filter = CAFilterCreate(.alphaThreshold)
            CAFilterSetInput(filter, threshold.color.cgColor, .color)
            CAFilterSetInput(filter, NSNumber(value: threshold.amount), .amount)
            return filter
        case .shadow, .projection, .shader:
            _openSwiftUIUnimplementedFailure()
        }
    }
}

extension GraphicsFilter.Curve {
    fileprivate var caFilterValues: [NSNumber] {
        let values = values
        return [
            NSNumber(value: values.0),
            NSNumber(value: values.1),
            NSNumber(value: values.2),
            NSNumber(value: values.3),
        ]
    }
}
#endif
