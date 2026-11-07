//
//  MaterialDefinitions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F296DEBC927E1390A362D58BE2242E68 (SwiftUICore)

import Foundation
#if os(macOS) && OPENSWIFTUI_LINK_COREUI
import CoreUI
#endif
#if os(visionOS)
package import QuartzCore_Private
#endif

// MARK: - ContentStyle.MaterialStyle

extension ContentStyle.MaterialStyle {
    package func resolveColor(in environment: EnvironmentValues) -> Color.Resolved {
        #if os(macOS)
        if case .coreMaterial = material.id {
            return resolveCoreMaterialColor(in: environment)
        }
        let usesSystemColor: Bool
        switch material.id {
        case .contentFill, .windowFill, .secondaryBackground, .tertiaryBackground, .quaternaryBackground:
            usesSystemColor = true
        default:
            usesSystemColor = material.isEmphasized
        }
        if usesSystemColor {
            #if OPENSWIFTUI_LINK_COREUI
            return CoreUIDefaultSystemColorDefinition.value(for: SystemColorType(base.id), environment: environment)
            #else
            return base.id.resolve(in: environment)
            #endif
        }
        let name: CoreUISystemCatalogColorName
        switch base.id {
        case .primary: name = .label
        case .secondary: name = .secondaryLabel
        case .tertiary: name = .tertiaryLabel
        case .quaternary: name = .quaternaryLabel
        case .quinary: name = .quinaryLabel
        }
        return environment.appearance(allowsVibrantBlending: true).asset(for: name)?.0 ?? .clear
        #else
        return resolveCoreMaterialColor(in: environment)
        #endif
    }

    package func resolveEffects() -> [DisplayList.Effect] {
        #if os(macOS)
        if case .coreMaterial = material.id {
            return resolveCoreMaterialEffects()
        }
        guard !material.isEmphasized else { return [] }
        switch material.id {
        case .contentFill, .windowFill, .secondaryBackground, .tertiaryBackground, .quaternaryBackground:
            return []
        default:
            guard base.id != .primary, material.colorSchemeContrast != .increased else {
                return []
            }
            return [.blendMode(.blendMode(material.colorScheme == .dark ? .plusLighter : .plusDarker))]
        }
        #else
        #if os(iOS) || os(visionOS)
        switch material.id {
        case .intelligenceLightSource_Unreactive, .intelligenceLightSource_AudioReactive:
            return []
        default:
            break
        }
        #endif
        return resolveCoreMaterialEffects()
        #endif
    }
}

#if os(macOS)
// MARK: - Material.ResolvedMaterial

extension Material.ResolvedMaterial {
    @AtomicBox
    private static var materialCache: MaterialLayerCache = {
        let definitions = MaterialLayerCache.materialsData().flatMap {
            (try? JSONSerialization.jsonObject(with: $0)) as? NSDictionary
        }
        return MaterialLayerCache(definitions: definitions)
    }()

    package func visitLayers<V: MaterialLayerVisitor>(_ visitor: inout V) {
        switch id {
        case .coreMaterial:
            visitCoreMaterialLayers(&visitor)
        case let .layers(layers):
            layers.visit(&visitor)
        case .menu:
            var material = self
            material.id = colorScheme == .dark && colorSchemeContrast == .increased ? .regular : .thick
            material.visitLayers(&visitor)
        default:
            let layers = Self.$materialCache.access { $0[self] }
            for layer in layers {
                visitor.visit(layer: layer)
            }
        }
    }
}

// MARK: - MaterialLayerCache

private struct MaterialLayerCache {
    var definitions: NSDictionary?
    var cache: [Material.ResolvedMaterial: [AnyMaterialLayer]] = [:]

    subscript(material: Material.ResolvedMaterial) -> [AnyMaterialLayer] {
        mutating get {
            if let layers = cache[material] {
                return layers
            } else {
                let layers: [AnyMaterialLayer]
                switch material.id {
                case .secondaryBackground:
                    layers = createSystemBackground(material: material, level: 1)
                case .tertiaryBackground:
                    layers = createSystemBackground(material: material, level: 2)
                case .quaternaryBackground:
                    layers = createSystemBackground(material: material, level: 3)
                default:
                    layers = load(material: material)
                }
                cache[material] = layers
                return layers
            }
        }
    }

    static func materialsData() -> Data? {
        guard let url = Bundle(identifier: "com.apple.SwiftUI")?
            .url(forResource: "mac-materials", withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    func load(material: Material.ResolvedMaterial) -> [AnyMaterialLayer] {
        let category: String
        if material.flags.contains(.increasedContrast) {
            category = "increased-contrast"
        } else if material.flags.contains(.reduceTransparency) {
            category = "reduced-transparency"
        } else if material.flags.contains(.disableChameleon) {
            category = "non-chameleon"
        } else {
            category = "normal"
        }
        guard let definitions = definitions?.value(forKey: category) as? NSDictionary else {
            return []
        }
        var name: String
        switch material.id {
        case .ultraThin: name = "ultrathin"
        case .thin: name = "thin"
        case .regular: name = "medium"
        case .thick: name = "thick"
        case .ultraThick: name = "ultrathick"
        case .systemBars: name = "Header"
        case .contentFill: name = "ContentAreaFill"
        case .windowFill: name = "WindowFill"
        default: return []
        }
        name += material.colorScheme == .dark ? " dark" : " light"
        if !material.flags.contains(.isActive) {
            name += ", inactive"
        }
        guard let definitions = definitions.value(forKey: name) as? NSArray else {
            return []
        }

        func decodeFloatArray(_ array: NSArray) -> [Float]? {
            let values = array.compactMap { $0 as? NSNumber }.map { $0.floatValue }
            return values.count == array.count ? values : nil
        }

        var layers: [AnyMaterialLayer] = []
        for case let definition as NSDictionary in definitions {
            guard let type = definition.value(forKey: "type") as? String else {
                continue
            }
            var filters: [GraphicsFilter] = []
            if let definitions = definition.value(forKey: "filters") as? NSArray {
                for case let definition as NSDictionary in definitions {
                    switch definition.value(forKey: "type") as? String {
                    case "colorSaturate":
                        if let amount = definition.value(forKey: "amount") as? Double, amount != 1 {
                            filters.append(.saturation(amount))
                        }
                    case "colorBrightness":
                        if let amount = definition.value(forKey: "amount") as? Double, amount != 0 {
                            filters.append(.brightness(amount))
                        }
                    case "gaussianBlur":
                        if !material.flags.contains(.noBlur),
                           let radius = definition.value(forKey: "radius") as? Double,
                           radius > 0 {
                            filters.append(.blur(BlurStyle(radius: radius, isOpaque: true, dither: true)))
                        }
                    case "colorTint", "colorOffset":
                        if let array = definition.value(forKey: "matrix") as? NSArray,
                           let values = decodeFloatArray(array) {
                            let matrix = _ColorMatrix(floatArray: values)
                            if !matrix.isIdentity {
                                filters.append(.colorMatrix(matrix, premultiplied: false))
                            }
                        }
                    default:
                        break
                    }
                }
            }

            let content: DisplayList.Content.Value
            switch type {
            case "layer":
                guard var color = Self.parseColor(definition["bgColor"]) else {
                    Log.internalWarning("invalid bgColor for layer \(definition)")
                    continue
                }
                for filter in filters {
                    if let matrix = _ColorMatrix(filter) {
                        color = color.applying(matrix)
                    }
                }
                content = .color(color)
            case "backdrop":
                content = .backdrop(BackdropEffect(
                    scale: material.flags.contains(.noBlur) ? 1 : 0.25,
                    color: Self.parseColor(definition["bgColor"]) ?? .clear,
                    filters: filters
                ))
            case "chameleon":
                content = .chameleonColor(fallback: .gray_75, filters: filters)
            default:
                continue
            }
            let blendMode: BlendMode
            switch definition.value(forKey: "blend") as? String {
            case "lighten": blendMode = .lighten
            case "darken": blendMode = .darken
            case "plusL": blendMode = .plusLighter
            case "plusD": blendMode = .plusDarker
            default: blendMode = .normal
            }
            layers.append(AnyMaterialLayer(
                content: content,
                opacity: Float(definition.value(forKey: "opacity") as? Double ?? 1),
                blendMode: GraphicsBlendMode(blendMode)
            ))
        }
        return layers
    }

    static func parseColor(_ value: Any?) -> Color.Resolved? {
        guard let values = value as? NSArray, values.count == 4,
              let red = values[0] as? Double,
              let green = values[1] as? Double,
              let blue = values[2] as? Double,
              let opacity = values[3] as? Double else {
            return nil
        }
        return Color.Resolved(
            colorSpace: .sRGB,
            red: Float(red),
            green: Float(green),
            blue: Float(blue),
            opacity: Float(opacity)
        )
    }

    mutating func createSystemBackground(material: Material.ResolvedMaterial, level: Int) -> [AnyMaterialLayer] {
        var contentMaterial = material
        contentMaterial.id = .contentFill
        var layers = self[contentMaterial]
        #if OPENSWIFTUI_LINK_COREUI
        var environment = EnvironmentValues()
        CoreGlue2.shared.configureDefaultEnvironment(&environment)
        environment.colorScheme = material.colorScheme
        environment.colorSchemeContrast = material.colorSchemeContrast
        let name = CUIColorName(rawValue: material.colorSchemeContrast == .increased ? 25 : 24)!
        let entry = CUIDesignLibraryCacheKey(name: name, in: environment).fetch()
        let layer = AnyMaterialLayer(content: .color(entry.color), blendMode: GraphicsBlendMode(entry.blendMode))
        if material.colorScheme == .dark {
            for _ in 0..<level {
                layers.append(layer)
            }
        } else if level % 2 == 1 {
            layers.append(layer)
        }
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        #endif
        return layers
    }
}
#endif

#if os(visionOS)
// MARK: - EnvironmentValues + materialBaseColor

private struct MaterialBaseColorKey: EnvironmentKey {
    static var defaultValue: Color? { nil }
}

@available(visionOS 1.0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension EnvironmentValues {
    @usableFromInline
    var materialBaseColor: Color? {
        get { self[MaterialBaseColorKey.self] }
        set { self[MaterialBaseColorKey.self] = newValue }
    }
}

// MARK: - View + materialBaseColor

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, introduced: 1.0, deprecated: 2.0, message: "Use foregroundStyle(_:) instead")
extension View {
    @_spi(Private)
    @inlinable
    nonisolated public func materialBaseColor(_ color: Color?) -> some View {
        environment(\.materialBaseColor, color)
    }
}

// MARK: - GraphicsBlendMode

extension GraphicsBlendMode {
    package static let plusLIgnoreAlpha = GraphicsBlendMode.caFilter(CAFilter(type: "plusLIgnoreAlpha"))

    package static let subtractSIgnoreAlpha = GraphicsBlendMode.caFilter(CAFilter(type: "subtractSIgnoreAlpha"))

    package static let destOutPassthrough = GraphicsBlendMode.caFilter(CAFilter(type: "destOutPassthrough"))

    package static let plusDIgnoreAlpha = GraphicsBlendMode.caFilter(CAFilter(type: "plusDIgnoreAlpha"))

    package static func plusLIgnoreAlphaSourceOver(_ inputAmount: Double) -> GraphicsBlendMode {
        let filter = CAFilter(type: "plusLIgnoreAlphaSourceOverBlend")
        filter.setInput(value: inputAmount, key: .amount)
        return .caFilter(filter)
    }

    package init?(_ type: CAFilterType) {
        switch type {
        case .plusLIgnoreAlpha: self = .plusLIgnoreAlpha
        case .subtractSIgnoreAlpha: self = .subtractSIgnoreAlpha
        case .destOutPassthrough: self = .destOutPassthrough
        case .plusDIgnoreAlpha: self = .plusDIgnoreAlpha
        }
    }

    package enum CAFilterType: UInt, Hashable, ProtobufEnum {
        case plusLIgnoreAlpha = 1
        case subtractSIgnoreAlpha
        case destOutPassthrough
        case plusDIgnoreAlpha

        package init?(_ filter: CAFilter) {
            switch filter.type {
            case "plusLIgnoreAlpha": self = .plusLIgnoreAlpha
            case "subtractSIgnoreAlpha": self = .subtractSIgnoreAlpha
            case "destOutPassthrough": self = .destOutPassthrough
            case "plusDIgnoreAlpha": self = .plusDIgnoreAlpha
            default: return nil
            }
        }

        package func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}
#endif
