//
//  MaterialProvider.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 4075E3A4E56336DD739D990E781CBB12 (SwiftUICore)

package import OpenCoreGraphicsShims

#if os(macOS) || os(iOS)

// MARK: - MaterialProvider

package protocol MaterialProvider: Hashable {
    func resolveLayers(in context: Material.Context) -> [Material.Layer]

    func resolveForegroundStyle(level: Int, in context: Material.Context) -> Material.ForegroundStyle?
}

extension MaterialProvider {
    package func resolveForegroundStyle(level: Int, in context: Material.Context) -> Material.ForegroundStyle? {
        nil
    }
}

// MARK: - Material.Context

extension Material {
    package struct Context {
        package var environment: EnvironmentValues

        package var role: ShapeRole?

        package init(environment: EnvironmentValues) {
            self.environment = environment
            role = nil
        }
    }

    package init<P: MaterialProvider>(provider: P) {
        self.init(.provider(MaterialProviderBox(provider)))
    }
}

// MARK: - Material.Layer

extension Material {
    package struct Layer: Equatable {
        fileprivate var storage: Storage

        private var _opacity: Float = 1

        private var _blendMode: GraphicsBlendMode = .normal

        fileprivate enum Storage: Equatable {
            case color(Color.Resolved)
            case backdrop(BackdropEffect)
            #if os(macOS)
            case chameleon(Chameleon)
            #endif
        }

        #if os(macOS)
        fileprivate struct Chameleon: Equatable {
            var fallbackColor: Color.Resolved
            var filters: [GraphicsFilter]
        }
        #endif

        package static func color(_ color: Color.Resolved) -> Layer {
            Layer(storage: .color(color))
        }

        package static func backdrop(scale: CGFloat, color: Color.Resolved, filters: [Filter]) -> Layer {
            Layer(storage: .backdrop(BackdropEffect(
                scale: Float(scale),
                color: color,
                filters: filters.map(\.base)
            )))
        }

        #if os(macOS)
        package static func chameleon(fallbackColor: Color.Resolved, filters: [Filter]) -> Layer {
            Layer(storage: .chameleon(Chameleon(
                fallbackColor: fallbackColor,
                filters: filters.map(\.base)
            )))
        }
        #endif

        package func opacity(_ opacity: Double) -> Layer {
            var result = self
            result._opacity = Float(opacity)
            return result
        }

        package func blendMode(_ blendMode: BlendMode) -> Layer {
            var result = self
            result._blendMode = GraphicsBlendMode(blendMode)
            return result
        }

        package var opacity: Double {
            Double(_opacity)
        }

        package var blendMode: GraphicsContext.BlendMode? {
            guard case let .blendMode(mode) = _blendMode else { return nil }
            return mode
        }

        package var compositingFilter: Any? {
            _blendMode.filter(compositingGroup: false)
        }

        package var contents: Contents {
            switch storage {
            case let .color(color): .color(color)
            case let .backdrop(backdrop): .backdrop(.init(backdrop: backdrop))
            #if os(macOS)
            case let .chameleon(chameleon): .chameleon(.init(chameleon: chameleon))
            #endif
            }
        }

        fileprivate struct Wrapper: MaterialLayer {
            var layer: Layer

            var content: DisplayList.Content.Value {
                switch layer.storage {
                case let .color(color): .color(color)
                case let .backdrop(backdrop): .backdrop(backdrop)
                #if os(macOS)
                case let .chameleon(chameleon):
                    .chameleonColor(fallback: chameleon.fallbackColor, filters: chameleon.filters)
                #endif
                }
            }

            var opacity: Float {
                layer._opacity
            }

            var blendMode: GraphicsBlendMode {
                layer._blendMode
            }
        }
    }
}

// MARK: - Material.Layer.Filter

extension Material.Layer {
    package struct Filter: Equatable {
        fileprivate var base: GraphicsFilter

        package static var averageColor: Filter {
            Filter(base: .averageColor)
        }

        package static func brightness(amount: Double) -> Filter {
            Filter(base: .brightness(amount))
        }

        package static func colorCurves(
            red: SIMD4<Float>,
            green: SIMD4<Float>,
            blue: SIMD4<Float>,
            alpha: SIMD4<Float>
        ) -> Filter {
            Filter(base: .colorCurves(.init(
                redCurve: .init((red.x, red.y, red.z, red.w)),
                greenCurve: .init((green.x, green.y, green.z, green.w)),
                blueCurve: .init((blue.x, blue.y, blue.z, blue.w)),
                opacityCurve: .init((alpha.x, alpha.y, alpha.z, alpha.w))
            )))
        }

        package static func saturation(amount: Double) -> Filter {
            Filter(base: .saturation(amount))
        }

        package static func colorMatrix(_ matrix: _ColorMatrix, isPremultiplied: Bool) -> Filter {
            Filter(base: .colorMatrix(matrix, premultiplied: isPremultiplied))
        }

        package static func gaussianBlur(radius: CGFloat, isOpaque: Bool, isDithered: Bool) -> Filter {
            Filter(base: .blur(.init(radius: radius, isOpaque: isOpaque, dither: isDithered)))
        }

        package static func luminanceCurve(_ curve: SIMD4<Float>, amount: Double) -> Filter {
            Filter(base: .luminanceCurve(.init(
                curve: .init((curve.x, curve.y, curve.z, curve.w)),
                amount: Float(amount)
            )))
        }

        package static func variableBlur(
            radius: CGFloat,
            isOpaque: Bool,
            isDithered: Bool,
            mask: CGImage
        ) -> Filter {
            let image = GraphicsImage(
                contents: .cgImage(mask),
                scale: 1,
                unrotatedPixelSize: CGSize(width: mask.width, height: mask.height),
                orientation: .up,
                isTemplate: false
            )
            return Filter(base: .variableBlur(.init(
                radius: radius,
                isOpaque: isOpaque,
                dither: isDithered,
                mask: .image(image)
            )))
        }

        package var contents: Contents {
            switch base {
            case .averageColor: .averageColor(.init())
            case let .brightness(amount): .brightness(.init(amount: amount))
            case let .colorCurves(curves): .colorCurves(.init(base: curves))
            case let .saturation(amount): .saturation(.init(amount: amount))
            case let .colorMatrix(matrix, premultiplied):
                .colorMatrix(.init(matrix: matrix, isPremultiplied: premultiplied))
            case let .blur(blur): .gaussianBlur(.init(base: blur))
            case let .luminanceCurve(curve): .luminanceCurve(.init(base: curve))
            case let .variableBlur(blur): .variableBlur(.init(base: blur))
            default: _openSwiftUIUnreachableCode()
            }
        }
    }
}

// MARK: - Material.ForegroundStyle

extension Material {
    package struct ForegroundStyle: Equatable {
        fileprivate var storage: Storage

        fileprivate enum Storage: Equatable {
            case color(Color.Resolved)
            case colorBlend(Color.Resolved, BlendMode)
            case colorMatrix(_ColorMatrix)
        }

        package static func color(_ color: Color.Resolved) -> ForegroundStyle {
            ForegroundStyle(storage: .color(color))
        }

        package static func color(_ color: Color.Resolved, blendMode: BlendMode) -> ForegroundStyle {
            ForegroundStyle(storage: .colorBlend(color, blendMode))
        }

        package static func colorMatrix(_ matrix: _ColorMatrix) -> ForegroundStyle {
            ForegroundStyle(storage: .colorMatrix(matrix))
        }

        package var contents: Contents {
            Contents(storage)
        }
    }
}

// MARK: - Material.Layers

extension Material {
    package struct Layers: Hashable {
        package var layers: [Layer]

        package init(_ layers: [Layer]) {
            self.layers = layers
        }

        package func hash(into hasher: inout Hasher) {
            _openSwiftUIEmptyStub()
        }

        package func visit<V: MaterialLayerVisitor>(_ visitor: inout V) {
            for layer in layers {
                visitor.visit(layer: Layer.Wrapper(layer: layer))
            }
        }
    }
}

// MARK: - MaterialProviderBoxBase

package class MaterialProviderBoxBase: Hashable {
    package func resolveLayers(in context: Material.Context) -> Material.Layers {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func applyForegroundStyle(to shape: inout _ShapeStyle_Shape) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func isEqual(to other: MaterialProviderBoxBase) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package static func == (lhs: MaterialProviderBoxBase, rhs: MaterialProviderBoxBase) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

// MARK: - MaterialProviderBox

private final class MaterialProviderBox<P: MaterialProvider>: MaterialProviderBoxBase {
    let provider: P

    init(_ provider: P) {
        self.provider = provider
    }

    override func resolveLayers(in context: Material.Context) -> Material.Layers {
        Material.Layers(provider.resolveLayers(in: context))
    }

    override func applyForegroundStyle(to shape: inout _ShapeStyle_Shape) {
        guard !shape.activeRecursiveStyles.contains(.materialProvider) else {
            SystemColorsStyle()._apply(to: &shape)
            return
        }
        let activeStyles = shape.activeRecursiveStyles
        shape.activeRecursiveStyles.insert(.materialProvider)
        defer { shape.activeRecursiveStyles = activeStyles }
        var context = Material.Context(environment: shape.environment)
        context.role = shape.role
        switch shape.operation {
        case let .prepareText(level):
            guard let style = provider.resolveForegroundStyle(level: level, in: context) else {
                SystemColorsStyle()._apply(to: &shape)
                return
            }
            switch style.storage {
            case let .color(color):
                shape.result = .preparedText(.foregroundColor(Color(color)))
            case .colorBlend, .colorMatrix:
                shape.result = .preparedText(.foregroundKeyColor)
            }
        case let .fallbackColor(level):
            guard let style = provider.resolveForegroundStyle(level: level, in: context) else {
                SystemColorsStyle()._apply(to: &shape)
                return
            }
            switch style.storage {
            case let .color(color), let .colorBlend(color, _):
                shape.result = .color(Color(color))
            case .colorMatrix:
                break
            }
        case let .resolveStyle(name, levels):
            guard name == .foreground else {
                SystemColorsStyle()._apply(to: &shape)
                return
            }
            for level in levels {
                guard let foreground = provider.resolveForegroundStyle(level: level, in: context) else {
                    shape.operation = .resolveStyle(name: name, levels: level ..< level + 1)
                    SystemColorsStyle()._apply(to: &shape)
                    continue
                }
                var style = shape.stylePack[name, level]
                switch foreground.storage {
                case let .color(color):
                    style.fill = .color(color)
                case let .colorBlend(color, blendMode):
                    style.fill = .color(color)
                    style.applyBlend(GraphicsBlendMode(blendMode))
                case let .colorMatrix(matrix):
                    style.fill = .vibrantMatrix(matrix)
                }
                shape.stylePack[name, level] = style
            }
        default:
            break
        }
    }

    override func isEqual(to other: MaterialProviderBoxBase) -> Bool {
        guard let other = other as? MaterialProviderBox<P> else { return false }
        return provider == other.provider
    }

    override func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }
}

// MARK: - Material.Layer.Contents

extension Material.Layer {
    package enum Contents {
        case color(Color.Resolved)
        case backdrop(Backdrop)
        #if os(macOS)
        case chameleon(Chameleon)
        #endif

        package struct Backdrop {
            fileprivate var backdrop: BackdropEffect

            package var scale: CGFloat { CGFloat(backdrop.scale) }

            package var color: Color.Resolved { backdrop.color }

            package var filters: [Filter] { backdrop.filters.map { Filter(base: $0) } }
        }

        #if os(macOS)
        package struct Chameleon {
            fileprivate var chameleon: Material.Layer.Chameleon
        }
        #endif
    }
}

// MARK: - Material.Layer.Filter.Contents

extension Material.Layer.Filter {
    package enum Contents {
        case averageColor(AverageColor)
        case brightness(Brightness)
        case colorCurves(ColorCurves)
        case saturation(Saturation)
        case colorMatrix(ColorMatrix)
        case gaussianBlur(GaussianBlur)
        case luminanceCurve(LuminanceCurve)
        case variableBlur(VariableBlur)

        package struct AverageColor {}

        package struct Brightness {
            package var amount: Double
        }

        package struct ColorCurves {
            fileprivate var base: GraphicsFilter.ColorCurves

            package var redCurve: SIMD4<Float> {
                let values = base.redCurve.values
                return SIMD4(values.0, values.1, values.2, values.3)
            }

            package var greenCurve: SIMD4<Float> {
                let values = base.greenCurve.values
                return SIMD4(values.0, values.1, values.2, values.3)
            }

            package var blueCurve: SIMD4<Float> {
                let values = base.blueCurve.values
                return SIMD4(values.0, values.1, values.2, values.3)
            }

            package var opacityCurve: SIMD4<Float> {
                let values = base.opacityCurve.values
                return SIMD4(values.0, values.1, values.2, values.3)
            }
        }

        package struct Saturation {
            package var amount: Double
        }

        package struct ColorMatrix {
            package var matrix: _ColorMatrix

            package var isPremultiplied: Bool
        }

        package struct GaussianBlur {
            fileprivate var base: BlurStyle

            package var radius: CGFloat { base.radius }

            package var isOpaque: Bool { base.isOpaque }

            package var isDithered: Bool { base.dither }
        }

        package struct LuminanceCurve {
            fileprivate var base: GraphicsFilter.LuminanceCurve

            package var curve: SIMD4<Float> {
                let values = base.curve.values
                return SIMD4(values.0, values.1, values.2, values.3)
            }

            package var amount: Double { Double(base.amount) }
        }

        package struct VariableBlur {
            fileprivate var base: VariableBlurStyle

            package var radius: CGFloat { base.radius }

            package var isOpaque: Bool { base.isOpaque }

            package var isDithered: Bool { base.dither }

            package var mask: Mask? {
                guard case let .image(image) = base.mask,
                      case let .cgImage(image) = image.contents else { return nil }
                return .cgImage(image)
            }

            package enum Mask {
                case cgImage(CGImage)
            }
        }
    }
}

// MARK: - Material.ForegroundStyle.Contents

extension Material.ForegroundStyle {
    package enum Contents {
        case color(Color.Resolved, GraphicsContext.BlendMode)
        case colorMatrix(_ColorMatrix)

        fileprivate init(_ storage: Material.ForegroundStyle.Storage) {
            switch storage {
            case let .color(color):
                self = .color(color, .normal)
            case let .colorBlend(color, blend):
                guard case let .blendMode(mode) = GraphicsBlendMode(blend) else {
                    preconditionFailure()
                }
                self = .color(color, mode)
            case let .colorMatrix(matrix):
                self = .colorMatrix(matrix)
            }
        }
    }
}

#endif
