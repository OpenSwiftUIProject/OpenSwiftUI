//
//  GraphicsConversions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
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
            let filter = CAFilter(key: .gaussianBlur)
            filter.setInput(value: NSNumber(value: style.radius), key: .radius)
            filter.setInput(value: NSNumber(value: style.isOpaque), key: .normalizeEdges)
            filter.setInput(value: NSNumber(value: style.dither), key: .dither)
            return filter
        case let .variableBlur(style):
            let filter = CAFilter(key: .variableBlur)
            filter.setInput(value: NSNumber(value: style.caFilterRadius), key: .radius)
            filter.setInput(value: NSNumber(value: style.isOpaque), key: .normalizeEdges)
            filter.setInput(value: NSNumber(value: style.dither), key: .dither)
            if case let .image(image) = style.mask,
               let mask = image.render(at: image.size) {
                filter.setInput(value: mask, key: .maskImage)
            }
            return filter
        case .averageColor:
            return CAFilter(key: .averageColor)
        case let .colorMatrix(matrix, premultiplied):
            let filter = CAFilter(key: .colorMatrix)
            filter.setInput(value: NSValue(caColorMatrix: matrix.caColorMatrix), key: .colorMatrix)
            filter.setInput(value: NSNumber(value: premultiplied), key: .premultipliedValues)
            return filter
        case let .colorMultiply(color):
            let filter = CAFilter(key: .multiplyColor)
            filter.setInput(value: color.cgColor, key: .color)
            return filter
        case let .hueRotation(angle):
            let filter = CAFilter(key: .colorHueRotate)
            filter.setInput(value: NSNumber(value: angle.radians), key: .angle)
            return filter
        case let .saturation(amount):
            let filter = CAFilter(key: .colorSaturate)
            filter.setInput(value: NSNumber(value: amount), key: .amount)
            return filter
        case let .brightness(amount):
            let filter = CAFilter(key: .colorBrightness)
            filter.setInput(value: NSNumber(value: amount), key: .amount)
            return filter
        case let .contrast(amount):
            let filter = CAFilter(key: .colorContrast)
            filter.setInput(value: NSNumber(value: amount), key: .amount)
            return filter
        case .luminanceToAlpha:
            return CAFilter(key: .luminanceToAlpha)
        case .colorInvert:
            return CAFilter(key: .colorInvert)
        case let .grayscale(amount):
            let filter = CAFilter(key: .colorMonochrome)
            filter.setInput(value: NSNumber(value: amount), key: .amount)
            return filter
        case let .colorMonochrome(monochrome):
            let filter = CAFilter(key: .colorMonochrome)
            filter.setInput(value: monochrome.color.cgColor, key: .color)
            filter.setInput(value: NSNumber(value: monochrome.amount), key: .amount)
            filter.setInput(value: NSNumber(value: monochrome.bias), key: .bias)
            return filter
        case let .vibrantColorMatrix(matrix):
            let filter = CAFilter(key: .vibrantColorMatrix)
            filter.setInput(value: NSValue(caColorMatrix: matrix.caColorMatrix), key: .colorMatrix)
            return filter
        case let .luminanceCurve(curve):
            let filter = CAFilter(key: .luminanceCurveMap)
            filter.setInput(value: curve.curve.caFilterValues, key: .values)
            filter.setInput(value: NSNumber(value: curve.amount), key: .amount)
            return filter
        case let .colorCurves(curves):
            let filter = CAFilter(key: .curves)
            filter.setInput(value: curves.redCurve.caFilterValues, key: .redValues)
            filter.setInput(value: curves.greenCurve.caFilterValues, key: .greenValues)
            filter.setInput(value: curves.blueCurve.caFilterValues, key: .blueValues)
            filter.setInput(value: curves.opacityCurve.caFilterValues, key: .alphaValues)
            return filter
        case let .alphaThreshold(threshold):
            let filter = CAFilter(key: .alphaThreshold)
            filter.setInput(value: threshold.color.cgColor, key: .color)
            filter.setInput(value: NSNumber(value: threshold.amount), key: .amount)
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
