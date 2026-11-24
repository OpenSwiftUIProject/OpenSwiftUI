//
//  AppearanceWidgetAssetCache.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9DFC34E25264BAA930CEB50D58794D4B (SwiftUICore)

#if os(macOS) && OPENSWIFTUI_LINK_COREUI

// MARK: - AppearanceWidgetAssetCache

private var caches: [String: AppearanceWidgetAssetCache] = [:]

final class AppearanceWidgetAssetCache {
    private var artworkCache: [AnyAppearanceWidget: Image] = [:]
    private var metricCache: [AnyAppearanceWidget: [String: Any]] = [:]

    private init() {}

    static func named(_ name: String) -> AppearanceWidgetAssetCache {
        if let cache = caches[name] {
            return cache
        }
        let cache = AppearanceWidgetAssetCache()
        caches[name] = cache
        return cache
    }

    func cachedArtwork<Widget>(for widget: Widget) -> Image? where Widget: AppearanceWidgetDefinition {
        let key = AnyAppearanceWidget(widget)
        return artworkCache.first { $0.key == key }?.value
    }

    func cacheArtwork<Widget>(_ image: Image, with widget: Widget) where Widget: AppearanceWidgetDefinition {
        artworkCache[AnyAppearanceWidget(widget)] = image
    }

    func cachedMetric<Widget, MetricValue>(
        _ metric: AppearanceMetricName<MetricValue>,
        for widget: Widget
    ) -> MetricValue? where Widget: AppearanceWidgetDefinition {
        metricCache[AnyAppearanceWidget(widget)]?[metric.rawValue] as? MetricValue
    }

    func cacheMetric<Widget, MetricValue>(
        _ value: MetricValue,
        for metric: AppearanceMetricName<MetricValue>,
        with widget: Widget
    ) where Widget: AppearanceWidgetDefinition {
        let key = AnyAppearanceWidget(widget)
        var metrics = metricCache[key] ?? [:]
        metrics[metric.rawValue] = value as Any
        metricCache[key] = metrics
    }
}

// MARK: - _AppearanceWidgetBox

private class _AppearanceWidgetBox: Hashable {
    func isEqual(to other: _AppearanceWidgetBox) -> Bool {
        _openSwiftUIUnreachableCode()
    }

    static func == (lhs: _AppearanceWidgetBox, rhs: _AppearanceWidgetBox) -> Bool {
        lhs.isEqual(to: rhs)
    }

    func hash(into hasher: inout Hasher) {
        _openSwiftUIUnreachableCode()
    }
}

private class _AppearanceWidgetBoxImpl<Widget>: _AppearanceWidgetBox where Widget: AppearanceWidgetDefinition {
    var storage: Widget

    init(_ widget: Widget) {
        storage = widget
    }

    override func isEqual(to other: _AppearanceWidgetBox) -> Bool {
        guard let other = other as? _AppearanceWidgetBoxImpl<Widget> else { return false }
        return storage == other.storage
    }

    override func hash(into hasher: inout Hasher) {
        storage.hash(into: &hasher)
    }
}

// MARK: - AnyAppearanceWidget

struct AnyAppearanceWidget: AppearanceWidgetDefinition {
    private let storage: _AppearanceWidgetBox

    init<Widget>(_ widget: Widget) where Widget: AppearanceWidgetDefinition {
        storage = _AppearanceWidgetBoxImpl(widget)
    }
}
#endif
