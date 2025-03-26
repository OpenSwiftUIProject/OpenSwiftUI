//
//  Export.swift
//  CoreGraphicsShims

#if canImport(CoreGraphics)
@_exported import CoreGraphics
#else
@_exported import CoreFoundation
#endif
