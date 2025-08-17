//
//  CoreTextUtil.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complte

#if canImport(CoreText)

package import CoreText
import Foundation
package import OpenSwiftUI_SPI

extension CTFont {
    package var pointSize: CGFloat {
        CTFontGetSize(self)
    }

    package var capHeight: CGFloat {
        CTFontGetCapHeight(self)
    }

    package var ascender: CGFloat {
        CTFontGetAscent(self)
    }

    package var descender: CGFloat {
        CTFontGetDescent(self)
    }

    package var leading: CGFloat {
        CTFontGetLeading(self)
    }

    package var bodyLeading: CGFloat {
        ascender + descender + leading
    }

    package var isSystemUIFont: Bool {
        CTFontIsSystemUIFont(self)
    }

    package var weight: CGFloat {
        CTFontGetWeight(self)
    }

    package var symbolicTraits: CTFontSymbolicTraits {
        CTFontGetSymbolicTraits(self)
    }

    package var stylisticClass: CTFontStylisticClass {
        .init(rawValue: CTFontGetSymbolicTraits(self).rawValue & CTFontSymbolicTraits.traitClassMask.rawValue)
    }

    package func scaled(
        by factor: CGFloat,
        toMultipleOf m: CGFloat? = 0.25,
        maintainVisualWeight: Bool = false,
    ) -> CTFont {
        guard factor != 1.0 else {
            return self
        }
        let newPointSize: CGFloat
        if let m {
            var size = pointSize * factor
            size.round(.toNearestOrAwayFromZero, toMultipleOf: m)
            newPointSize = size
        } else {
            newPointSize = pointSize * factor
        }
        var descriptor = CTFontCopyFontDescriptor(self)
        if maintainVisualWeight, newPointSize > 0 {
            let newWeight = (factor + 1.0) * 0.5 * ((weight + 1.0) * pointSize / newPointSize) - 1.0
            let attributes = [
                kCTFontTraitsAttribute: [
                    kCTFontWeightTrait: NSNumber(value: newWeight),
                ],
            ] as CFDictionary
            descriptor = CTFontDescriptorCreateCopyWithAttributes(
                descriptor,
                attributes,
            )
        }
        return CTFontCreateWithFontDescriptor(descriptor, newPointSize, nil)
    }

    package var mayRequireLanguageAwareOutsets: Bool {
        guard symbolicTraits.isEmpty else {
            return true
        }
        guard weight <= kCTFontWeightHeavy else {
            return true
        }
        let stylisticClass = stylisticClass
        return stylisticClass == [.modernSerifsClass] || stylisticClass == [.oldStyleSerifsClass, .modernSerifsClass]
    }
}

extension CTFontLegibilityWeight {
    package init(_ legibilityWeight: LegibilityWeight?) {
        switch legibilityWeight {
        case .regular: self = .regular
        case .bold: self = .bold
        case nil: self = .regular
        }
    }
}

extension CTFontDescriptor {
    package static func fontDescriptor(
        textStyle: CFString,
        design: CFString?,
        weight: Font.Weight?,
        sizeCategory: ContentSizeCategory,
        legibilityWeight: LegibilityWeight?,
    ) -> CTFontDescriptor {
        var attributes: [CFString: Any] = [:]
        var traits: [CFString: Any] = [:]
        if let design {
            traits[kCTFontUIFontDesignTrait] = design
        }
        if let weight {
            traits[kCTFontWeightTrait] = weight.value
        }
        if !traits.isEmpty {
            attributes[kCTFontTraitsAttribute] = traits
        }
        if let legibilityWeight {
            attributes[kCTFontLegibilityWeightAttribute] = CTFontLegibilityWeight(legibilityWeight)
        }
        return CTFontDescriptorCreateWithTextStyleAndAttributes(
            textStyle,
            DynamicTypeSize(sizeCategory).ctTextSize,
            attributes as CFDictionary
        )
    }

    package static func fontDescriptor(
        size: CGFloat,
        design: CFString,
        weight: Font.Weight?,
        legibilityWeight: LegibilityWeight?,
    ) -> CTFontDescriptor {
        var attributes: [CFString: Any] = [
            kCTFontTraitsAttribute: [
                kCTFontWidthTrait: kCTFontWeightRegular,
                kCTFontUIFontDesignTrait: design,
            ],
            kCTFontSizeAttribute: size
        ]
        if let legibilityWeight {
            attributes[kCTFontLegibilityWeightAttribute] = CTFontLegibilityWeight(legibilityWeight)
        }
        return CTFontDescriptorCreateWithAttributesAndOptions(
            attributes as CFDictionary,
            .init(rawValue: 0x400)
        )
    }
}

extension Font {
    package func resolve(in dynamicTypeSize: DynamicTypeSize) -> CTFontDescriptor {
        resolve(
            in: Context(
                sizeCategory: .init(dynamicTypeSize),
                legibilityWeight: nil,
                fontDefinition: .init(base: DefaultFontDefinition.self),
                watchDisplayVariant: .h394,
                shouldRedactContent: false
            )
        )
    }
}
#endif
