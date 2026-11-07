//
//  Material.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B2CCB444DA7C00CFB13A219298A4122C (SwiftUICore)

public import Foundation
import OpenAttributeGraphShims

// MARK: Material

/// A background material type.
///
/// You can apply a blur effect to a view that appears behind another view by
/// adding a material with the ``View/background(_:ignoresSafeAreaEdges:)``
/// modifier:
///
///     ZStack {
///         Color.teal
///         Label("Flag", systemImage: "flag.fill")
///             .padding()
///             .background(.regularMaterial)
///     }
///
/// In the example above, the ``ZStack`` layers a ``Label`` on top of the color
/// ``ShapeStyle/teal``. The background modifier inserts the
/// regular material below the label, blurring the part of
/// the background that the label --- including its padding --- covers:
///
/// ![A screenshot of a label on a teal background, where the area behind
/// the label appears blurred.](Material-1)
///
/// A material isn't a view, but adding a material is like inserting a
/// translucent layer between the modified view and its background:
///
/// ![An illustration that shows a background layer below a material layer,
/// which in turn appears below a foreground layer.](Material-2)
///
/// The blurring effect provided by the material isn't simple opacity. Instead,
/// it uses a platform-specific blending that produces an effect that resembles
/// heavily frosted glass. You can see this more easily with a complex
/// background, like an image:
///
///     ZStack {
///         Image("chili_peppers")
///             .resizable()
///             .aspectRatio(contentMode: .fit)
///         Label("Flag", systemImage: "flag.fill")
///             .padding()
///             .background(.regularMaterial)
///     }
///
/// ![A screenshot of a label on an image background, where the area behind
/// the label appears blurred.](Material-3)
///
/// For physical materials, the degree to which the background colors pass
/// through depends on the thickness. The effect also varies with light and
/// dark appearance:
///
/// ![An array of labels on a teal background. The first column, labeled light
/// appearance, shows a succession of labels on blurred backgrounds where the
/// blur increases from top to bottom, resulting in lighter and lighter blur.
/// The second column, labeled dark appearance, shows a similar succession of
/// labels, except that the blur gets darker from top to bottom. The rows are
/// labeled, from top to bottom: no material, ultra thin, thin, regular, thick,
/// and ultra thick.](Material-4)
///
/// If you need a material to have a particular shape, you can use the
/// ``View/background(_:in:fillStyle:)`` modifier. For example, you can
/// create a material with rounded corners:
///
///     ZStack {
///         Color.teal
///         Label("Flag", systemImage: "flag.fill")
///             .padding()
///             .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
///     }
///
/// ![A screenshot of a label on a teal background, where the area behind
/// the label appears blurred. The blurred area has rounded corners.](Material-5)
///
/// When you add a material, foreground elements exhibit vibrancy,
/// a context-specific blend of the foreground and background colors
/// that improves contrast. However using ``View/foregroundStyle(_:)``
/// to set a custom foreground style --- excluding the hierarchical styles,
/// like ``ShapeStyle/secondary-swift.type.property`` --- disables vibrancy.
///
/// > Note: A material blurs a background that's part of your app, but not
/// what appears behind your app on the screen.
/// For example, the content on the Home Screen doesn't affect the appearance
/// of a widget.
@available(OpenSwiftUI_v3_0, *)
public struct Material: Sendable {
    package enum ID: Hashable {
        case ultraThin
        case thin
        case regular
        case thick
        case ultraThick
        case systemBars
        #if os(macOS)
        case contentFill
        case windowFill
        case menu
        case secondaryBackground
        case tertiaryBackground
        case quaternaryBackground
        #elseif os(watchOS)
        case modal
        case toolbarButton
        #elseif os(iOS) || os(visionOS)
        case intelligenceLightSource_Unreactive
        case intelligenceLightSource_AudioReactive
        #endif
        #if os(visionOS)
        case pinched
        case selected
        case disabled
        case vibrantGlassContent
        case darkerGlass
        case lighterGlass
        case ultraDarkerGlass
        #endif
        indirect case coreMaterial(light: String, dark: String, bundle: Bundle?)
        #if os(macOS) || os(iOS)
        case provider(MaterialProviderBoxBase)
        case layers(Layers)
        #endif
    }

    package struct ResolvedMaterial: Hashable {
        package struct Flags: OptionSet, Hashable {
            package let rawValue: UInt32

            package init(rawValue: UInt32) { self.rawValue = rawValue }

            package static let darkColorScheme = Flags(rawValue: 1 << 0)

            package static let reduceTransparency = Flags(rawValue: 1 << 1)

            package static let increasedContrast = Flags(rawValue: 1 << 2)

            package static let disableChameleon = Flags(rawValue: 1 << 3)

            package static let isActive = Flags(rawValue: 1 << 4)

            package static let noBlur = Flags(rawValue: 1 << 5)

            package static let isEmphasized = Flags(rawValue: 1 << 6)

            package static let filtersInPlace = Flags(rawValue: 1 << 7)

            package static let noTransparentBlur = Flags(rawValue: 1 << 8)

            package static let isVisionEnabled = Flags(rawValue: 1 << 9)

            package static let noNormalizedEdgesBlur = Flags(rawValue: 1 << 10)

            package static let applyHardEdgesBlur = Flags(rawValue: 1 << 11)

            package init(environment: EnvironmentValues) {
                var flags = Flags()
                if environment.colorScheme == .dark {
                    flags.insert(.darkColorScheme)
                }
                #if os(visionOS)
                if environment.isVisionEnabled {
                    flags.insert(.isVisionEnabled)
                }
                if environment.isBackgroundOpaque {
                    flags.insert(.noTransparentBlur)
                }
                #else
                if environment.accessibilityReduceTransparency {
                    flags.insert(.reduceTransparency)
                }
                #endif
                if environment.colorSchemeContrast == .increased {
                    flags.insert(.increasedContrast)
                }
                #if os(macOS)
                if environment.reduceDesktopTinting {
                    flags.insert(.disableChameleon)
                }
                if isAppKitBased(), environment.backgroundProminence == .increased {
                    flags.insert(.isEmphasized)
                }
                #endif
                self = flags
            }
        }

        package var id: Material.ID

        package var flags: Material.ResolvedMaterial.Flags

        #if os(visionOS)
        package var styleID: ContentStyle.ID? = nil
        #endif

        package var colorScheme: ColorScheme {
            flags.contains(.darkColorScheme) ? .dark : .light
        }

        package var colorSchemeContrast: ColorSchemeContrast {
            flags.contains(.increasedContrast) ? .increased : .standard
        }

        package var isEmphasized: Bool {
            flags.contains(.isEmphasized)
        }
    }

    package var id: Material.ID

    package var flags: Material.ResolvedMaterial.Flags = []

    #if os(macOS)
    package var activeAppearance: MaterialActiveAppearance = .active
    #endif

    package init(_ id: Material.ID) {
        self.id = id
    }

    package func resolve(in env: EnvironmentValues, role: ShapeRole? = nil) -> Material.ResolvedMaterial {
        #if os(macOS) || os(iOS)
        if case let .provider(provider) = id {
            var context = Context(environment: env)
            context.role = role
            return ResolvedMaterial(id: .layers(provider.resolveLayers(in: context)), flags: flags)
        }
        #endif
        var flags = ResolvedMaterial.Flags(environment: env).union(flags)
        #if os(macOS)
        let appearance = activeAppearance == .automatic ? env.materialActiveAppearance : activeAppearance
        if appearance.resolve(material: id, in: env) {
            flags.insert(.isActive)
        }
        #endif
        #if os(visionOS)
        let styleID: ContentStyle.ID?
        switch id {
        case .ultraThin, .thin, .regular, .thick, .ultraThick,
             .pinched, .selected, .disabled, .darkerGlass, .lighterGlass, .ultraDarkerGlass:
            styleID = env.isVisionEnabled ? env.backgroundContentStyleID : nil
        default:
            styleID = nil
        }
        return ResolvedMaterial(id: id, flags: flags, styleID: styleID)
        #else
        return ResolvedMaterial(id: id, flags: flags)
        #endif
    }
}

// MARK: - Material options

@available(OpenSwiftUI_v4_0, *)
extension Material {
    @_spi(_)
    public func disablingBlur(_ flag: Bool = true) -> Material {
        var result = self
        result.flags.setValue(flag, for: .noBlur)
        return result
    }

    @_spi(_)
    public func applyingFiltersInPlace(_ flag: Bool = true) -> Material {
        var result = self
        result.flags.setValue(flag, for: .filtersInPlace)
        return result
    }
}

// MARK: - Material presets

@available(OpenSwiftUI_v3_0, *)
@available(OpenSwiftUI_watchOS_v5_0, *)
extension ShapeStyle where Self == Material {
    /// A material that's somewhat translucent.
    @_alwaysEmitIntoClient
    public static var regularMaterial: Material { .regular }

    /// A material that's more opaque than translucent.
    @_alwaysEmitIntoClient
    public static var thickMaterial: Material { .thick }

    /// A material that's more translucent than opaque.
    @_alwaysEmitIntoClient
    public static var thinMaterial: Material { .thin }

    /// A mostly translucent material.
    @_alwaysEmitIntoClient
    public static var ultraThinMaterial: Material { .ultraThin }

    /// A mostly opaque material.
    @_alwaysEmitIntoClient
    public static var ultraThickMaterial: Material { .ultraThick }
}

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension ShapeStyle where Self == Material {
    /// A material matching the style of system toolbars.
    @_alwaysEmitIntoClient
    public static var bar: Material { .bar }
}

@available(OpenSwiftUI_v3_0, *)
@available(OpenSwiftUI_watchOS_v5_0, *)
extension Material {
    /// A material that's somewhat translucent.
    public static let regular = Material(.regular)

    /// A material that's more opaque than translucent.
    public static let thick = Material(.thick)

    /// A material that's more translucent than opaque.
    public static let thin = Material(.thin)

    /// A mostly translucent material.
    public static let ultraThin = Material(.ultraThin)

    /// A mostly opaque material.
    public static let ultraThick = Material(.ultraThick)
}

@available(OpenSwiftUI_v3_0, *)
@available(OpenSwiftUI_watchOS_v5_0, *)
extension Material {
    @_spi(_)
    public static var pinched: Material {
        #if os(visionOS)
        Material(.pinched)
        #else
        Material(.regular)
        #endif
    }

    @_spi(_)
    public static var selected: Material {
        #if os(visionOS)
        Material(.selected)
        #else
        .pinched
        #endif
    }

    @_spi(_)
    public static var disabled: Material {
        #if os(visionOS)
        Material(.disabled)
        #else
        .pinched
        #endif
    }

    @_spi(_)
    public static func coreMaterial(bundle: Bundle? = nil, provider: @escaping (ColorScheme) -> String) -> Material {
        Material(.coreMaterial(light: provider(.light), dark: provider(.dark), bundle: bundle))
    }
}

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Material {
    /// A material matching the style of system toolbars.
    public static let bar = Material(.systemBars)
}

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Material {
    @available(*, deprecated, renamed: "bar")
    public static let chrome = Material(.systemBars)
}

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension Material {
    public static var modal: Material {
        #if os(watchOS)
        Material(.modal)
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension Material {
    public static var toolbarButton: Material {
        #if os(watchOS)
        Material(.toolbarButton)
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

#if os(macOS)
extension Material {
    package static let contentFill = Material(.contentFill)

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    @available(macCatalyst 17.0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static let windowFill = Material(.windowFill)

    package static let menu = Material(.menu)

    package static let secondaryBackground = Material(.secondaryBackground)

    package static let tertiaryBackground = Material(.tertiaryBackground)

    package static let quaternaryBackground = Material(.quaternaryBackground)
}
#endif


@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension Material {
    public static func _intelligenceLightSource(prefersAudioReactivity: Bool = false) -> Material {
        #if os(macOS) || os(watchOS)
        _openSwiftUIUnreachableCode()
        #else
        Material(prefersAudioReactivity ? .intelligenceLightSource_AudioReactive : .intelligenceLightSource_Unreactive)
        #endif
    }
}

// MARK: - View + Material

@_spi(_)
@available(OpenSwiftUI_v3_0, *)
extension View {
    @available(*, deprecated, renamed: "background(_:)")
    @_disfavoredOverload
    nonisolated public func backgroundMaterial(_ material: Material) -> some View {
        modifier(MaterialView(material: material, shape: Rectangle(), ignoredSafeAreaEdges: .all))
    }

    @available(*, deprecated, renamed: "background(_:in:)")
    @_disfavoredOverload
    nonisolated public func backgroundMaterial<S>(_ material: Material, in shape: S) -> some View where S: Shape {
        modifier(MaterialView(material: material, shape: shape))
    }

    @available(*, deprecated, renamed: "background(_:)")
    @_alwaysEmitIntoClient
    nonisolated public func backgroundMaterial(_v2: Void = (), _ material: Material) -> some View {
        background(material)
    }

    @available(*, deprecated, renamed: "background(_:in:)")
    @_alwaysEmitIntoClient
    nonisolated public func backgroundMaterial<S>(_v2: Void = (), _ material: Material, in shape: S) -> some View where S: Shape {
        background(material, in: shape)
    }
}

// MARK: - EnvironmentValues + backgroundMaterial

private struct BackgroundMaterialKey: EnvironmentKey {
    static var defaultValue: Material? { nil }
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    #if os(visionOS)
    package var backgroundContentStyleID: ContentStyle.ID? {
        switch backgroundMaterial?.id {
        case .ultraThin, .thin, .lighterGlass: .secondary
        case .regular, .darkerGlass: .tertiary
        case .thick, .ultraThick, .ultraDarkerGlass: .quaternary
        default: .primary
        }
    }
    #endif

    /// The material underneath the current view.
    ///
    /// This value is `nil` if the current background isn't one of the standard
    /// materials. If you set a material, the standard content styles enable
    /// their vibrant rendering modes.
    ///
    /// You set this value by calling one of the background modifiers that takes
    /// a ``ShapeStyle``, like ``View/background(_:ignoresSafeAreaEdges:)``
    /// or ``View/background(_:in:fillStyle:)``, and passing in a
    /// ``Material``. You can also set the value manually, using
    /// `nil` to disable vibrant rendering, or a ``Material`` instance to
    /// enable the vibrancy style associated with the specified material.
    public var backgroundMaterial: Material? {
        get { self[BackgroundMaterialKey.self] }
        set { self[BackgroundMaterialKey.self] = newValue }
    }
}

// MARK: - MaterialView

package struct MaterialView<S> where S: Shape {
    package var material: Material

    package var shape: S

    package var ignoredSafeAreaEdges: Edge.Set

    package init(material: Material, shape: S, ignoredSafeAreaEdges: Edge.Set = []) {
        self.material = material
        self.shape = shape
        self.ignoredSafeAreaEdges = ignoredSafeAreaEdges
    }

    private struct Background: Rule, AsyncAttribute {
        @Attribute var view: MaterialView

        var value: some View {
            view.shape.fill(view.material)
                .ignoresSafeArea(.container, edges: view.ignoredSafeAreaEdges)
        }
    }

    private struct ChildEnvironment: Rule {
        @Attribute var material: Material
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var shape = _ShapeStyle_Shape(operation: .modifyBackground(level: 0), environment: environment)
            material._apply(to: &shape)
            return shape.environment
        }
    }
}

extension MaterialView: PrimitiveView, MultiView {
    nonisolated package static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let background = Attribute(Background(view: view.value))
        return Background.Value.makeDebuggableView(view: .init(background), inputs: inputs)
    }
}

extension MaterialView: PrimitiveViewModifier, MultiViewModifier {
    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let background = Attribute(Background(view: modifier.value))
        var inputs = inputs
        inputs.environment = Attribute(ChildEnvironment(
            material: modifier[offset: { .of(&$0.material) }].value,
            environment: inputs.environment
        ))
        inputs.needsGeometry = true
        return makeSecondaryLayerView(
            secondaryLayer: background,
            alignment: nil,
            inputs: inputs,
            body: body,
            flipOrder: true
        )
    }
}

// MARK: - MaterialLayer

package protocol MaterialLayer {
    var content: DisplayList.Content.Value { get }

    var opacity: Float { get }

    var blendMode: GraphicsBlendMode { get }
}

extension MaterialLayer {
    package var opacity: Float {
        1
    }

    package var blendMode: GraphicsBlendMode {
        .normal
    }
}

package struct AnyMaterialLayer: MaterialLayer {
    package var content: DisplayList.Content.Value

    package var opacity: Float

    package var blendMode: GraphicsBlendMode

    package init(
        content: DisplayList.Content.Value,
        opacity: Float = 1,
        blendMode: GraphicsBlendMode = .normal
    ) {
        self.content = content
        self.opacity = opacity
        self.blendMode = blendMode
    }
}

package protocol MaterialLayerVisitor {
    mutating func visit<L>(layer: L) where L: MaterialLayer
}

// MARK: - Material + ShapeStyle

@available(OpenSwiftUI_v3_0, *)
extension Material: ShapeStyle, PrimitiveShapeStyle {
    nonisolated public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, Material>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard let level = levels.first else { return }
            let material = resolve(in: shape.environment, role: shape.role)
            shape.stylePack[name, level] = .init(.backgroundMaterial(material))
        case .fallbackColor:
            shape.result = .color(Color._background)
        case .modifyBackground:
            #if os(macOS)
            switch id {
            case .contentFill, .windowFill, .secondaryBackground, .tertiaryBackground, .quaternaryBackground:
                shape.environment.backgroundMaterial = nil
            default:
                shape.environment.backgroundMaterial = self
            }
            #else
            shape.environment.backgroundMaterial = self
            #endif
        case .copyStyle, .multiLevel, .primaryStyle:
            break
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }
}

// MARK: - ForegroundMaterialStyle

package struct ForegroundMaterialStyle: ShapeStyle, PrimitiveShapeStyle {
    package var material: Material

    package init(material: Material) {
        self.material = material
    }

    package func _apply(to shape: inout _ShapeStyle_Shape) {
        #if os(macOS) || os(iOS)
        if case let .provider(provider) = material.id {
            provider.applyForegroundStyle(to: &shape)
            return
        }
        #endif
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard let level = levels.first else { return }
            let id = ContentStyle.ID(truncatingLevel: level)
            shape.stylePack[name, level] = shape.resolveStyle(id: id, material: material)
        case .fallbackColor:
            SystemColorsStyle()._apply(to: &shape)
        default:
            break
        }
    }
}

extension _ShapeStyle_Shape {
    fileprivate func resolveStyle(id: ContentStyle.ID, material: Material) -> _ShapeStyle_Pack.Style {
        let style = ContentStyle.MaterialStyle(
            material: material.resolve(in: environment, role: nil),
            base: .init(id: id, primitive: .init(role))
        )
        return .init(.foregroundMaterial(style.resolveColor(in: environment), style))
    }
}

// MARK: - MaterialActiveAppearance

/// The behavior for how materials appear active and inactive.
///
/// On macOS, materials have active and inactive appearances that can reinforce
/// the active appearance of the window they are in:
/// - Materials used as a `window` container background and `bar` materials
///   will appear inactive when their containing window is inactive.
/// - All other materials will always appear active by default.
///
/// An explicit active appearance can be set to override a material's default
/// behavior. For example, materials used as the `window` container background
/// can be made to always appear active by setting the active appearance
/// behavior to be always active:
///
///     Text("Hello, World!")
///         .containerBackground(
///             Material.regular.materialActiveAppearance(.active),
///             for: .window)
///
@available(OpenSwiftUI_v6_0, *)
public struct MaterialActiveAppearance: Sendable, Equatable {
    private enum Storage {
        case automatic
        case active
        case inactive
        case matchWindow
    }

    private var storage: Storage

    /// Materials will automatically appear active or inactive based on context
    /// and platform convention.
    ///
    /// Examples of automatic behavior on macOS:
    /// - Materials used as a `window` container background will appear inactive
    /// when the containing window is inactive.
    /// - `Material.bar` materials will appear inactive when the containing
    /// window is inactive.
    /// - All other materials will appear as active.
    ///
    /// Materials always appear as active on all other platforms.
    public static let automatic = MaterialActiveAppearance(storage: .automatic)

    /// Materials will always appear active.
    public static let active = MaterialActiveAppearance(storage: .active)

    /// Materials will always appear inactive.
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public static let inactive = MaterialActiveAppearance(storage: .inactive)

    /// Materials will have an active or inactive appearance based on
    /// the active appearance of their window.
    ///
    /// On non-macOS platforms, materials will always appear as active.
    public static let matchWindow = MaterialActiveAppearance(storage: .matchWindow)

    #if os(macOS)
    fileprivate func resolve(material: Material.ID, in environment: EnvironmentValues) -> Bool {
        let appearsActive = environment.appearsActive
        let container = environment.containerBackgroundKind
        switch storage {
        case .automatic:
            return appearsActive || (material != .systemBars && container != .builtin(.window))
        case .active:
            return true
        case .inactive:
            return false
        case .matchWindow:
            return appearsActive
        }
    }
    #endif

    fileprivate struct Key: EnvironmentKey {
        static let defaultValue = MaterialActiveAppearance.automatic
    }
}

@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {
    /// The behavior materials should use for their active state, defaulting to
    /// `automatic`.
    public var materialActiveAppearance: MaterialActiveAppearance {
        get { self[MaterialActiveAppearance.Key.self] }
        set { self[MaterialActiveAppearance.Key.self] = newValue }
    }
}

@available(OpenSwiftUI_v6_0, *)
extension Material {
    /// Sets an explicit active appearance for this material.
    ///
    /// Materials used as the `window` container background on macOS will
    /// automatically appear inactive when their window appears inactive, but
    /// can be made to always appear active by setting the active appearance
    /// behavior to be always active:
    ///
    ///     Text("Hello, World!")
    ///         .containerBackground(
    ///             Material.regular.materialActiveAppearance(.active),
    ///             for: .window)
    ///
    public func materialActiveAppearance(_ appearance: MaterialActiveAppearance) -> Material {
        #if os(macOS)
        var result = self
        result.activeAppearance = appearance
        return result
        #else
        return self
        #endif
    }
}

@available(OpenSwiftUI_v6_0, *)
extension ShapeStyle {
    /// Sets an explicit active appearance for materials created by this style.
    public func materialActiveAppearance(_ appearance: MaterialActiveAppearance) -> some ShapeStyle {
        MaterialActiveAppearanceShapeStyle(base: self, appearance: appearance)
    }
}

@available(OpenSwiftUI_v6_0, *)
extension View {
    /// Sets an explicit active appearance for materials in this view.
    nonisolated public func materialActiveAppearance(_ appearance: MaterialActiveAppearance) -> some View {
        environment(\.materialActiveAppearance, appearance)
    }
}

private struct MaterialActiveAppearanceShapeStyle<Base>: ShapeStyle, PrimitiveShapeStyle where Base: ShapeStyle {
    var base: Base

    var appearance: MaterialActiveAppearance

    func _apply(to shape: inout _ShapeStyle_Shape) {
        shape.environment.materialActiveAppearance = appearance
        base._apply(to: &shape)
    }

    static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Base._apply(to: &type)
    }
}
