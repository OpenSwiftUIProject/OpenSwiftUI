//
//  DisplayListAsyncLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
import OpenQuartzCoreShims

protocol _DisplayList_ViewUpdater_AsyncLayerProperty {
    associatedtype Value

    static var keyPath: String { get }
    static var supportsPresentationModifier: Bool { get }
    static func boxValue(_ value: Value) -> NSObject
}

extension _DisplayList_ViewUpdater_AsyncLayerProperty {
    static var supportsPresentationModifier: Bool { true }
}

extension DisplayList.ViewUpdater {
    struct AsyncLayer {
        typealias Property = _DisplayList_ViewUpdater_AsyncLayerProperty

        var layer: CALayer
        let cache: UnsafeMutablePointer<DisplayList.ViewUpdater.ViewCache>
        let kind: PlatformViewDefinition.ViewKind
        let flags: DisplayList.ViewUpdater.Platform.ViewFlags
        var nextUpdate: Time
        var isInvalid: Bool

        @inline(__always)
        var isBoundsOriginEnabled: Bool {
            flags.contains(.boundsOrigin)
        }

        @inline(__always)
        var isAffineTransformEnabled: Bool {
            flags.contains(.affineTransform)
        }

        @inline(__always)
        var isProjectionGeometryEnabled: Bool {
            flags.contains(.projectionGeometry)
        }

        @inline(__always)
        var isClipRectEnabled: Bool {
            flags.contains(.clipRect)
        }

        @inline(__always)
        var isMaskLayerEnabled: Bool {
            flags.contains(.maskLayer)
        }

        @inline(__always)
        var isContentGeometryEnabled: Bool {
            flags.contains(.contentGeometry)
        }
    }
}
