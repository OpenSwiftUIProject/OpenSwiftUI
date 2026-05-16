//
//  DisplayListAsyncLayer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
import OpenQuartzCoreShims
import UIFoundation_Private

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
        
        @inline(__always)
        mutating func update<P>(
            _ property: P.Type,
            from oldValue: P.Value,
            to newValue: P.Value
        ) where P: Property, P.Value: Equatable {
            guard oldValue != newValue else {
                return
            }
            setValue(P.self, to: newValue)
        }

        @inline(__always)
        mutating func setValue<P>(
            _ property: P.Type,
            to value: P.Value
        ) where P: Property {
            cache.pointee.setAsyncValue(
                P.boxValue(value),
                for: P.keyPath,
                in: layer,
                usingPresentationModifier: P.supportsPresentationModifier
            )
        }
    }
    
    // MARK: - AsyncLayer.Property
    
    struct BackgroundColor: AsyncLayer.Property {
        static let keyPath = "backgroundColor"

        static func boxValue(_ value: Color.Resolved) -> NSObject {
            #if canImport(Darwin)
            unsafeDowncast(value.cgColor, to: NSObject.self)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

    struct PositionLayer: AsyncLayer.Property {
        static let keyPath = "position"

        static func boxValue(_ value: CGPoint) -> NSObject {
            #if canImport(QuartzCore)
            NSValue(cgPoint: value)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

    struct BoundsLayer: AsyncLayer.Property {
        static let keyPath = "bounds"

        static func boxValue(_ value: CGRect) -> NSObject {
            #if canImport(QuartzCore)
            NSValue(cgRect: value)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

    struct AffineTransformLayer: AsyncLayer.Property {
        static let keyPath = "transform"

        static func boxValue(_ value: CGAffineTransform) -> NSObject {
            #if canImport(QuartzCore)
            NSValue(caTransform3D: CATransform3DMakeAffineTransform(value))
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

    struct LayerProjectionTransform: AsyncLayer.Property {
        static let keyPath = "transform"

        static func boxValue(_ value: ProjectionTransform) -> NSObject {
            #if canImport(QuartzCore)
            NSValue(caTransform3D: CATransform3D(value))
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

    struct OpacityLayer: AsyncLayer.Property {
        static let keyPath = "opacity"

        static func boxValue(_ value: Float) -> NSObject {
            NSNumber(value: value)
        }
    }

    struct CornerRadiusLayer: AsyncLayer.Property {
        static let keyPath = "cornerRadius"

        static func boxValue(_ value: CGFloat) -> NSObject {
            NSNumber(value: Double(value))
        }
    }

    struct ContentsMultiplyColor: AsyncLayer.Property {
        static let keyPath = "contentsMultiplyColor"

        static func boxValue(_ value: Color.Resolved?) -> NSObject {
            #if canImport(Darwin)
            guard let value else {
                return NSNull()
            }
            return unsafeDowncast(value.cgColor, to: NSObject.self)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
    }

}
