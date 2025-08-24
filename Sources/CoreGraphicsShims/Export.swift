//
//  Export.swift
//  CoreGraphicsShims

#if canImport(CoreGraphics)
@_exported import CoreGraphics
#else
@_exported import Foundation
#endif

#if canImport(QuartzCore)
@_exported import QuartzCore
#endif

@_exported import CoreFoundation
