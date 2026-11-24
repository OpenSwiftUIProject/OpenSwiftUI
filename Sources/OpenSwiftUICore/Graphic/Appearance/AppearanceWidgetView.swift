//
//  AppearanceWidgetView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS) && OPENSWIFTUI_LINK_COREUI

// MARK: - AppearanceWidgetView

package struct AppearanceWidgetView<W>: AppearanceAssetReadingView, Equatable where W: AppearanceWidgetDefinition {
    let widget: W

    package init(_ widget: W) {
        self.widget = widget
    }

    package func body(values: AppearanceAssetValues) -> some View {
        let blendMode = values.asset(for: AppearanceWidgetMetricKey(metric: blendModeMetricName, for: widget)) ?? .normal
        let insets = values.asset(for: AppearanceWidgetMetricKey(metric: insetMetricName, for: widget)) ?? .zero
        let image = values.asset(for: AppearanceWidgetArtworkKey(widget))
        let traits = values.asset(for: AppearanceWidgetMetricKey(metric: layoutTraitsMetricName, for: widget)) ?? _LayoutTraits()
        return image
            .frame(
                minWidth: traits.width.min, idealWidth: traits.width.ideal, maxWidth: traits.width.max,
                minHeight: traits.height.min, idealHeight: traits.height.ideal, maxHeight: traits.height.max
            )
            .padding(insets.negatedInsets)
            .blendMode(blendMode)
    }
}

#endif
