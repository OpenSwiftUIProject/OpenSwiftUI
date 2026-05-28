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
            return makeBlurFilter(
                type: 10,
                radius: style.radius,
                isOpaque: style.isOpaque,
                dither: style.dither
            )
        case let .variableBlur(style):
            let filter = makeBlurFilter(
                type: 14,
                radius: style.caFilterRadius,
                isOpaque: style.isOpaque,
                dither: style.dither
            )
            if case let .image(image) = style.mask,
               let mask = image.render(at: image.size) {
                CAFilterSetInput(filter, mask, 10)
            }
            return filter
        case .averageColor:
            return CAFilterCreate(1)
        case let .colorMatrix(matrix, premultiplied):
            let filter = makeColorMatrixFilter(type: 6, matrix: matrix)
            CAFilterSetInput(filter, NSNumber(value: premultiplied), 14)
            return filter
        case let .colorMultiply(color):
            let filter = CAFilterCreate(13)
            CAFilterSetInput(filter, color.cgColor, 5)
            return filter
        case let .hueRotation(angle):
            return makeScalarFilter(type: 4, key: 2, value: angle.radians)
        case let .saturation(amount):
            return makeScalarFilter(type: 8, key: 1, value: amount)
        case let .brightness(amount):
            return makeScalarFilter(type: 2, key: 1, value: amount)
        case let .contrast(amount):
            return makeScalarFilter(type: 3, key: 1, value: amount)
        case .luminanceToAlpha:
            return CAFilterCreate(12)
        case .colorInvert:
            return CAFilterCreate(5)
        case let .grayscale(amount):
            return makeScalarFilter(type: 7, key: 1, value: amount)
        case let .colorMonochrome(monochrome):
            let filter = CAFilterCreate(7)
            CAFilterSetInput(filter, monochrome.color.cgColor, 5)
            CAFilterSetInput(filter, NSNumber(value: monochrome.amount), 1)
            CAFilterSetInput(filter, NSNumber(value: monochrome.bias), 3)
            return filter
        case let .vibrantColorMatrix(matrix):
            return makeColorMatrixFilter(type: 15, matrix: matrix)
        case let .luminanceCurve(curve):
            let filter = CAFilterCreate(11)
            CAFilterSetInput(filter, curve.curve.caFilterValues, 17)
            CAFilterSetInput(filter, NSNumber(value: curve.amount), 1)
            return filter
        case let .colorCurves(curves):
            let filter = CAFilterCreate(9)
            CAFilterSetInput(filter, curves.redCurve.caFilterValues, 16)
            CAFilterSetInput(filter, curves.greenCurve.caFilterValues, 8)
            CAFilterSetInput(filter, curves.blueCurve.caFilterValues, 4)
            CAFilterSetInput(filter, curves.opacityCurve.caFilterValues, 0)
            return filter
        case let .alphaThreshold(threshold):
            let filter = CAFilterCreate(0)
            CAFilterSetInput(filter, threshold.color.cgColor, 5)
            CAFilterSetInput(filter, NSNumber(value: threshold.amount), 1)
            return filter
        case .shadow, .projection, .shader:
            _openSwiftUIUnimplementedFailure()
        }
    }

    @inline(__always)
    private func makeBlurFilter(
        type: UInt32,
        radius: CGFloat,
        isOpaque: Bool,
        dither: Bool
    ) -> CAFilter {
        let filter = CAFilterCreate(type)
        CAFilterSetInput(filter, NSNumber(value: radius), 15)
        CAFilterSetInput(filter, NSNumber(value: isOpaque), 11)
        CAFilterSetInput(filter, NSNumber(value: dither), 7)
        return filter
    }

    @inline(__always)
    private func makeScalarFilter(type: UInt32, key: UInt32, value: Double) -> CAFilter {
        let filter = CAFilterCreate(type)
        CAFilterSetInput(filter, NSNumber(value: value), key)
        return filter
    }

    @inline(__always)
    private func makeColorMatrixFilter(type: UInt32, matrix: _ColorMatrix) -> CAFilter {
        let filter = CAFilterCreate(type)
        CAFilterSetInput(filter, NSValue(caColorMatrix: matrix.caColorMatrix), 6)
        return filter
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
