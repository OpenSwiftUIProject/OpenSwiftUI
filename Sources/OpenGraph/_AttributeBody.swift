//
//  _AttributeBody.swift
//  OpenGraph
//
//  Created by Kyle on 2023/10/17.
//  Lastest Version: iOS 15.5
//  Status: Blocked by AttributeBodyVisitor

import _OpenGraph

public protocol _AttributeBody {
    static func _destroySelf(_ value: UnsafeMutableRawPointer)
    static var _hasDestroySelf: Bool { get }
    static func _updateDefault(_ value: UnsafeMutableRawPointer)
    static var comparisonMode: OGComparisonMode { get }
    #if !os(Linux)
    static var flags: OGAttributeTypeFlags { get }
    #endif
}

extension _AttributeBody {
    // TODO
//    public static func _visitBody<A1: AttributeBodyVisitor>(_ visitor: inout A1, _ body: UnsafeRawPointer) {
//    }

    public static func _destroySelf(_ value: UnsafeMutableRawPointer) {}

    public static var _hasDestroySelf: Bool { false }

    public static func _updateDefault(_ value: UnsafeMutableRawPointer) {}

    public static var comparisonMode: OGComparisonMode { ._2 }
    #if !os(Linux)
    public static var flags: OGAttributeTypeFlags { ._8 }
    #endif
}
