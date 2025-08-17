//
//  CoreText+Private.swift
//  OpenSwiftUICore

#if canImport(CoreText)
package import CoreText
import CoreFoundation

// MARK: - Private CoreText APIs

/// Private CoreText function to get the weight value from a font descriptor.
///
/// - Parameter descriptor: The font descriptor to query.
/// - Returns: The weight value as a CGFloat.
@_silgen_name("CTFontDescriptorGetWeight")
package func CTFontDescriptorGetWeight(_ descriptor: CTFontDescriptor) -> CGFloat

@_silgen_name("CTFontDescriptorGetTextStyleSize")
package func CTFontDescriptorGetTextStyleSize(
    _ textStyle: CFString,
    _ sizeCategory: CFString,
    _: Int32,
    _ weight: UnsafePointer<CGFloat>?,
    _ size: UnsafePointer<CGFloat>? // FIXME
) -> CGFloat

// MARK: - CTFontTextStyle

@_silgen_name("kCTUIFontTextStyleTitle0")
let kCTUIFontTextStyleTitle0: CFString

@_silgen_name("kCTUIFontTextStyleTitle1")
let kCTUIFontTextStyleTitle1: CFString

@_silgen_name("kCTUIFontTextStyleTitle2")
let kCTUIFontTextStyleTitle2: CFString

@_silgen_name("kCTUIFontTextStyleTitle3")
let kCTUIFontTextStyleTitle3: CFString

@_silgen_name("kCTUIFontTextStyleHeadline")
let kCTUIFontTextStyleHeadline: CFString

@_silgen_name("kCTUIFontTextStyleSubhead")
let kCTUIFontTextStyleSubhead: CFString

@_silgen_name("kCTUIFontTextStyleBody")
let kCTUIFontTextStyleBody: CFString

@_silgen_name("kCTUIFontTextStyleCallout")
let kCTUIFontTextStyleCallout: CFString

@_silgen_name("kCTUIFontTextStyleFootnote")
let kCTUIFontTextStyleFootnote: CFString

@_silgen_name("kCTUIFontTextStyleCaption1")
let kCTUIFontTextStyleCaption1: CFString

@_silgen_name("kCTUIFontTextStyleCaption2")
let kCTUIFontTextStyleCaption2: CFString

@_silgen_name("kCTUIFontTextStyleExtraLargeTitle")
let kCTUIFontTextStyleExtraLargeTitle: CFString

@_silgen_name("kCTUIFontTextStyleExtraLargeTitle2")
let kCTUIFontTextStyleExtraLargeTitle2: CFString

@_silgen_name("kCTUIFontTextStyleCaption3")
let kCTUIFontTextStyleCaption3: CFString

@_silgen_name("kCTUIFontTextStyleFootnote2")
let kCTUIFontTextStyleFootnote2: CFString

let kUICTFontTextStyleShortCaption1: CFString = "UICTFontTextStyleShortCaption1" as CFString

let kUICTFontTextStyleShortCaption2: CFString = "UICTFontTextStyleShortCaption2" as CFString

// MARK: - CTFontDesign

@_silgen_name("kCTFontUIFontDesignDefault")
let kCTFontUIFontDesignDefault: CFString

@_silgen_name("kCTFontUIFontDesignSerif")
let kCTFontUIFontDesignSerif: CFString

@_silgen_name("kCTFontUIFontDesignRounded")
let kCTFontUIFontDesignRounded: CFString

@_silgen_name("kCTFontUIFontDesignMonospaced")
let kCTFontUIFontDesignMonospaced: CFString

@_silgen_name("kCTFontUIFontDesignCompact")
let kCTFontUIFontDesignCompact: CFString

@_silgen_name("kCTFontUIFontDesignCompactRounded")
let kCTFontUIFontDesignCompactRounded: CFString

@_silgen_name("kCTFontUIFontDesignSoft")
let kCTFontUIFontDesignSoft: CFString

@_silgen_name("kCTFontUIFontDesignCompactSoft")
let kCTFontUIFontDesignCompactSoft: CFString

// MARK: - CTFontContentSizeCategory

@_silgen_name("kCTFontContentSizeCategoryXS")
let kCTFontContentSizeCategoryXS: CFString

@_silgen_name("kCTFontContentSizeCategoryS")
let kCTFontContentSizeCategoryS: CFString

@_silgen_name("kCTFontContentSizeCategoryM")
let kCTFontContentSizeCategoryM: CFString

@_silgen_name("kCTFontContentSizeCategoryL")
let kCTFontContentSizeCategoryL: CFString

@_silgen_name("kCTFontContentSizeCategoryXL")
let kCTFontContentSizeCategoryXL: CFString

@_silgen_name("kCTFontContentSizeCategoryXXL")
let kCTFontContentSizeCategoryXXL: CFString

@_silgen_name("kCTFontContentSizeCategoryXXXL")
let kCTFontContentSizeCategoryXXXL: CFString

@_silgen_name("kCTFontContentSizeCategoryAccessibilityM")
let kCTFontContentSizeCategoryAccessibilityM: CFString

@_silgen_name("kCTFontContentSizeCategoryAccessibilityL")
let kCTFontContentSizeCategoryAccessibilityL: CFString

@_silgen_name("kCTFontContentSizeCategoryAccessibilityXL")
let kCTFontContentSizeCategoryAccessibilityXL: CFString

@_silgen_name("kCTFontContentSizeCategoryAccessibilityXXL")
let kCTFontContentSizeCategoryAccessibilityXXL: CFString

@_silgen_name("kCTFontContentSizeCategoryAccessibilityXXXL")
let kCTFontContentSizeCategoryAccessibilityXXXL: CFString

// MARK: - CTFontWidth

@_silgen_name("kCTFontWidthCompressed")
let kCTFontWidthCompressed: CGFloat

@_silgen_name("kCTFontWidthCondensed")
let kCTFontWidthCondensed: CGFloat

@_silgen_name("kCTFontWidthExpanded")
let kCTFontWidthExpanded: CGFloat

@_silgen_name("kCTFontWidthStandard")
let kCTFontWidthStandard: CGFloat

@_silgen_name("kCTFontWidthTrait")
let kCTFontWidthTrait: CGFloat

#else

public import Foundation

// Placeholder for CoreText when not available.
public class CTFontDescriptor: NSObject {}

public class CTFont: NSObject {}

#endif
