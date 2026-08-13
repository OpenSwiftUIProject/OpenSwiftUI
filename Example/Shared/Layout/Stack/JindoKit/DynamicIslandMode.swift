//
//  DynamicIslandMode.swift
//  JindoKit

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

/// A structure that offers values that describe a Dynamic Island content mode.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
public struct DynamicIslandMode: Equatable, Sendable {
    enum Storage: Equatable, Sendable {
        case expanded
        case compactLeading
        case compactTrailing
        case minimal
    }

    let storage: Storage

    private init(_ storage: Storage) {
        self.storage = storage
    }

    /// The expanded presentation of a Live Activity in the Dynamic Island.
    public static let expanded = DynamicIslandMode(.expanded)

    /// The compact leading presentation of a Live Activity.
    public static let compactLeading = DynamicIslandMode(.compactLeading)

    /// The compact trailing presentation of a Live Activity.
    public static let compactTrailing = DynamicIslandMode(.compactTrailing)

    /// The minimal presentation of a Live Activity in the Dynamic Island.
    public static let minimal = DynamicIslandMode(.minimal)
}
/// A structure that selects the Dynamic Island presentation rendered by a
/// JindoKit preview.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
public struct DynamicIslandPreviewMode: Equatable, Sendable {
    enum Storage: Equatable, Sendable {
        case expanded
        case compact
        case minimal
    }

    let storage: Storage

    private init(_ storage: Storage) {
        self.storage = storage
    }

    /// The expanded presentation.
    public static let expanded = DynamicIslandPreviewMode(.expanded)

    /// The combined compact leading and compact trailing presentation.
    public static let compact = DynamicIslandPreviewMode(.compact)

    /// The minimal presentation.
    public static let minimal = DynamicIslandPreviewMode(.minimal)
}

/// The geometry used to render a Dynamic Island preview.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
public struct DynamicIslandPreviewConfiguration: Equatable, Sendable {
    /// The size of the obstruction in the expanded presentation.
    public var notchSize: CGSize

    /// The size of the obstruction separating compact content.
    public var compactObstructionSize: CGSize

    /// The size of the expanded preview canvas.
    public var expandedSize: CGSize

    /// The size of the compact preview canvas.
    public var compactSize: CGSize

    /// The size of the minimal preview canvas.
    public var minimalSize: CGSize

    /// The corner radius of the expanded presentation.
    public var expandedCornerRadius: CGFloat

    /// Creates a Dynamic Island preview configuration.
    ///
    /// - Parameters:
    ///   - notchSize: The expanded obstruction size.
    ///   - compactObstructionSize: The compact obstruction size.
    ///   - expandedSize: The expanded preview size.
    ///   - compactSize: The compact preview size.
    ///   - minimalSize: The minimal preview size.
    ///   - expandedCornerRadius: The expanded presentation's corner radius.
    public init(
        notchSize: CGSize = CGSize(width: 126, height: 37),
        compactObstructionSize: CGSize = CGSize(width: 119.33, height: 37),
        expandedSize: CGSize = CGSize(width: 371, height: 160),
        compactSize: CGSize = CGSize(width: 230, height: 37),
        minimalSize: CGSize = CGSize(width: 45, height: 37),
        expandedCornerRadius: CGFloat = 44
    ) {
        self.notchSize = notchSize
        self.compactObstructionSize = compactObstructionSize
        self.expandedSize = expandedSize
        self.compactSize = compactSize
        self.minimalSize = minimalSize
        self.expandedCornerRadius = expandedCornerRadius
    }

    /// The default preview geometry.
    public static let `default` = DynamicIslandPreviewConfiguration()
}

struct DynamicIslandContentMargins: Equatable {
    var top: CGFloat
    var leading: CGFloat
    var bottom: CGFloat
    var trailing: CGFloat
    private var explicitEdges: Edge.Set = []

    init(_ value: CGFloat) {
        top = value
        leading = value
        bottom = value
        trailing = value
    }

    var edgeInsets: EdgeInsets {
        EdgeInsets(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }

    mutating func set(_ edges: Edge.Set, to value: CGFloat) {
        if edges.contains(.top), !explicitEdges.contains(.top) {
            top = value
        }
        if edges.contains(.leading), !explicitEdges.contains(.leading) {
            leading = value
        }
        if edges.contains(.bottom), !explicitEdges.contains(.bottom) {
            bottom = value
        }
        if edges.contains(.trailing), !explicitEdges.contains(.trailing) {
            trailing = value
        }
        explicitEdges.formUnion(edges)
    }
}
