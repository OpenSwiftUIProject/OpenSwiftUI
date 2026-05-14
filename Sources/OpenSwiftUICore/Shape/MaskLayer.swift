//
//  MaskLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP (Async)
//  ID: A60BC6C4EC21A2F308B4F151783AE2A3 (SwiftUICore)

import Foundation
import OpenQuartzCoreShims
import OpenSwiftUI_SPI

#if canImport(QuartzCore)

// MARK: - MaskLayer

final class MaskLayer: CAShapeLayer {
    var clips: [DisplayList.ViewUpdater.Model.Clip] = []
    var clipTransform: CGAffineTransform = .init()

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setClips(_ clips: [DisplayList.ViewUpdater.Model.Clip], transform: CGAffineTransform) {
        self.clips = clips
        clipTransform = transform
        switch clips.count {
        case 0:
            path = nil
            sublayers = []
        case 1:
            Self.update(layer: self, clip: clips[0], transform: transform)
            sublayers = []
        default:
            path = nil
            var newSublayers = sublayers ?? []
            var sublayersChanged = false
            for (index, clip) in clips.enumerated() {
                let layer: CAShapeLayer
                if index < newSublayers.count {
                    layer = newSublayers[index] as! CAShapeLayer
                } else {
                    layer = CAShapeLayer()
                    layer.anchorPoint = .zero
                    layer.setNoAnimationDelegate()
                    newSublayers.append(layer)
                    sublayersChanged = true
                }
                Self.update(layer: layer, clip: clip, transform: transform)
                layer.compositingFilter = index == 0 ? nil : "sourceIn"
            }
            if newSublayers.count > clips.count {
                newSublayers.removeSubrange(clips.count..<newSublayers.count)
                sublayersChanged = true
            }
            if sublayersChanged {
                sublayers = newSublayers
            }
        }
    }

    private static func update(
        layer: CAShapeLayer,
        clip: DisplayList.ViewUpdater.Model.Clip,
        transform: CGAffineTransform
    ) {
        let shapeType = ShapeType(clip.path)
        let position: CGPoint
        switch shapeType {
        case let .rect(rect, radius, style):
            position = rect.origin
            layer.position = rect.origin
            layer.bounds = CGRect(origin: .zero, size: rect.size)
            layer.path = nil
            layer.cornerRadius = radius
            layer.cornerCurve = style == .continuous ? .continuous : .circular
            layer.borderWidth = 0
            layer.backgroundColor = layer.borderColor
        case let .rectBorder(rect, radius, style, lineWidth):
            position = rect.origin
            layer.position = rect.origin
            layer.bounds = CGRect(origin: .zero, size: rect.size)
            layer.path = nil
            layer.cornerRadius = radius
            layer.cornerCurve = style == .continuous ? .continuous : .circular
            layer.borderWidth = lineWidth
            layer.backgroundColor = nil
        case .strokedPath, .other:
            position = .zero
            layer.position = .zero
            layer.borderWidth = 0
            layer.backgroundColor = nil
            layer.path = clip.path.cgPath
            layer.fillRule = clip.style.isEOFilled ? .evenOdd : .nonZero
        case .empty:
            position = .zero
            layer.path = nil
            layer.borderWidth = 0
            layer.backgroundColor = nil
        }
        var finalTransform = clip.transform.map { $0.concatenating(transform) } ?? transform
        finalTransform.tx += position.x * finalTransform.a + position.y * finalTransform.c - position.x
        finalTransform.ty += position.x * finalTransform.b + position.y * finalTransform.d - position.y
        layer.setAffineTransform(finalTransform)
    }
    
    static func updateClipsAsync(
        layer: inout DisplayList.ViewUpdater.AsyncLayer,
        oldClips: [DisplayList.ViewUpdater.Model.Clip],
        newClips: [DisplayList.ViewUpdater.Model.Clip],
        oldTransform: CGAffineTransform,
        newTransform: CGAffineTransform
    ) -> Bool {
        _openSwiftUIUnimplementedWarning()
        return false
    }
}

#endif
