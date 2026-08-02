//
//  FontPlayground.swift
//  Shared

import CoreText
import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif

// Examples adapted from “SwiftUI under the Hood: Fonts”:
// https://movingparts.io/fonts-in-swiftui
struct FontPlayground: View {
    private let weights: [CGFloat] = Array(stride(from: 100, through: 900, by: 150))

    private let slants: [CGFloat] = Array(stride(from: 0, through: -10, by: -10 / 6))

    init() {
        #if DEBUG
        _ = Self.dumpExamplesOnce
        #endif
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font providers")
                .font(.headline)

            Text("Font.body")
                .font(.body)
            Text("Font.system(size:weight:design:)")
                .font(.system(size: 17, weight: .regular, design: .default))
            Text("Font.custom(_:size:relativeTo:)")
                .font(.custom("Helvetica", size: 17, relativeTo: .body))
            Text("Font.body.italic()")
                .font(.body.italic())
            Text("Font.body.weight(.medium)")
                .font(.body.weight(.medium))

            #if canImport(UIKit)
            Text("BackdropText")
                .font(.headline)

            #if !OPENSWIFTUI // FIXME: CGPath crash
            BackdropText()
                .font(.custom("Avenir", size: 32).italic())
            #endif
            #endif

            Text("Inter 4.1: slant × weight")
                .font(.headline)

            ForEach(slants, id: \.self) { slant in
                HStack {
                    ForEach(weights, id: \.self) { weight in
                        Text("Hi")
                            .font(.inter(size: 32, slant: slant, weight: weight))
                    }
                }
            }
        }
        .padding()
    }

    #if DEBUG
    private static let dumpExamplesOnce: Void = {
        dump(Font.body, name: "Font.body")
        dump(
            Font.system(size: 17, weight: .regular, design: .default),
            name: "Font.system(size: 17, weight: .regular, design: .default)"
        )
        dump(
            Font.custom("Helvetica", size: 17, relativeTo: .body),
            name: "Font.custom(\"Helvetica\", size: 17, relativeTo: .body)"
        )
        dump(
            Font.inter(size: 40, slant: -5, weight: 300),
            name: "Font.inter(size: 40, slant: -5, weight: 300)"
        )
        dump(Font.body.italic(), name: "Font.body.italic()")
        dump(Font.body.weight(.medium), name: "Font.body.weight(.medium)")
    }()
    #endif
}

extension Font {
    static func inter(
        size: CGFloat,
        slant: CGFloat = 0,
        weight: CGFloat = 400
    ) -> Font {
        let variations = [
            /* 'wght' */ 0x77676874: weight,
        ]
        let radians = slant * CGFloat.pi / 180
        let matrix = CGAffineTransform(
            a: 1,
            b: 0,
            c: -tan(radians),
            d: 1,
            tx: 0,
            ty: 0
        )

        #if canImport(UIKit)
        let descriptor = UIFontDescriptor(fontAttributes: [
            .name: "InterVariable",
            kCTFontVariationAttribute as UIFontDescriptor.AttributeName: variations,
        ]).withMatrix(matrix)
        return Font(UIFont(descriptor: descriptor, size: size))
        #else
        let descriptor = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "InterVariable",
            kCTFontVariationAttribute: variations,
        ] as CFDictionary)
        let font = CTFontCreateWithFontDescriptor(descriptor, size, nil)
        var fontMatrix = matrix
        return Font(CTFontCreateCopyWithAttributes(font, size, &fontMatrix, nil))
        #endif
    }
}

#if canImport(UIKit)
private struct BackdropText: View {
    @Environment(\.font) private var font
    @Environment(\.sizeCategory) private var sizeCategory

    private var uiFont: UIFont {
        let traits = UITraitCollection(
            preferredContentSizeCategory: sizeCategory.uiContentSizeCategory
        )
        return resolveFont(font ?? .body)?.font(with: traits)
            ?? UIFont.preferredFont(forTextStyle: .body, compatibleWith: traits)
    }

    var body: some View {
        // The baseline is measured from the top of the Text view.
        let baselineY = uiFont.lineHeight + uiFont.descender
        let slant = abs(uiFont.slant) * CGFloat.pi / 180

        Text("Hello World!")
            .lineLimit(1)
            .background(
                FontBackdrop(baselineY: baselineY, slant: slant)
                    .fill(Color.pink)
            )
    }
}

private struct FontBackdrop: Shape {
    var baselineY: CGFloat
    var slant: CGFloat

    func path(in rect: CGRect) -> Path {
        let transform = CGAffineTransform(
            a: 1,
            b: 0,
            c: -tan(slant),
            d: 1,
            tx: 0,
            ty: 0
        ).translatedBy(x: baselineY * sin(slant), y: 0)
        let path = CGMutablePath()
        path.addRect(rect, transform: transform)
        return Path(path)
    }
}

// The article mirrors SwiftUI's private provider tree so a late-bound Font can
// be resolved with the environment values available to BackdropText.
private protocol ResolvedFontProvider {
    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor
}

private extension ResolvedFontProvider {
    func font(with traitCollection: UITraitCollection?) -> UIFont {
        UIFont(descriptor: fontDescriptor(with: traitCollection), size: 0)
    }
}

private protocol ResolvedFontModifier {
    func modify(_ fontDescriptor: inout UIFontDescriptor)
}

private protocol ResolvedStaticFontModifier: ResolvedFontModifier {
    init()
}

private struct ResolvedTextStyleProvider: ResolvedFontProvider {
    var style: UIFont.TextStyle
    var design: UIFontDescriptor.SystemDesign?
    var weight: UIFont.Weight?

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        var descriptor = UIFont
            .preferredFont(forTextStyle: style, compatibleWith: traitCollection)
            .fontDescriptor
        if let design {
            descriptor = descriptor.withDesign(design) ?? descriptor
        }
        if let weight {
            descriptor = descriptor.addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: weight.rawValue],
            ])
        }
        return descriptor
    }
}

private struct ResolvedSystemProvider: ResolvedFontProvider {
    var size: CGFloat
    var design: UIFontDescriptor.SystemDesign?
    var weight: UIFont.Weight?

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        var descriptor = UIFont
            .systemFont(ofSize: size, weight: weight ?? .regular)
            .fontDescriptor
        if let design {
            descriptor = descriptor.withDesign(design) ?? descriptor
        }
        return descriptor
    }
}

private struct ResolvedNamedProvider: ResolvedFontProvider {
    var name: String
    var size: CGFloat
    var textStyle: UIFont.TextStyle?

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        let resolvedSize: CGFloat
        if let textStyle {
            resolvedSize = UIFontMetrics(forTextStyle: textStyle)
                .scaledValue(for: size, compatibleWith: traitCollection)
        } else {
            resolvedSize = size
        }
        return UIFontDescriptor(name: name, size: resolvedSize)
    }
}

private struct ResolvedPlatformFontProvider: ResolvedFontProvider {
    var font: UIFont

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        font.fontDescriptor
    }
}

private struct ResolvedModifierProvider<M: ResolvedFontModifier>: ResolvedFontProvider {
    var base: any ResolvedFontProvider
    var modifier: M

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        var descriptor = base.fontDescriptor(with: traitCollection)
        modifier.modify(&descriptor)
        return descriptor
    }
}

private struct ResolvedStaticModifierProvider<M: ResolvedStaticFontModifier>: ResolvedFontProvider {
    var base: any ResolvedFontProvider

    func fontDescriptor(with traitCollection: UITraitCollection?) -> UIFontDescriptor {
        var descriptor = base.fontDescriptor(with: traitCollection)
        M().modify(&descriptor)
        return descriptor
    }
}

private struct ResolvedItalicModifier: ResolvedStaticFontModifier {
    init() {}

    func modify(_ fontDescriptor: inout UIFontDescriptor) {
        fontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) ?? fontDescriptor
    }
}

private struct ResolvedWeightModifier: ResolvedFontModifier {
    var value: CGFloat

    func modify(_ fontDescriptor: inout UIFontDescriptor) {
        fontDescriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: value],
        ])
    }
}

private func resolveFont(_ font: Font) -> (any ResolvedFontProvider)? {
    let mirror = Mirror(reflecting: font)
    guard let provider = mirror.descendant("provider", "base") else {
        return nil
    }
    return resolveFontProvider(provider)
}

private func resolveFontProvider(_ provider: Any) -> (any ResolvedFontProvider)? {
    let mirror = Mirror(reflecting: provider)

    switch String(describing: type(of: provider)) {
    case "StaticModifierProvider<ItalicModifier>":
        guard let base = mirror.descendant("base", "provider", "base"),
              let resolvedBase = resolveFontProvider(base) else {
            return nil
        }
        return ResolvedStaticModifierProvider<ResolvedItalicModifier>(base: resolvedBase)
    case "ModifierProvider<WeightModifier>":
        guard let base = mirror.descendant("base", "provider", "base"),
              let resolvedBase = resolveFontProvider(base),
              let value = mirror.descendant("modifier", "weight", "value") as? CGFloat else {
            return nil
        }
        return ResolvedModifierProvider(
            base: resolvedBase,
            modifier: ResolvedWeightModifier(value: value)
        )
    case "TextStyleProvider":
        guard let style = mirror.descendant("style") as? Font.TextStyle else {
            return nil
        }
        let design = reflectedOptional(
            mirror.descendant("design"),
            as: Font.Design.self
        )
        let weight = reflectedOptional(
            mirror.descendant("weight"),
            as: Font.Weight.self
        )
        return ResolvedTextStyleProvider(
            style: style.uiTextStyle,
            design: design?.uiSystemDesign,
            weight: weight?.uiFontWeight
        )
    case "SystemProvider":
        guard let size = mirror.descendant("size") as? CGFloat else {
            return nil
        }
        let design = reflectedOptional(
            mirror.descendant("design"),
            as: Font.Design.self
        )
        let weight = reflectedOptional(
            mirror.descendant("weight"),
            as: Font.Weight.self
        )
        return ResolvedSystemProvider(
            size: size,
            design: design?.uiSystemDesign,
            weight: weight?.uiFontWeight
        )
    case "NamedProvider":
        guard let name = mirror.descendant("name") as? String,
              let size = mirror.descendant("size") as? CGFloat else {
            return nil
        }
        let textStyle = reflectedOptional(
            mirror.descendant("textStyle"),
            as: Font.TextStyle.self
        )
        return ResolvedNamedProvider(
            name: name,
            size: size,
            textStyle: textStyle?.uiTextStyle
        )
    case "PlatformFontProvider":
        guard let font = mirror.descendant("font") as? UIFont else {
            return nil
        }
        return ResolvedPlatformFontProvider(font: font)
    default:
        // This intentionally mirrors only the providers used by the playground.
        return nil
    }
}

private func reflectedOptional<Value>(
    _ value: Any?,
    as type: Value.Type
) -> Value? {
    guard let value else {
        return nil
    }
    if let value = value as? Value {
        return value
    }
    let mirror = Mirror(reflecting: value)
    guard mirror.displayStyle == .optional else {
        return nil
    }
    return mirror.children.first?.value as? Value
}

private extension Font.Design {
    var uiSystemDesign: UIFontDescriptor.SystemDesign {
        switch self {
        case .default: .default
        case .serif: .serif
        case .rounded: .rounded
        case .monospaced: .monospaced
        @unknown default: .default
        }
    }
}

private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        @unknown default: .body
        }
    }
}

private extension Font.Weight {
    var uiFontWeight: UIFont.Weight {
        let value = Mirror(reflecting: self).descendant("value") as? CGFloat ?? 0
        return UIFont.Weight(rawValue: value)
    }
}

private extension ContentSizeCategory {
    var uiContentSizeCategory: UIContentSizeCategory {
        switch self {
        case .extraSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .extraLarge: .extraLarge
        case .extraExtraLarge: .extraExtraLarge
        case .extraExtraExtraLarge: .extraExtraExtraLarge
        case .accessibilityMedium: .accessibilityMedium
        case .accessibilityLarge: .accessibilityLarge
        case .accessibilityExtraLarge: .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge: .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: .accessibilityExtraExtraExtraLarge
        @unknown default: .large
        }
    }
}

private extension UIFont {
    var slant: CGFloat {
        CTFontGetSlantAngle(self)
    }
}
#endif
