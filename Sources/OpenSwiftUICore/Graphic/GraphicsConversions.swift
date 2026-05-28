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
            let filter = CAFilterCreate(10)
            CAFilterSetInput(filter, NSNumber(value: style.radius), .radius)
            CAFilterSetInput(filter, NSNumber(value: style.isOpaque), .normalizeEdges)
            CAFilterSetInput(filter, NSNumber(value: style.dither), .dither)
            return filter
        case let .variableBlur(style):
            let filter = CAFilterCreate(14)
            CAFilterSetInput(filter, NSNumber(value: style.caFilterRadius), .radius)
            CAFilterSetInput(filter, NSNumber(value: style.isOpaque), .normalizeEdges)
            CAFilterSetInput(filter, NSNumber(value: style.dither), .dither)
            if case let .image(image) = style.mask,
               let mask = image.render(at: image.size) {
                CAFilterSetInput(filter, mask, .maskImage)
            }
            return filter
        case .averageColor:
            return CAFilterCreate(1)
        case let .colorMatrix(matrix, premultiplied):
            let filter = CAFilterCreate(6)
            CAFilterSetInput(filter, NSValue(caColorMatrix: matrix.caColorMatrix), .colorMatrix)
            CAFilterSetInput(filter, NSNumber(value: premultiplied), .premultipliedValues)
            return filter
        case let .colorMultiply(color):
            let filter = CAFilterCreate(13)
            CAFilterSetInput(filter, color.cgColor, .color)
            return filter
        case let .hueRotation(angle):
            let filter = CAFilterCreate(4)
            CAFilterSetInput(filter, NSNumber(value: angle.radians), .angle)
            return filter
        case let .saturation(amount):
            let filter = CAFilterCreate(8)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case let .brightness(amount):
            let filter = CAFilterCreate(2)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case let .contrast(amount):
            let filter = CAFilterCreate(3)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case .luminanceToAlpha:
            return CAFilterCreate(12)
        case .colorInvert:
            return CAFilterCreate(5)
        case let .grayscale(amount):
            let filter = CAFilterCreate(7)
            CAFilterSetInput(filter, NSNumber(value: amount), .amount)
            return filter
        case let .colorMonochrome(monochrome):
            let filter = CAFilterCreate(7)
            CAFilterSetInput(filter, monochrome.color.cgColor, .color)
            CAFilterSetInput(filter, NSNumber(value: monochrome.amount), .amount)
            CAFilterSetInput(filter, NSNumber(value: monochrome.bias), .bias)
            return filter
        case let .vibrantColorMatrix(matrix):
            let filter = CAFilterCreate(15)
            CAFilterSetInput(filter, NSValue(caColorMatrix: matrix.caColorMatrix), .colorMatrix)
            return filter
        case let .luminanceCurve(curve):
            let filter = CAFilterCreate(11)
            CAFilterSetInput(filter, curve.curve.caFilterValues, .values)
            CAFilterSetInput(filter, NSNumber(value: curve.amount), .amount)
            return filter
        case let .colorCurves(curves):
            let filter = CAFilterCreate(9)
            CAFilterSetInput(filter, curves.redCurve.caFilterValues, .redValues)
            CAFilterSetInput(filter, curves.greenCurve.caFilterValues, .greenValues)
            CAFilterSetInput(filter, curves.blueCurve.caFilterValues, .blueValues)
            CAFilterSetInput(filter, curves.opacityCurve.caFilterValues, .alphaValues)
            return filter
        case let .alphaThreshold(threshold):
            let filter = CAFilterCreate(0)
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
