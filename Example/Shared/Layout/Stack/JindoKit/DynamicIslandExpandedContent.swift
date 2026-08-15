//
//  DynamicIslandExpandedContent.swift
//  JindoKit

#if !os(macOS)

#if OPENSWIFTUI
@_spi(Jindo) import OpenSwiftUI
#else
@_spi(Jindo) import SwiftUI_SPI
#endif

/// A view that describes the expanded presentation of a Live Activity in the
/// Dynamic Island.
///
/// This view holds the intermediate content for
/// ``DynamicIslandExpandedContentBuilder``.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
@MainActor
public struct DynamicIslandExpandedContent<Content> where Content: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

/// A result builder that constructs the content of an expanded Live Activity
/// in the Dynamic Island.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
@resultBuilder
@MainActor
public struct DynamicIslandExpandedContentBuilder {
    /// Builds expanded content from its first region.
    public static func buildPartialBlock<C>(
        first: DynamicIslandExpandedRegion<C>
    ) -> DynamicIslandExpandedContent<some View> where C: View {
        DynamicIslandExpandedContent {
            first._viewRepresentation
        }
    }

    /// Passes through an existing expanded-content value.
    public static func buildPartialBlock<C>(
        first: DynamicIslandExpandedContent<C>
    ) -> DynamicIslandExpandedContent<some View> where C: View {
        first
    }

    /// Appends a region to accumulated expanded content.
    public static func buildPartialBlock<C0, C1>(
        accumulated: DynamicIslandExpandedContent<C0>,
        next: DynamicIslandExpandedRegion<C1>
    ) -> DynamicIslandExpandedContent<some View> where C0: View, C1: View {
        DynamicIslandExpandedContent {
            accumulated.content
            next._viewRepresentation
        }
    }

    /// Combines two expanded-content values.
    public static func buildPartialBlock<C0, C1>(
        accumulated: DynamicIslandExpandedContent<C0>,
        next: DynamicIslandExpandedContent<C1>
    ) -> DynamicIslandExpandedContent<some View> where C0: View, C1: View {
        DynamicIslandExpandedContent {
            accumulated.content
            next.content
        }
    }
}

/// View positions of an expanded Live Activity in the Dynamic Island.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
public struct DynamicIslandExpandedRegionPosition: Sendable {
    enum Storage: Sendable {
        case leading
        case trailing
        case center
        case bottom
    }

    let storage: Storage

    private init(_ storage: Storage) {
        self.storage = storage
    }

    /// The leading position next to the island obstruction.
    public static let leading = DynamicIslandExpandedRegionPosition(.leading)

    /// The trailing position next to the island obstruction.
    public static let trailing = DynamicIslandExpandedRegionPosition(.trailing)

    /// The center position below the island obstruction.
    public static let center = DynamicIslandExpandedRegionPosition(.center)

    /// The bottom position below the leading, trailing, and center content.
    public static let bottom = DynamicIslandExpandedRegionPosition(.bottom)
}

/// A structure that defines and positions the content of an expanded Live
/// Activity in the Dynamic Island.
///
/// The expanded presentation consists of four regions:
///
/// - ``DynamicIslandExpandedRegionPosition/center`` places content below the
///   island obstruction.
/// - ``DynamicIslandExpandedRegionPosition/leading`` places content along the
///   leading edge and wraps additional content below it.
/// - ``DynamicIslandExpandedRegionPosition/trailing`` places content along the
///   trailing edge and wraps additional content below it.
/// - ``DynamicIslandExpandedRegionPosition/bottom`` places content below the
///   other regions.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
@MainActor
public struct DynamicIslandExpandedRegion<Content> where Content: View {
    private let position: DynamicIslandExpandedRegionPosition
    private let priority: Double
    private let content: Content
    private var margins = JindoRegionContentMargins()

    /// Creates and positions content in the expanded Dynamic Island.
    ///
    /// - Parameters:
    ///   - position: The position for the expanded content.
    ///   - priority: The priority used when sizing competing regions.
    ///   - content: The content of the expanded region.
    public init(
        _ position: DynamicIslandExpandedRegionPosition,
        priority: Double = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.position = position
        self.priority = priority
        self.content = content()
    }

    /// The view representation consumed by the expanded-content builder.
    public var _viewRepresentation: some View {
        content
            .jindoPosition(position.jindoPosition)
            .jindoPriority(priority)
            .jindoContentMargins(margins.value)
    }

    /// Overrides the default content margins for the specified edges.
    ///
    /// - Parameters:
    ///   - edges: The edges that use custom content margins.
    ///   - length: The custom margin for the specified edges.
    /// - Returns: An expanded region with updated content margins.
    public func contentMargins(
        _ edges: Edge.Set = .all,
        _ length: Double
    ) -> DynamicIslandExpandedRegion<Content> {
        var copy = self
        let value = CGFloat(length)
        if edges.contains(.top) {
            copy.margins.top = value
        }
        if edges.contains(.leading) {
            copy.margins.leading = value
        }
        if edges.contains(.bottom) {
            copy.margins.bottom = value
        }
        if edges.contains(.trailing) {
            copy.margins.trailing = value
        }
        return copy
    }
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private extension DynamicIslandExpandedRegionPosition {
    var jindoPosition: JindoTripleVStack.Position {
        switch storage {
        case .leading:
            .leading
        case .trailing:
            .trailing
        case .center:
            .center
        case .bottom:
            .bottom
        }
    }
}

/// Vertical positions for expanded Live Activity content in the Dynamic
/// Island.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
public struct DynamicIslandExpandedRegionVerticalPlacement: Equatable, Sendable {
    enum Storage: Equatable, Sendable {
        case `default`
        case belowIfTooWide
    }

    let storage: Storage

    private init(_ storage: Storage) {
        self.storage = storage
    }

    /// The system's default vertical placement.
    public static let `default` =
        DynamicIslandExpandedRegionVerticalPlacement(.default)

    /// A placement below the default position when content is too wide to fit
    /// next to the island obstruction.
    public static let belowIfTooWide =
        DynamicIslandExpandedRegionVerticalPlacement(.belowIfTooWide)
}

/// Adds Dynamic Island-specific layout behavior to a view.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
@MainActor
public extension View {
    /// Specifies the vertical placement for expanded Dynamic Island content.
    ///
    /// - Parameter verticalPlacement: The vertical placement for the view.
    /// - Returns: A view with the specified vertical placement.
    func dynamicIsland(
        verticalPlacement: DynamicIslandExpandedRegionVerticalPlacement
    ) -> some View {
        jindoVerticalPlacement(verticalPlacement.jindoPlacement)
    }
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private extension DynamicIslandExpandedRegionVerticalPlacement {
    var jindoPlacement: JindoTripleVStack.VerticalPlacement {
        switch storage {
        case .default:
            .default
        case .belowIfTooWide:
            .belowNotchIfTooWide
        }
    }
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private struct JindoRegionContentMargins: Sendable {
    var top: CGFloat?
    var leading: CGFloat?
    var bottom: CGFloat?
    var trailing: CGFloat?

    var value: JindoTripleVStack.ContentMargins? {
        guard top != nil || leading != nil || bottom != nil || trailing != nil else {
            return nil
        }
        return JindoTripleVStack.ContentMargins(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }
}

#endif
