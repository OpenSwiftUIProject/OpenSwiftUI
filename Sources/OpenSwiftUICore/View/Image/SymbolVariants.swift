//
//  SymbolVariants.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 10D838C6E672964CE3DB0EADFD20CA25 (SwiftUICore)

public import Foundation

/// A variant of a symbol.
///
/// Many of the
/// [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
/// that you can add to your app using an ``Image`` or a ``Label`` instance
/// have common variants, like a filled version or a version that's
/// contained within a circle. The symbol's name indicates the variant:
///
///     VStack(alignment: .leading) {
///         Label("Default", systemImage: "heart")
///         Label("Fill", systemImage: "heart.fill")
///         Label("Circle", systemImage: "heart.circle")
///         Label("Circle Fill", systemImage: "heart.circle.fill")
///     }
///
/// ![A screenshot showing an outlined heart, a filled heart, a heart in
/// a circle, and a filled heart in a circle, each with a text label
/// describing the symbol.](SymbolVariants-1)
///
/// You can configure a part of your view hierarchy to use a particular variant
/// for all symbols in that view and its child views using `SymbolVariants`.
/// Add the ``View/symbolVariant(_:)`` modifier to a view to set a variant
/// for that view's environment. For example, you can use the modifier to
/// create the same set of labels as in the example above, using only the
/// base name of the symbol in the label declarations:
///
///     VStack(alignment: .leading) {
///         Label("Default", systemImage: "heart")
///         Label("Fill", systemImage: "heart")
///             .symbolVariant(.fill)
///         Label("Circle", systemImage: "heart")
///             .symbolVariant(.circle)
///         Label("Circle Fill", systemImage: "heart")
///             .symbolVariant(.circle.fill)
///     }
///
/// Alternatively, you can set the variant in the environment directly by
/// passing the ``EnvironmentValues/symbolVariants`` environment value to the
/// ``View/environment(_:_:)`` modifier:
///
///     Label("Fill", systemImage: "heart")
///         .environment(\.symbolVariants, .fill)
///
/// OpenSwiftUI sets a variant for you in some environments. For example, OpenSwiftUI
/// automatically applies the ``SymbolVariants/fill-swift.type.property``
/// symbol variant for items that appear in the `content` closure of the
/// ``View/swipeActions(edge:allowsFullSwipe:content:)``
/// method, or as the tab bar items of a ``TabView``.
@available(OpenSwiftUI_v3_0, *)
public struct SymbolVariants: Hashable, Sendable {
    private struct Flags: OptionSet, Hashable {
        var rawValue: UInt8

        static var fill: Flags { .init(rawValue: 1 << 0) }

        static var slash: Flags { .init(rawValue: 1 << 1) }

        static var background: Flags { .init(rawValue: 1 << 2) }
    }

    private var flags: Flags

    package enum Shape: Hashable {
        case circle
        case square
        case rectangle

        package var suffix: String {
            switch self {
            case .circle: ".circle"
            case .square: ".square"
            case .rectangle: ".rectangle"
            }
        }
    }

    var shape: Shape?

    /// No variant for a symbol.
    ///
    /// Using this variant with the ``View/symbolVariant(_:)`` modifier doesn't
    /// have any effect. Instead, to show a symbol that ignores the current
    /// variant, directly set the ``EnvironmentValues/symbolVariants``
    /// environment value to `none` using the ``View/environment(_:_:)``
    /// modifer:
    ///
    ///     HStack {
    ///         Image(systemName: "heart")
    ///         Image(systemName: "heart")
    ///             .environment(\.symbolVariants, .none)
    ///     }
    ///     .symbolVariant(.fill)
    ///
    /// ![A screenshot of two heart symbols. The first is filled while the
    /// second is outlined.](SymbolVariants-none-1)
    public static let none: SymbolVariants = .init(flags: [], shape: nil)

    /// A variant that encapsulates the symbol in a circle.
    ///
    /// Use this variant with a call to the ``View/symbolVariant(_:)`` modifier
    /// to draw symbols in a circle, for those symbols that have a circle
    /// variant:
    ///
    ///     VStack(spacing: 20) {
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         .symbolVariant(.circle)
    ///     }
    ///
    /// ![A screenshot showing two rows of four symbols each. Both rows contain
    /// a flag, a heart, a bolt, and a star. The symbols in the second row are
    /// versions of the symbols in the first row, but each is enclosed in a
    /// circle.](SymbolVariants-circle-1)
    public static let circle: SymbolVariants = .init(flags: [], shape: .circle)

    /// A variant that encapsulates the symbol in a square.
    ///
    /// Use this variant with a call to the ``View/symbolVariant(_:)`` modifier
    /// to draw symbols in a square, for those symbols that have a square
    /// variant:
    ///
    ///     VStack(spacing: 20) {
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         .symbolVariant(.square)
    ///     }
    ///
    /// ![A screenshot showing two rows of four symbols each. Both rows contain
    /// a flag, a heart, a bolt, and a star. The symbols in the second row are
    /// versions of the symbols in the first row, but each is enclosed in a
    /// square.](SymbolVariants-square-1)
    public static let square: SymbolVariants = .init(flags: [], shape: .square)

    /// A variant that encapsulates the symbol in a rectangle.
    ///
    /// Use this variant with a call to the ``View/symbolVariant(_:)`` modifier
    /// to draw symbols in a rectangle, for those symbols that have a rectangle
    /// variant:
    ///
    ///     VStack(spacing: 20) {
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "plus")
    ///             Image(systemName: "minus")
    ///             Image(systemName: "xmark")
    ///             Image(systemName: "checkmark")
    ///         }
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "plus")
    ///             Image(systemName: "minus")
    ///             Image(systemName: "xmark")
    ///             Image(systemName: "checkmark")
    ///         }
    ///         .symbolVariant(.rectangle)
    ///     }
    ///
    /// ![A screenshot showing two rows of four symbols each. Both rows contain
    /// a plus sign, a minus sign, a multiplication sign, and a check mark.
    /// The symbols in the second row are versions of the symbols in the first
    /// row, but each is enclosed in a rectangle.](SymbolVariants-rectangle-1)
    public static let rectangle: SymbolVariants = .init(flags: [], shape: .rectangle)

    /// A version of the variant that's encapsulated in a circle.
    ///
    /// Use this property to modify a variant like ``fill-swift.property``
    /// so that it's also contained in a circle:
    ///
    ///     Label("Fill Circle", systemImage: "bolt")
    ///         .symbolVariant(.fill.circle)
    ///
    /// ![A screenshot of a label that shows a bolt in a filled circle
    /// beside the words Fill Circle.](SymbolVariants-circle-2)
    public var circle: SymbolVariants {
        SymbolVariants(flags: flags, shape: .circle)
    }

    /// A version of the variant that's encapsulated in a square.
    ///
    /// Use this property to modify a variant like ``fill-swift.property``
    /// so that it's also contained in a square:
    ///
    ///     Label("Fill Square", systemImage: "star")
    ///         .symbolVariant(.fill.square)
    ///
    /// ![A screenshot of a label that shows a star in a filled square
    /// beside the words Fill Square.](SymbolVariants-square-2)
    public var square: SymbolVariants {
        SymbolVariants(flags: flags, shape: .square)
    }

    /// A version of the variant that's encapsulated in a rectangle.
    ///
    /// Use this property to modify a variant like ``fill-swift.property``
    /// so that it's also contained in a rectangle:
    ///
    ///     Label("Fill Rectangle", systemImage: "plus")
    ///         .symbolVariant(.fill.rectangle)
    ///
    /// ![A screenshot of a label that shows a plus sign in a filled rectangle
    /// beside the words Fill Rectangle.](SymbolVariants-rectangle-2)
    public var rectangle: SymbolVariants {
        SymbolVariants(flags: flags, shape: .rectangle)
    }

    /// A variant that fills the symbol.
    ///
    /// Use this variant with a call to the ``View/symbolVariant(_:)`` modifier
    /// to draw filled symbols, for those symbols that have a filled variant:
    ///
    ///     VStack(spacing: 20) {
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         .symbolVariant(.fill)
    ///     }
    ///
    /// ![A screenshot showing two rows of four symbols each. Both rows contain
    /// a flag, a heart, a bolt, and a star. The symbols in the second row are
    /// filled version of the symbols in the first row.](SymbolVariants-fill-1)
    public static let fill: SymbolVariants = .init(flags: [.fill], shape: nil)

    /// A filled version of the variant.
    ///
    /// Use this property to modify a shape variant like
    /// ``circle-swift.type.property`` so that it's also filled:
    ///
    ///     Label("Circle Fill", systemImage: "flag")
    ///         .symbolVariant(.circle.fill)
    ///
    /// ![A screenshot of a label that shows a flag in a filled circle
    /// beside the words Circle Fill.](SymbolVariants-fill-2)
    public var fill: SymbolVariants {
        SymbolVariants(flags: flags.union(.fill), shape: shape)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static let background: SymbolVariants = .init(flags: [.background], shape: nil)

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public var background: SymbolVariants {
        SymbolVariants(flags: flags.union(.background), shape: shape)
    }

    /// A variant that draws a slash through the symbol.
    ///
    /// Use this variant with a call to the ``View/symbolVariant(_:)`` modifier
    /// to draw symbols with a slash, for those symbols that have such a
    /// variant:
    ///
    ///     VStack(spacing: 20) {
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "flag")
    ///             Image(systemName: "heart")
    ///             Image(systemName: "bolt")
    ///             Image(systemName: "star")
    ///         }
    ///         .symbolVariant(.slash)
    ///     }
    ///
    /// ![A screenshot showing two rows of four symbols each. Both rows contain
    /// a flag, a heart, a bolt, and a star. A slash is superimposed over
    /// all the symbols in the second row.](SymbolVariants-slash-1)
    public static let slash: SymbolVariants = .init(flags: [.slash], shape: nil)

    /// A slashed version of the variant.
    ///
    /// Use this property to modify a shape variant like
    /// ``circle-swift.type.property`` so that it's also covered by a slash:
    ///
    ///     Label("Circle Slash", systemImage: "flag")
    ///         .symbolVariant(.circle.slash)
    ///
    /// ![A screenshot of a label that shows a flag in a circle with a
    /// slash over it beside the words Circle Slash.](SymbolVariants-slash-2)
    public var slash: SymbolVariants {
        SymbolVariants(flags: flags.union(.slash), shape: shape)
    }

    package mutating func formUnion(_ other: SymbolVariants) {
        flags = flags.union(other.flags)
        shape = other.shape ?? shape
    }

    /// Returns a Boolean value that indicates whether the current variant
    /// contains the specified variant.
    ///
    /// - Parameter other: A variant to look for in this variant.
    /// - Returns: `true` if this variant contains `other`; otherwise,
    ///   `false`.
    public func contains(_ other: SymbolVariants) -> Bool {
        flags.contains(other.flags) && (shape == other.shape || other.shape == nil)
    }

    package func shapeVariantName(name: String) -> String? {
        guard let shape else { return nil }
        return name + shape.suffix
    }
}

extension SymbolVariants.Shape {
    package func path(in rect: CGRect, cornerRadius: Float?) -> Path {
        switch self {
        case .circle:
            return Path(ellipseIn: rect)
        case .square, .rectangle:
            let radius: Double
            if let cornerRadius {
                radius = Double(cornerRadius).clamp(min: 0, max: 0.5)
            } else {
                radius = 0.225
            }
            return Path(
                roundedRect: rect,
                cornerRadius: radius * min(rect.width, rect.height)
            )
        }
    }
}

// MARK: - SymbolVariants + EnvironmentValues

@available(OpenSwiftUI_v3_0, *)
extension View {

    /// Makes symbols within the view show a particular variant.
    ///
    /// When you want all the
    /// [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
    /// in a part of your app's user interface to use the same variant, use the
    /// `symbolVariant(_:)` modifier with a ``SymbolVariants`` value, like
    /// ``SymbolVariants/fill-swift.type.property``:
    ///
    ///     VStack(spacing: 20) {
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "person")
    ///             Image(systemName: "folder")
    ///             Image(systemName: "gearshape")
    ///             Image(systemName: "list.bullet")
    ///         }
    ///
    ///         HStack(spacing: 20) {
    ///             Image(systemName: "person")
    ///             Image(systemName: "folder")
    ///             Image(systemName: "gearshape")
    ///             Image(systemName: "list.bullet")
    ///         }
    ///         .symbolVariant(.fill) // Shows filled variants, when available.
    ///     }
    ///
    /// A symbol that doesn't have the specified variant remains unaffected.
    /// In the example above, the `list.bullet` symbol doesn't have a filled
    /// variant, so the `symbolVariant(_:)` modifer has no effect.
    ///
    /// ![A screenshot showing two rows of four symbols. Both rows contain a
    /// person, a folder, a gear, and a bullet list. The symbols in the first
    /// row are outlined. The symbols in the second row are filled, except the
    /// list, which is the same in both rows.](View-symbolVariant-1)
    ///
    /// If you apply the modifier more than once, its effects accumulate.
    /// Alternatively, you can apply multiple variants in one call:
    ///
    ///     Label("Airplane", systemImage: "airplane.circle.fill")
    ///
    ///     Label("Airplane", systemImage: "airplane")
    ///         .symbolVariant(.circle)
    ///         .symbolVariant(.fill)
    ///
    ///     Label("Airplane", systemImage: "airplane")
    ///         .symbolVariant(.circle.fill)
    ///
    /// All of the labels in the code above produce the same output:
    ///
    /// ![A screenshot of a label that shows an airplane in a filled circle
    /// beside the word Airplane.](View-symbolVariant-2)
    ///
    /// You can apply all these variants in any order, but
    /// if you apply more than one shape variant, the one closest to the
    /// symbol takes precedence. For example, the following image uses the
    /// ``SymbolVariants/square-swift.type.property`` shape:
    ///
    ///     Image(systemName: "arrow.left")
    ///         .symbolVariant(.square) // This shape takes precedence.
    ///         .symbolVariant(.circle)
    ///         .symbolVariant(.fill)
    ///
    /// ![A screenshot of a left arrow symbol in a filled
    /// square.](View-symbolVariant-3)
    ///
    /// To cause a symbol to ignore the variants currently in the environment,
    /// directly set the ``EnvironmentValues/symbolVariants`` environment value
    /// to ``SymbolVariants/none`` using the ``View/environment(_:_:)`` modifer.
    ///
    /// - Parameter variant: The variant to use for symbols. Use the values in
    ///   ``SymbolVariants``.
    /// - Returns: A view that applies the specified symbol variant or variants
    ///   to itself and its child views.
    nonisolated public func symbolVariant(_ variant: SymbolVariants) -> some View {
        transformEnvironment(\.symbolVariants) {
            $0.formUnion(variant)
        }
    }
}

private struct SymbolVariantsKey: EnvironmentKey {
    static var defaultValue: SymbolVariants { .none }
}

private struct SymbolBackgroundCornerRadiusKey: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

private struct SymbolsGrowToFitBackgroundKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    public var symbolVariants: SymbolVariants {
        get { self[SymbolVariantsKey.self] }
        set { self[SymbolVariantsKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public var symbolBackgroundCornerRadius: CGFloat? {
        get { self[SymbolBackgroundCornerRadiusKey.self] }
        set { self[SymbolBackgroundCornerRadiusKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public var symbolsGrowToFitBackground: Bool {
        get { self[SymbolsGrowToFitBackgroundKey.self] }
        set { self[SymbolsGrowToFitBackgroundKey.self] = newValue }
    }
}
