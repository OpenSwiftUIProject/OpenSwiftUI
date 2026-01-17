//
//  ShapeStyleResolverMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

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
    
    package init(rbSymbolStyleMask mask: UInt32, location: Image.Location) {
        let bundle: Bundle?
        var options: Options
        if mask & (1 << 9) != 0 {
            options = .multicolor
            bundle = location.bundle
        } else {
            options = []
            bundle = nil
        }
        let foregroundLevels: UInt16
        let hasForegroundPalette: Bool
        if mask & (1 << 8) != 0 {
            foregroundLevels = 5
            hasForegroundPalette = true
        } else if mask & (1 << 7) != 0 {
            foregroundLevels = 4
            hasForegroundPalette = true
        } else if mask & (1 << 6) != 0 {
            foregroundLevels = 3
            hasForegroundPalette = true
        } else if mask & (1 << 5) != 0 {
            foregroundLevels = 2
            hasForegroundPalette = true
        } else if mask & (1 << 0) != 0 {
            foregroundLevels = 1
            hasForegroundPalette = false
        } else {
            foregroundLevels = 0
            hasForegroundPalette = false
        }
        if hasForegroundPalette {
            options.formUnion(.foregroundPalette)
        }
        self.bundle = bundle
        self.foregroundLevels = foregroundLevels
        self.options = options
    }

    package mutating func formUnion(_ rhs: _ShapeStyle_ResolverMode) {
        bundle = bundle ?? rhs.bundle
        foregroundLevels = max(foregroundLevels, rhs.foregroundLevels)
        options.formUnion(rhs.options)
    }
}
