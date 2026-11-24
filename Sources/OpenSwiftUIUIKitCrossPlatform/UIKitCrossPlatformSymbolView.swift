//
//  UIKitCrossPlatformSymbolView.swift
//  OpenSwiftUI

#if UIKIT_CROSS_PLATFORM
import Foundation
import UIKit
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore

final class UIKitCrossPlatformSymbolView: UIKitCrossPlatformView {
    struct Spec: Equatable {
        let name: String
        let pointSize: Foundation.CGFloat
        let weight: Foundation.CGFloat
        let color: Color.Resolved
    }

    var spec: Spec? {
        didSet {
            guard spec != oldValue else { return }
            if spec == nil { layer.contents = nil }
            layer.setNeedsDisplay()
            UIKit.CALayer.layerTreeIsDirty = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.setNeedsDisplay()
        UIKit.CALayer.layerTreeIsDirty = true
    }

    override func display(_ layer: UIKit.CALayer) {
        guard let spec, let screen = UIScreen.main else { return }
        let widthPoints = bounds.width > 0 ? bounds.width : Double(spec.pointSize)
        let heightPoints = bounds.height > 0 ? bounds.height : Double(spec.pointSize)
        guard widthPoints.isFinite, heightPoints.isFinite, widthPoints > 0, heightPoints > 0 else {
            layer.contents = nil
            return
        }
        let scale = min(max(screen.scale, 1.0), 512.0 / max(widthPoints, heightPoints))
        let width = max(1, Int(ceil(widthPoints * scale)))
        let height = max(1, Int(ceil(heightPoints * scale)))
        let bytes = Self.rasterize(spec: spec, width: width, height: height)
        layer.contents = bytes.withUnsafeBufferPointer {
            UIKit.CGImage.premultipliedRGBA($0.baseAddress!, width: width, height: height)
        }
    }

    @_optimize(speed)
    private static func rasterize(spec: Spec, width: Int, height: Int) -> [UInt8] {
        func clamp01(_ v: Float) -> Float { min(1, max(0, v)) }
        let baseAlpha = clamp01(spec.color.opacity)
        let pr = clamp01(spec.color.red) * baseAlpha
        let pg = clamp01(spec.color.green) * baseAlpha
        let pb = clamp01(spec.color.blue) * baseAlpha

        let weightBias = max(-0.4, min(0.6, Double(spec.weight)))
        let stroke = max(0.055, 0.082 + 0.03 * weightBias)
        let aa = 2.0 / Double(max(1, min(width, height)))

        return [UInt8](unsafeUninitializedCapacity: width * height * 4) { buffer, count in
            var idx = 0
            for py in 0..<height {
                let ny = ((Double(py) + 0.5) / Double(height)) * 2.0 - 1.0
                for px in 0..<width {
                    let nx = ((Double(px) + 0.5) / Double(width)) * 2.0 - 1.0
                    let sd = signedDistance(symbol: spec.name, x: nx, y: ny, stroke: stroke)
                    let cov = Float(min(1.0, max(0.0, 0.5 - sd / aa)))
                    buffer.initializeElement(at: idx, to: UInt8((pr * cov * 255).rounded()))
                    buffer.initializeElement(at: idx + 1, to: UInt8((pg * cov * 255).rounded()))
                    buffer.initializeElement(at: idx + 2, to: UInt8((pb * cov * 255).rounded()))
                    buffer.initializeElement(at: idx + 3, to: UInt8((baseAlpha * cov * 255).rounded()))
                    idx += 4
                }
            }
            count = idx
        }
    }

    @inline(__always)
    private static func segmentDistance(
        px: Double, py: Double,
        ax: Double, ay: Double,
        bx: Double, by: Double
    ) -> Double {
        let vx = bx - ax
        let vy = by - ay
        let wx = px - ax
        let wy = py - ay
        let len2 = vx * vx + vy * vy
        let t = len2 > 0 ? min(1.0, max(0.0, (wx * vx + wy * vy) / len2)) : 0.0
        return hypot(px - (ax + t * vx), py - (ay + t * vy))
    }

    private static func signedDistance(symbol: String, x: Double, y: Double, stroke: Double) -> Double {
        let half = stroke * 0.5
        switch symbol {
        case "globe":
            let r = 0.76
            let outer = abs(hypot(x, y) - r) - half
            let inside = hypot(x, y) - (r + half * 0.5)
            let equator = max(abs(y) - half * 0.85, inside)
            let meridian = max(abs(hypot(x / 0.44, y / r) - 1.0) * 0.55 - half * 0.85, inside)
            let centerAxis = max(abs(x) - half * 0.75, inside)
            return min(min(outer, equator), min(meridian, centerAxis))

        case "arrow.clockwise":
            let r = 0.62
            let distR = abs(hypot(x, y) - r) - half
            let theta = atan2(y, x) // -pi..pi, y down
            // Leave an opening in the upper-right quadrant (-0.85..-0.10 rad)
            let inGap = theta > -0.85 && theta < -0.08
            let arc = inGap ? 1.0 : distR
            // Arrowhead at the top-right end of the clockwise sweep (near angle -0.85)
            let tipX = r * cos(-0.22)
            let tipY = r * sin(-0.22)
            let wing1 = segmentDistance(px: x, py: y, ax: tipX, ay: tipY, bx: tipX - 0.34, by: tipY - 0.10) - half
            let wing2 = segmentDistance(px: x, py: y, ax: tipX, ay: tipY, bx: tipX + 0.06, by: tipY - 0.34) - half
            return min(arc, min(wing1, wing2))

        case "arrow.up.and.down.and.arrow.left.and.right":
            let reach = 0.74
            let head = 0.24
            let hBar = segmentDistance(px: x, py: y, ax: -reach, ay: 0, bx: reach, by: 0) - half * 0.85
            let vBar = segmentDistance(px: x, py: y, ax: 0, ay: -reach, bx: 0, by: reach) - half * 0.85
            let ax = abs(x)
            let ay = abs(y)
            let hTip = segmentDistance(px: ax, py: ay, ax: reach, ay: 0, bx: reach - head, by: head) - half * 0.85
            let vTip = segmentDistance(px: ax, py: ay, ax: 0, ay: reach, bx: head, by: reach - head) - half * 0.85
            return min(min(hBar, vBar), min(hTip, vTip))

        case "trophy.fill", "trophy":
            // Cup body, stem, and base
            let cupBox = max(abs(x) - 0.44, max(y - 0.08, -0.68 - y))
            let cupBottom = hypot(x, max(0, y + 0.05)) - 0.44
            let cup = y < -0.05 ? cupBox : min(cupBox, cupBottom)
            let stem = max(abs(x) - 0.10, max(y - 0.48, -0.05 - y))
            let base = max(abs(x) - 0.38, max(y - 0.68, 0.46 - y))
            let handles = max(abs(hypot(abs(x) - 0.42, y + 0.34) - 0.20) - half * 0.8, -0.42 - abs(x))
            return min(min(cup, stem), min(base, handles))

        default:
            return abs(hypot(x, y) - 0.64) - half
        }
    }
}
#endif
