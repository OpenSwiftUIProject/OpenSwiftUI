#if OPENSWIFTUI
@_spi(Jindo) import OpenSwiftUI
#else
import SwiftUI
import SwiftUI_SPI
#endif

/// A view that previews the layout and configuration of a Live Activity in the
/// Dynamic Island.
#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
@MainActor
public struct DynamicIsland: View {
    private let expanded: () -> AnyView
    private let compactLeading: () -> AnyView
    private let compactTrailing: () -> AnyView
    private let minimal: () -> AnyView

    private var mode = DynamicIslandPreviewMode.expanded
    private var configuration = DynamicIslandPreviewConfiguration.default
    private var expandedMargins = DynamicIslandContentMargins(12)
    private var compactLeadingMargins = DynamicIslandContentMargins(8)
    private var compactTrailingMargins = DynamicIslandContentMargins(8)
    private var minimalMargins = DynamicIslandContentMargins(4)

    /// Creates a preview with views for each Dynamic Island presentation.
    ///
    /// - Parameters:
    ///   - expanded: A closure that builds the expanded presentation.
    ///   - compactLeading: A closure that builds the compact leading
    ///     presentation.
    ///   - compactTrailing: A closure that builds the compact trailing
    ///     presentation.
    ///   - minimal: A closure that builds the minimal presentation.
    public init<Expanded, CompactLeading, CompactTrailing, Minimal>(
        @DynamicIslandExpandedContentBuilder expanded: @escaping () ->
            DynamicIslandExpandedContent<Expanded>,
        @ViewBuilder compactLeading: @escaping () -> CompactLeading,
        @ViewBuilder compactTrailing: @escaping () -> CompactTrailing,
        @ViewBuilder minimal: @escaping () -> Minimal
    ) where
        Expanded: View,
        CompactLeading: View,
        CompactTrailing: View,
        Minimal: View
    {
        self.expanded = {
            let expandedContent = expanded()
            return AnyView(
                JindoExpandedLayout {
                    expandedContent.content
                }
            )
        }
        self.compactLeading = {
            AnyView(compactLeading())
        }
        self.compactTrailing = {
            AnyView(compactTrailing())
        }
        self.minimal = {
            AnyView(minimal())
        }
    }

    /// The content and behavior of the Dynamic Island preview.
    public var body: some View {
        Group {
            switch mode.storage {
            case .expanded:
                expandedPreview
            case .compact:
                compactPreview
            case .minimal:
                minimalPreview
            }
        }
        .foregroundStyle(.white)
        .tint(.white)
    }

    /// Overrides the default content margins for a Dynamic Island mode.
    ///
    /// Use this modifier to customize the content margins for a presentation.
    /// Avoid placing content too close to the edges of the Dynamic Island.
    ///
    /// When you apply multiple modifiers, the first value specified for an edge
    /// takes precedence. For example, this keeps an 8-point trailing margin and
    /// uses 20 points for all other edges:
    ///
    /// ```swift
    /// dynamicIsland
    ///     .contentMargins(.trailing, 8, for: .expanded)
    ///     .contentMargins(.all, 20, for: .expanded)
    /// ```
    ///
    /// - Parameters:
    ///   - edges: The edges that use custom content margins.
    ///   - length: The custom margin for the specified edges.
    ///   - mode: The presentation that receives the custom margins.
    /// - Returns: A Dynamic Island preview with updated content margins.
    public func contentMargins(
        _ edges: Edge.Set = .all,
        _ length: Double,
        for mode: DynamicIslandMode
    ) -> DynamicIsland {
        var copy = self
        let value = CGFloat(length)
        switch mode.storage {
        case .expanded:
            copy.expandedMargins.set(edges, to: value)
        case .compactLeading:
            copy.compactLeadingMargins.set(edges, to: value)
        case .compactTrailing:
            copy.compactTrailingMargins.set(edges, to: value)
        case .minimal:
            copy.minimalMargins.set(edges, to: value)
        }
        return copy
    }

    /// Selects the presentation that this view renders.
    ///
    /// - Parameter mode: The expanded, compact, or minimal preview mode.
    /// - Returns: A Dynamic Island configured to render the selected mode.
    public func previewMode(_ mode: DynamicIslandPreviewMode) -> DynamicIsland {
        var copy = self
        copy.mode = mode
        return copy
    }

    /// Configures the geometry used to render the Dynamic Island preview.
    ///
    /// - Parameter configuration: The island and presentation geometry.
    /// - Returns: A Dynamic Island that uses the specified preview geometry.
    public func previewConfiguration(
        _ configuration: DynamicIslandPreviewConfiguration
    ) -> DynamicIsland {
        var copy = self
        copy.configuration = configuration
        return copy
    }

    private var expandedPreview: some View {
        expanded()
            ._jindoPreviewLayoutConfiguration(
                JindoPreviewLayoutConfiguration(
                    notchSize: configuration.notchSize,
                    layoutMargins: expandedMargins.edgeInsets
                )
            )
            .frame(
                width: configuration.expandedSize.width,
                alignment: .top
            )
            .frame(
                minHeight: min(84, configuration.expandedSize.height),
                maxHeight: configuration.expandedSize.height,
                alignment: .top
            )
            .fixedSize(horizontal: false, vertical: true)
            .background {
                RoundedRectangle(
                    cornerRadius: configuration.expandedCornerRadius,
                    style: .continuous
                )
                .fill(.black)
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: configuration.expandedCornerRadius,
                    style: .continuous
                )
            )
    }

    private var compactPreview: some View {
        HStack(spacing: 0) {
            compactLeading()
                .padding(compactLeadingMargins.edgeInsets)

            Color.clear
                .frame(
                    width: configuration.compactObstructionSize.width,
                    height: configuration.compactObstructionSize.height
                )

            compactTrailing()
                .padding(compactTrailingMargins.edgeInsets)
        }
        .frame(maxWidth: configuration.compactSize.width)
        .fixedSize(horizontal: true, vertical: false)
        .frame(height: configuration.compactSize.height)
        .background {
            Capsule(style: .continuous)
                .fill(.black)
        }
        .clipShape(Capsule(style: .continuous))
    }

    private var minimalPreview: some View {
        minimal()
            .padding(minimalMargins.edgeInsets)
            .frame(
                minWidth: min(
                    configuration.minimalSize.width,
                    configuration.minimalSize.height
                ),
                maxWidth: configuration.minimalSize.width
            )
            .fixedSize(horizontal: true, vertical: false)
            .frame(
                height: configuration.minimalSize.height
            )
            .background {
                Capsule(style: .continuous)
                    .fill(.black)
            }
            .clipShape(Capsule(style: .continuous))
    }
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private struct JindoPreviewLayoutConfiguration: Sendable {
    var notchSize: CGSize
    var layoutMargins: EdgeInsets
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private struct JindoPreviewLayoutConfigurationKey: EnvironmentKey {
    static let defaultValue = JindoPreviewLayoutConfiguration(
        notchSize: CGSize(width: 126, height: 37),
        layoutMargins: EdgeInsets()
    )
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private extension EnvironmentValues {
    var jindoPreviewLayoutConfiguration: JindoPreviewLayoutConfiguration {
        get { self[JindoPreviewLayoutConfigurationKey.self] }
        set { self[JindoPreviewLayoutConfigurationKey.self] = newValue }
    }
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private extension View {
    func _jindoPreviewLayoutConfiguration(
        _ configuration: JindoPreviewLayoutConfiguration
    ) -> some View {
        environment(\.jindoPreviewLayoutConfiguration, configuration)
    }
}

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
private struct JindoExpandedLayout<Content>: View where Content: View {
    @Environment(\.jindoPreviewLayoutConfiguration)
    private var configuration

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        JindoTripleVStack(
            configuration: .init(
                notchSize: configuration.notchSize,
                horizontalSizing: .split,
                layoutMargins: EdgeInsets()
            )
        ) {
            content
        }
        .padding(configuration.layoutMargins)
    }
}
