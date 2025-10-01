//
//  ShapeStyle_ResolverMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Blocked by Image.Location

package import Foundation

package struct _ShapeStyle_ResolverMode: Equatable {
    package var bundle: Bundle?
    package var foregroundLevels: UInt16
    package struct Options: OptionSet {
        package let rawValue: UInt8
        package init(rawValue: UInt8) { self.rawValue = rawValue }
        
        package static let foregroundPalette: Options = .init(rawValue: 1 << 0)
        package static let background: Options = .init(rawValue: 1 << 1)
        package static let multicolor: Options = .init(rawValue: 1 << 2)
    }
  
    package var options: Options

    package init(foregroundLevels: UInt16 = 0, options: Options = .init()) {
        self.bundle = nil
        self.foregroundLevels = foregroundLevels
        self.options = options
    }
    
    // package init(rbSymbolStyleMask mask: UInt32, location: Image.Location)

    package mutating func formUnion(_ rhs: _ShapeStyle_ResolverMode) {
        bundle = bundle ?? rhs.bundle
        foregroundLevels = max(foregroundLevels, rhs.foregroundLevels)
        options.formUnion(rhs.options)
    }
}
