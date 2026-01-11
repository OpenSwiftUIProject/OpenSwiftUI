//
//  RasterizationOptions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenRenderBoxShims

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

// MARK: - RasterizationOptions

package struct RasterizationOptions: Equatable {
    package struct Flags: OptionSet {
        package let rawValue: UInt32

        package init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        package static let isAccelerated: RasterizationOptions.Flags = .init(rawValue: 1 << 0)

        package static let isOpaque: RasterizationOptions.Flags = .init(rawValue: 1 << 1)

        package static let rendersAsynchronously: RasterizationOptions.Flags = .init(rawValue: 1 << 2)

        package static let prefersDisplayCompositing: RasterizationOptions.Flags = .init(rawValue: 1 << 3)

        package static let rendersFirstFrameAsync: RasterizationOptions.Flags = .init(rawValue: 1 << 4)

        package static let allowsPackedDrawable: RasterizationOptions.Flags = .init(rawValue: 1 << 5)

        package static let alphaOnly: RasterizationOptions.Flags = .init(rawValue: 1 << 6)

        package static let requiresLayer: RasterizationOptions.Flags = .init(rawValue: 1 << 7)

        package static let rgbaContext: RasterizationOptions.Flags = .init(rawValue: 1 << 8)

        package static let highRes: RasterizationOptions.Flags = .init(rawValue: 1 << 9)

        package static let defaultFlags: RasterizationOptions.Flags = [.allowsPackedDrawable, .requiresLayer]
    }

    package var colorMode: ColorRenderingMode

    package var rbColorMode: Int32?

    package var flags: RasterizationOptions.Flags

    package var maxDrawableCount: Int8

    package init(
        colorMode: ColorRenderingMode = .nonLinear,
        rbColorMode: Int32? = nil,
        flags: RasterizationOptions.Flags = .defaultFlags,
        maxDrawableCount: Int8 = 3
    ) {
        self.colorMode = colorMode
        self.rbColorMode = rbColorMode
        self.flags = flags
        self.maxDrawableCount = maxDrawableCount
    }

    package var isAccelerated: Bool {
        get { flags.contains(.isAccelerated) }
        set { flags.setValue(newValue, for: .isAccelerated) }
    }

    package var isOpaque: Bool {
        get { flags.contains(.isOpaque) }
        set { flags.setValue(newValue, for: .isOpaque) }
    }

    package var rendersAsynchronously: Bool {
        get { flags.contains(.rendersAsynchronously) }
        set { flags.setValue(newValue, for: .rendersAsynchronously) }
    }

    package var rendersFirstFrameAsynchronously: Bool {
        get { flags.contains(.rendersFirstFrameAsync) }
        set { flags.setValue(newValue, for: .rendersFirstFrameAsync) }
    }

    package var prefersDisplayCompositing: Bool {
        get { flags.contains(.prefersDisplayCompositing) }
        set { flags.setValue(newValue, for: .prefersDisplayCompositing) }
    }

    package var allowsPackedDrawable: Bool {
        get { flags.contains(.allowsPackedDrawable) }
        set { flags.setValue(newValue, for: .allowsPackedDrawable) }
    }

    #if !OPENSWIFTUI_ANY_ATTRIBUTE_FIX
    package var resolvedColorMode: ORBColor.Mode {
        if let mode = rbColorMode {
            return ORBColor.Mode(rawValue: mode)
        } else {
            let alphaOnly = alphaOnly
            switch colorMode {
            case .nonLinear:
                return alphaOnly ? ORBColor.Mode(rawValue: 9) : ORBColor.Mode(rawValue: 0)
            case .linear:
                return alphaOnly ? ORBColor.Mode(rawValue: 10) : ORBColor.Mode(rawValue: 1)
            case .extendedLinear:
                return alphaOnly ? ORBColor.Mode(rawValue: 10) : ORBColor.Mode(rawValue: 2)
            }
        }
    }
    #endif

    package var colorSpace: ORBColor.ColorSpace {
        #if OPENSWIFTUI_ANY_ATTRIBUTE_FIX
        .default
        #else
        resolvedColorMode.workingColorSpace
        #endif
     }

    package var alphaOnly: Bool {
        get { flags.contains(.alphaOnly) }
        set { flags.setValue(newValue, for: .alphaOnly) }
    }

    package var requiresLayer: Bool {
        get { flags.contains(.requiresLayer) }
        set { flags.setValue(newValue, for: .requiresLayer) }
    }
}

extension RasterizationOptions: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.enumField(1, colorMode, defaultValue: .nonLinear)
        if let rbColorMode {
            encoder.intField(2, Int(rbColorMode))
        }
        encoder.intField(3, Int(flags.rawValue))
        encoder.intField(4, Int(maxDrawableCount))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var options = RasterizationOptions()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: options.colorMode = try decoder.enumField(field) ?? .nonLinear
            case 2: options.rbColorMode = Int32(try decoder.intField(field))
            case 3: options.flags = Flags(rawValue: UInt32(try decoder.intField(field)))
            case 4: options.maxDrawableCount = Int8(try decoder.intField(field))
            default: try decoder.skipField(field)
            }
        }
        self = options
    }
}
