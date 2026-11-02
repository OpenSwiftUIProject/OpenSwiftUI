//
//  CoreMaterialDefinitions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1136DDC987AEEDFF1217B91AA2732172 (SwiftUICore)

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if OPENSWIFTUI_LINK_COREMATERIAL
import CoreMaterial
#endif
#if os(visionOS) && canImport(QuartzCore)
import QuartzCore_Private
#endif

// MARK: - ContentStyle.MaterialStyle

extension ContentStyle.MaterialStyle {
    package func resolveCoreMaterialColor(in environment: EnvironmentValues) -> Color.Resolved {
        #if os(visionOS)
        if environment.isVisionEnabled {
            return (environment.materialBaseColor ?? .white).resolve(in: environment)
        }
        #endif
        return material.colorScheme == .dark ? .white : .black
    }

    func resolveCoreMaterialEffects() -> [DisplayList.Effect] {
        CoreMaterialCache.$shared.access { $0[self] }
    }

    fileprivate var coreMaterialDescription: [String: Any] {
        #if OPENSWIFTUI_LINK_COREMATERIAL
        let category: MTCoreMaterialVisualStyleCategory
        let style: MTCoreMaterialVisualStyle
        switch base.primitive {
        case .separator:
            category = .fill
            style = .separator
        default:
            switch base.primitive {
            case .fill: category = .fill
            #if os(visionOS)
            case .overlay: category = .overlay
            #endif
            default: category = .stroke
            }
            switch base.id {
            case .primary: style = .primary
            case .secondary: style = .secondary
            case .tertiary: style = .tertiary
            case .quaternary, .quinary:
                #if os(visionOS)
                style = base.primitive == .fill && !material.flags.contains(.isVisionEnabled)
                    ? .tertiary : .quaternary
                #else
                style = base.primitive == .fill ? .tertiary : .quaternary
                #endif
            }
        }
        var description = MTVisualStylingCreateDictionaryRepresentation(
            material.coreMaterialRecipe,
            category,
            style,
            material.coreMaterialOptions
        ) ?? [:]
        #if os(visionOS)
        if base.primitive == .destructive,
           var filter = description["compositingFilter"] as? [String: Any],
           filter["inputAmount"] is Double {
            filter["inputAmount"] = 0.65
            description["compositingFilter"] = filter
        }
        #endif
        return description
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return [:]
        #endif
    }
}

// MARK: - Material.ResolvedMaterial

extension Material.ResolvedMaterial {
    package func visitCoreMaterialLayers<V: MaterialLayerVisitor>(_ visitor: inout V) {
        let layers = CoreMaterialCache.$shared.access { $0[self] }
        for layer in layers {
            visitor.visit(layer: layer)
        }
    }

    fileprivate var coreMaterialDescription: [String: Any] {
        #if OPENSWIFTUI_LINK_COREMATERIAL
        return MTMaterialCreateDictionaryRepresentation(coreMaterialRecipe, coreMaterialOptions)!
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return [:]
        #endif
    }

    #if OPENSWIFTUI_LINK_COREMATERIAL
    fileprivate var coreMaterialRecipe: MTCoreMaterialRecipe {
        let isDark = colorScheme == .dark
        switch id {
        case .ultraThin:
            return isDark ? .platformContentUltraThinDark : .platformContentUltraThinLight
        case .thin:
            return isDark ? .platformContentThinDark : .platformContentThinLight
        case .regular:
            return isDark ? .platformContentDark : .platformContentLight
        case .thick, .ultraThick:
            return isDark ? .platformContentThickDark : .platformContentThickLight
        case .systemBars:
            return isDark ? .platformChromeDark : .platformChromeLight
        #if os(visionOS)
        case .pinched: return MTCoreMaterialRecipe(rawValue: "platformPinched")
        case .selected: return MTCoreMaterialRecipe(rawValue: "platformSelected")
        case .disabled: return MTCoreMaterialRecipe(rawValue: "platformDisabled")
        case .vibrantGlassContent: return .platformContentGlass
        case .darkerGlass: return .platformContentGlassDarker
        case .lighterGlass: return .platformContentGlassLighter
        case .ultraDarkerGlass: return .platformContentGlassUltraDarker
        #endif
        case let .coreMaterial(light, dark, _):
            return MTCoreMaterialRecipe(rawValue: isDark ? dark : light)
        default:
            preconditionFailure("unexpected material ID type")
        }
    }

    fileprivate var coreMaterialOptions: [String: Any] {
        var options: [String: Any] = [
            kMTDictionaryRepresentationOptionsIncludeOptimizationsKey: true,
            kMTDictionaryRepresentationOptionsReduceTransparencyKey: flags.contains(.reduceTransparency),
        ]
        if case let .coreMaterial(_, _, bundle) = id {
            options[kMTDictionaryRepresentationOptionsBundleKey] = bundle
        }
        #if os(visionOS)
        options[kMTDictionaryRepresentationOptionsFiltersRepresentationV2Key] = true
        #endif
        return options
    }
    #endif
}

// MARK: - CoreMaterialCache

private struct CoreMaterialCache {
    var materials: [Material.ResolvedMaterial: [AnyMaterialLayer]] = [:]
    var styles: [ContentStyle.MaterialStyle: [DisplayList.Effect]] = [:]

    @AtomicBox
    static var shared = CoreMaterialCache()

    subscript(material: Material.ResolvedMaterial) -> [AnyMaterialLayer] {
        mutating get {
            if let layers = materials[material] {
                return layers
            } else {
                let layers = load(material: material)
                materials[material] = layers
                return layers
            }
        }
    }

    subscript(style: ContentStyle.MaterialStyle) -> [DisplayList.Effect] {
        mutating get {
            if let effects = styles[style] {
                return effects
            } else {
                let effects = loadEffects(style: style)
                styles[style] = effects
                return effects
            }
        }
    }

    func load(material: Material.ResolvedMaterial) -> [AnyMaterialLayer] {
        let description = material.coreMaterialDescription
        guard let definitions = description["filters"] as? [[String: Any]] else {
            return []
        }
        let scale: Float
        if material.flags.contains(.filtersInPlace) {
            scale = 0
        } else if material.flags.contains(.noBlur) {
            scale = 1
        } else {
            scale = Float(description["scale"] as? Double ?? 0.25)
        }
        var filters: [GraphicsFilter] = []
        for definition in definitions {
            switch definition["type"] as? String {
            case "colorSaturate":
                if let amount = definition["inputAmount"] as? Double, amount != 1 {
                    filters.append(.saturation(amount))
                }
            case "colorBrightness":
                if let amount = definition["inputAmount"] as? Double, amount != 0 {
                    filters.append(.brightness(amount))
                }
            case "gaussianBlur":
                guard !material.flags.contains(.noBlur),
                      let radius = definition["inputRadius"] as? Double else {
                    continue
                }
                var style = BlurStyle(
                    radius: CGFloat(radius),
                    isOpaque: definition["inputNormalizeEdges"] as? Bool ?? false,
                    dither: definition["inputDither"] as? Bool ?? false
                )
                #if os(visionOS)
                style.isOpaque = style.isOpaque && !material.flags.contains(.noNormalizedEdgesBlur)
                style.hardEdges = (definition["inputHardEdges"] as? Bool ?? false)
                    || material.flags.contains(.applyHardEdgesBlur)
                style.isVisionEnabled = material.flags.contains(.isVisionEnabled)
                    && !material.flags.contains(.noTransparentBlur)
                #endif
                if !style.isIdentity {
                    filters.append(.blur(style))
                }
            #if canImport(CoreGraphics)
            case "variableBlur":
                guard !material.flags.contains(.noBlur),
                      let radius = definition["inputRadius"] as? Double,
                      let image = definition["inputMaskImage"] as! CGImage? else {
                    continue
                }
                let mask = GraphicsImage(
                    contents: .cgImage(image),
                    scale: 1,
                    unrotatedPixelSize: CGSize(width: image.width, height: image.height),
                    orientation: .up,
                    isTemplate: false
                )
                var style = VariableBlurStyle(
                    isOpaque: definition["inputNormalizeEdges"] as? Bool ?? false,
                    dither: definition["inputDither"] as? Bool ?? false,
                    mask: .image(mask)
                )
                style.caFilterRadius = CGFloat(radius)
                if !style.isIdentity {
                    filters.append(.variableBlur(style))
                }
            #endif
            case "averageColor":
                if !material.flags.contains(.noBlur) {
                    filters.append(.averageColor)
                }
            case "luminanceCurveMap":
                if let amount = definition["inputAmount"] as? Double {
                    filters.append(.luminanceCurve(.init(
                        curve: Self.parseCurve(definition["inputValues"]),
                        amount: Float(amount)
                    )))
                }
            case "curves":
                filters.append(.colorCurves(.init(
                    redCurve: Self.parseCurve(definition["inputRedValues"]),
                    greenCurve: Self.parseCurve(definition["inputGreenValues"]),
                    blueCurve: Self.parseCurve(definition["inputBlueValues"]),
                    opacityCurve: Self.parseCurve(definition["inputAlphaValues"])
                )))
            #if canImport(ObjectiveC)
            case "colorMatrix":
                if let value = definition["inputColorMatrix"] as? NSValue {
                    var matrix = _ColorMatrix()
                    value.getValue(&matrix)
                    if !matrix.isIdentity {
                        filters.append(.colorMatrix(matrix, premultiplied: false))
                    }
                }
            #endif
            default:
                break
            }
        }
        guard !filters.isEmpty else { return [] }
        let backdrop = BackdropEffect(scale: scale, color: .clear, filters: filters)
        let layer = AnyMaterialLayer(content: .backdrop(backdrop))
        #if os(visionOS) && canImport(QuartzCore)
        if material.flags.contains(.isVisionEnabled),
           !material.flags.contains(.noTransparentBlur),
           !material.flags.contains(.noBlur) {
            var capture = backdrop
            capture.captureOnly = true
            return [
                AnyMaterialLayer(content: .backdrop(capture)),
                AnyMaterialLayer(content: .color(.black), blendMode: .destOutPassthrough),
                layer,
            ]
        }
        #endif
        return [layer]
    }

    private static func parseCurve(_ value: Any?) -> GraphicsFilter.Curve {
        guard let values = value as? [Double] else {
            return .init((0, 0, 1, 1))
        }
        return .init((Float(values[0]), Float(values[1]), Float(values[2]), Float(values[3])))
    }

    func loadEffects(style: ContentStyle.MaterialStyle) -> [DisplayList.Effect] {
        let description = style.coreMaterialDescription
        var effects: [DisplayList.Effect] = []
        #if os(visionOS) && canImport(QuartzCore)
        if let effect = loadBlendModeEffect(description) {
            effects.append(effect)
        }
        if let effect = loadTintAlphaEffect(description) {
            effects.append(effect)
        }
        #endif

        var colorMatrix: _ColorMatrix?
        #if canImport(ObjectiveC)
        if let filters = description["filters"] as? [[String: Any]] {
            for filter in filters {
                guard filter["type"] as? String == "vibrantColorMatrix",
                      let value = filter["inputColorMatrix"] as? NSValue else {
                    continue
                }
                var matrix = _ColorMatrix()
                value.getValue(&matrix)
                colorMatrix = colorMatrix.map { matrix * $0 } ?? matrix
            }
        }
        #endif

        if let colorMatrix {
            effects.append(.filter(.vibrantColorMatrix(colorMatrix)))
        } else if let tint = Self.parseColor(description["tintColor"]) {
            if tint.linearRed == 1, tint.linearGreen == 1, tint.linearBlue == 1 {
                if tint.opacity != 1 {
                    effects.append(.opacity(tint.opacity))
                }
            } else {
                effects.append(.filter(.colorMultiply(tint)))
            }
        }
        return effects
    }

    static func parseColor(_ value: Any?) -> Color.Resolved? {
        guard let color = value as? [String: Any] else {
            return nil
        }
        guard let alpha = color["alpha"] as? Double else {
            return .white
        }
        if let white = color["white"] as? Double {
            return Color.Resolved(white: Float(white), opacity: Float(alpha))
        }
        if let red = color["red"] as? Double,
           let green = color["green"] as? Double,
           let blue = color["blue"] as? Double {
            return Color.Resolved(
                colorSpace: .sRGB,
                red: Float(red),
                green: Float(green),
                blue: Float(blue),
                opacity: Float(alpha)
            )
        }
        return Color.Resolved(linearWhite: 1, opacity: Float(alpha))
    }

    #if os(visionOS) && canImport(QuartzCore)
    private static let subtractSIgnoreAlpha = GraphicsBlendMode.caFilter(CAFilter(type: "subtractSIgnoreAlpha"))
    private static let plusDIgnoreAlpha = GraphicsBlendMode.caFilter(CAFilter(type: "plusDIgnoreAlpha"))
    private static let plusLIgnoreAlpha = GraphicsBlendMode.caFilter(CAFilter(type: "plusLIgnoreAlpha"))

    func loadBlendModeEffect(_ description: [String: Any]) -> DisplayList.Effect? {
        let filter = description["compositingFilter"] as? [String: Any]
        let type = description["compositingFilter"] as? String ?? filter?["type"] as? String
        switch type {
        case "subtractSIgnoreAlpha":
            return .blendMode(Self.subtractSIgnoreAlpha)
        case "plusDIgnoreAlpha":
            return .blendMode(Self.plusDIgnoreAlpha)
        case "plusLIgnoreAlpha":
            return .blendMode(Self.plusLIgnoreAlpha)
        case "plusLIgnoreAlphaSourceOverBlend":
            guard let amount = filter?["inputAmount"] as? Double else {
                return nil
            }
            let filter = CAFilter(type: "plusLIgnoreAlphaSourceOverBlend")
            filter.setInput(value: amount, key: .amount)
            return .blendMode(.caFilter(filter))
        default:
            return nil
        }
    }

    func loadTintAlphaEffect(_ description: [String: Any]) -> DisplayList.Effect? {
        guard let alpha = description["tintAlpha"] as? Float, alpha != 1 else {
            return nil
        }
        return .opacity(alpha)
    }
    #endif
}
