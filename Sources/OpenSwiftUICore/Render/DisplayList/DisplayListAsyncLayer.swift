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
    }
}

// FIXME: ShapeLayerShadowHelper & ShapeLayerAsyncShadowHelper

extension DisplayList.ViewUpdater.AsyncLayer {
    @discardableResult
    mutating func updateShadowStyle(
        oldShadow: ResolvedShadowStyle?,
        newShadow: ResolvedShadowStyle?
    ) -> Bool {
        switch (oldShadow, newShadow) {
        case (nil, nil):
            return true
        case let (oldShadow?, newShadow?):
            guard oldShadow.kind == newShadow.kind else {
                return false
            }
            update(ShadowOffsetProperty.self, from: oldShadow.offset, to: newShadow.offset)
            update(ShadowRadiusProperty.self, from: oldShadow.radius, to: newShadow.radius)
            update(ShadowColorProperty.self, from: oldShadow.color, to: newShadow.color)
            return !isInvalid
        default:
            return false
        }
    }

    private mutating func update<P>(
        _ property: P.Type,
        from oldValue: P.Value,
        to newValue: P.Value
    ) where P: Property, P.Value: Equatable {
        guard oldValue != newValue else {
            return
        }
        setValue(newValue, for: property)
    }

    private mutating func setValue<P>(
        _ value: P.Value,
        for property: P.Type
    ) where P: Property {
        guard !isInvalid else {
            return
        }
        cache.pointee.setAsyncValue(
            P.boxValue(value),
            for: P.keyPath,
            in: layer,
            usingPresentationModifier: P.supportsPresentationModifier
        )
    }
}

private struct ShadowColorProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
    static let keyPath = "shadowColor"

    static func boxValue(_ value: Color.Resolved) -> NSObject {
        #if canImport(Darwin)
        return value.cgColor as! NSObject
        #else
        return NSObject()
        #endif
    }
}

private struct ShadowRadiusProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
    static let keyPath = "shadowRadius"

    static func boxValue(_ value: CGFloat) -> NSObject {
        NSNumber(value: Double(value))
    }
}

private struct ShadowOffsetProperty: DisplayList.ViewUpdater.AsyncLayer.Property {
    static let keyPath = "shadowOffset"

    static func boxValue(_ value: CGSize) -> NSObject {
        #if canImport(Darwin)
//        return NSValue(size: value)
        // FIXME
        return NSObject()
        #else
        return NSObject()
        #endif
    }
}
