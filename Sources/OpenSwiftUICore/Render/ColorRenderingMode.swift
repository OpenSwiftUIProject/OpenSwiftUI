//
//  ColorRenderingMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ColorRenderingMode

/// The set of possible working color spaces for color-compositing operations.
///
/// Each color space guarantees the preservation of a particular range of color
/// values.
public enum ColorRenderingMode: Sendable {

    /// The non-linear sRGB working color space.
    ///
    /// Color component values outside the range `[0, 1]` produce undefined
    /// results. This color space is gamma corrected.
    case nonLinear
    
    /// The linear sRGB working color space.
    ///
    /// Color component values outside the range `[0, 1]` produce undefined
    /// results. This color space isn't gamma corrected.
    case linear
    
    /// The extended linear sRGB working color space.
    ///
    /// Color component values outside the range `[0, 1]` are preserved.
    /// This color space isn't gamma corrected.
    case extendedLinear
}

extension ColorRenderingMode: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .nonLinear: return 0
        case .linear: return 1
        case .extendedLinear: return 2
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .nonLinear
        case 1: self = .linear
        case 2: self = .extendedLinear
        default: return nil
        }
    }
}
