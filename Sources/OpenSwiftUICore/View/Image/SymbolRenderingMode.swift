//
//  SymbolRenderingMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FE3FF33C1D9A704A22DF5519034B23F2 (SwiftUICore)

// MARK: - SymbolRenderingMode

/// A symbol rendering mode.
@available(OpenSwiftUI_v3_0, *)
public struct SymbolRenderingMode: Sendable {
    package enum Storage: Equatable, Sendable {
        case monochrome
        case multicolor
        case hierarchical
        case palette
        case preferred
        case hierarchicalUnlessSlashed
        case hierarchicalSlashBadge
        case paletteSlashBadge
    }

    package var storage: Storage

    package init(storage: Storage) {
        self.storage = storage
    }

    /// A mode that renders symbols as a single layer filled with the
    /// foreground style.
    ///
    /// For example, you can render a filled exclamation mark triangle in
    /// purple:
    ///
    ///     Image(systemName: "exclamationmark.triangle.fill")
    ///         .symbolRenderingMode(.monochrome)
    ///         .foregroundStyle(Color.purple)
    public static let monochrome = SymbolRenderingMode(storage: .monochrome)

    /// A mode that renders symbols as multiple layers with their inherit
    /// styles.
    ///
    /// The layers may be filled with their own inherent styles, or the
    /// foreground style. For example, you can render a filled exclamation
    /// mark triangle in its inherent colors, with yellow for the triangle and
    /// white for the exclamation mark:
    ///
    ///     Image(systemName: "exclamationmark.triangle.fill")
    ///         .symbolRenderingMode(.multicolor)
    public static let multicolor = SymbolRenderingMode(storage: .multicolor)

    /// A mode that renders symbols as multiple layers, with different opacities
    /// applied to the foreground style.
    ///
    /// OpenSwiftUI fills the first layer with the foreground style, and the others
    /// the secondary, and tertiary variants of the foreground style. You can
    /// specify these styles explicitly using the ``View/foregroundStyle(_:_:)``
    /// and ``View/foregroundStyle(_:_:_:)`` modifiers. If you only specify
    /// a primary foreground style, OpenSwiftUI automatically derives
    /// the others from that style. For example, you can render a filled
    /// exclamation mark triangle with purple as the tint color for the
    /// exclamation mark, and lower opacity purple for the triangle:
    ///
    ///     Image(systemName: "exclamationmark.triangle.fill")
    ///         .symbolRenderingMode(.hierarchical)
    ///         .foregroundStyle(Color.purple)
    public static let hierarchical = SymbolRenderingMode(storage: .hierarchical)

    /// A mode that renders symbols as multiple layers, with different styles
    /// applied to the layers.
    ///
    /// In this mode OpenSwiftUI maps each successively defined layer in the image
    /// to the next of the primary, secondary, and tertiary variants of the
    /// foreground style. You can specify these styles explicitly using the
    /// ``View/foregroundStyle(_:_:)`` and ``View/foregroundStyle(_:_:_:)``
    /// modifiers. If you only specify a primary foreground style, OpenSwiftUI
    /// automatically derives the others from that style. For example, you can
    /// render a filled exclamation mark triangle with yellow as the tint color
    /// for the exclamation mark, and fill the triangle with cyan:
    ///
    ///     Image(systemName: "exclamationmark.triangle.fill")
    ///         .symbolRenderingMode(.palette)
    ///         .foregroundStyle(Color.yellow, Color.cyan)
    ///
    /// You can also omit the symbol rendering mode, as specifying multiple
    /// foreground styles implies switching to palette rendering mode:
    ///
    ///     Image(systemName: "exclamationmark.triangle.fill")
    ///         .foregroundStyle(Color.yellow, Color.cyan)
    public static let palette = SymbolRenderingMode(storage: .palette)

    package static let preferred = SymbolRenderingMode(storage: .preferred)

    package static let preferredIfEnabled: SymbolRenderingMode? = {
        _SemanticFeature_v4.isEnabled ? .preferred : nil
    }()
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension SymbolRenderingMode {
    public static let hierarchicalUnlessSlashed = SymbolRenderingMode(storage: .hierarchicalUnlessSlashed)

    public static let hierarchicalSlashBadge = SymbolRenderingMode(storage: .hierarchicalSlashBadge)

    public static let paletteSlashBadge = SymbolRenderingMode(storage: .paletteSlashBadge)
}

// MARK: - SymbolRenderingMode.Storage + Codable

extension SymbolRenderingMode.Storage: Codable {
    private enum CodingKeys: CodingKey {
        case monochrome
        case multicolor
        case hierarchical
        case palette
        case preferred
        case hierarchicalUnlessSlashed
        case hierarchicalSlashBadge
        case paletteSlashBadge
    }

    private enum MonochromeCodingKeys: CodingKey {}
    private enum MulticolorCodingKeys: CodingKey {}
    private enum HierarchicalCodingKeys: CodingKey {}
    private enum PaletteCodingKeys: CodingKey {}
    private enum PreferredCodingKeys: CodingKey {}
    private enum HierarchicalUnlessSlashedCodingKeys: CodingKey {}
    private enum HierarchicalSlashBadgeCodingKeys: CodingKey {}
    private enum PaletteSlashBadgeCodingKeys: CodingKey {}

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .monochrome:
            _ = container.nestedContainer(keyedBy: MonochromeCodingKeys.self, forKey: .monochrome)
        case .multicolor:
            _ = container.nestedContainer(keyedBy: MulticolorCodingKeys.self, forKey: .multicolor)
        case .hierarchical:
            _ = container.nestedContainer(keyedBy: HierarchicalCodingKeys.self, forKey: .hierarchical)
        case .palette:
            _ = container.nestedContainer(keyedBy: PaletteCodingKeys.self, forKey: .palette)
        case .preferred:
            _ = container.nestedContainer(keyedBy: PreferredCodingKeys.self, forKey: .preferred)
        case .hierarchicalUnlessSlashed:
            _ = container.nestedContainer(keyedBy: HierarchicalUnlessSlashedCodingKeys.self, forKey: .hierarchicalUnlessSlashed)
        case .hierarchicalSlashBadge:
            _ = container.nestedContainer(keyedBy: HierarchicalSlashBadgeCodingKeys.self, forKey: .hierarchicalSlashBadge)
        case .paletteSlashBadge:
            _ = container.nestedContainer(keyedBy: PaletteSlashBadgeCodingKeys.self, forKey: .paletteSlashBadge)
        }
    }
    
    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = container.allKeys
        guard keys.count == 1 else {
            throw DecodingError.typeMismatch(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one."
                )
            )
        }
        switch keys[0] {
        case .monochrome:
            _ = try container.nestedContainer(keyedBy: MonochromeCodingKeys.self, forKey: .monochrome)
            self = .monochrome
        case .multicolor:
            _ = try container.nestedContainer(keyedBy: MulticolorCodingKeys.self, forKey: .multicolor)
            self = .multicolor
        case .hierarchical:
            _ = try container.nestedContainer(keyedBy: HierarchicalCodingKeys.self, forKey: .hierarchical)
            self = .hierarchical
        case .palette:
            _ = try container.nestedContainer(keyedBy: PaletteCodingKeys.self, forKey: .palette)
            self = .palette
        case .preferred:
            _ = try container.nestedContainer(keyedBy: PreferredCodingKeys.self, forKey: .preferred)
            self = .preferred
        case .hierarchicalUnlessSlashed:
            _ = try container.nestedContainer(keyedBy: HierarchicalUnlessSlashedCodingKeys.self, forKey: .hierarchicalUnlessSlashed)
            self = .hierarchicalUnlessSlashed
        case .hierarchicalSlashBadge:
            _ = try container.nestedContainer(keyedBy: HierarchicalSlashBadgeCodingKeys.self, forKey: .hierarchicalSlashBadge)
            self = .hierarchicalSlashBadge
        case .paletteSlashBadge:
            _ = try container.nestedContainer(keyedBy: PaletteSlashBadgeCodingKeys.self, forKey: .paletteSlashBadge)
            self = .paletteSlashBadge
        }
    }
}

// MARK: - EnvironmentValues + symbolRenderingMode

private struct SymbolRenderingModeKey: EnvironmentKey {
    static let defaultValue: SymbolRenderingMode? = nil
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {

    /// The current symbol rendering mode, or `nil` denoting that the
    /// mode is picked automatically using the current image and
    /// foreground style as parameters.
    public var symbolRenderingMode: SymbolRenderingMode? {
        get { self[SymbolRenderingModeKey.self] }
        set { self[SymbolRenderingModeKey.self] = newValue }
    }
}

// MARK: - View + symbolRenderingMode

@available(OpenSwiftUI_v3_0, *)
extension View {

    /// Sets the rendering mode for symbol images within this view.
    ///
    /// - Parameter mode: The symbol rendering mode to use.
    ///
    /// - Returns: A view that uses the rendering mode you supply.
    @inlinable
    nonisolated public func symbolRenderingMode(_ mode: SymbolRenderingMode?) -> some View {
        return environment(\.symbolRenderingMode, mode)
    }
}

// MARK: - Image + symbolRenderingMode

@available(OpenSwiftUI_v3_0, *)
extension Image {

    /// Sets the rendering mode for symbol images within this view.
    ///
    /// - Parameter mode: The symbol rendering mode to use.
    ///
    /// - Returns: A view that uses the rendering mode you supply.
    public func symbolRenderingMode(_ mode: SymbolRenderingMode?) -> Image {
        Image(
            SymbolRenderingModeProvider(
                base: self,
                mode: mode?.storage
            )
        )
    }

    private struct SymbolRenderingModeProvider: ImageProvider {
        var base: Image

        var mode: SymbolRenderingMode.Storage?

        func resolve(in context: ImageResolutionContext) -> Image.Resolved {
            var context = context
            context.symbolRenderingMode = mode.map { .init(storage: $0) }
            return base.resolve(in: context)
        }

        func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
            var context = context
            context.symbolRenderingMode = mode.map { .init(storage: $0) }
            return base.resolveNamedImage(in: context)
        }
    }
}
