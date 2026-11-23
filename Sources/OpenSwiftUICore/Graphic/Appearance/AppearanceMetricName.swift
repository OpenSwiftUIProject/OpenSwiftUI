//
//  AppearanceMetricName.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS) && OPENSWIFTUI_LINK_COREUI
import CoreUI
import Foundation

// MARK: - AppearanceMetricName

package struct AppearanceMetricName<MetricValue>: RawRepresentable, Equatable, Hashable {
    private var _rawValue: String

    package init(rawValue: String) {
        _rawValue = rawValue
    }

    package var rawValue: String { _rawValue }

    package var hashValue: Int { _rawValue.hashValue }
}

package let layoutTraitsMetricName = AppearanceMetricName<_LayoutTraits>(rawValue: "size")
package let contentInsetsMetricName = AppearanceMetricName<EdgeInsets>(rawValue: "contentInsets")
package let insetMetricName = AppearanceMetricName<EdgeInsets>(rawValue: "inset")
package let baselineMetricName = AppearanceMetricName<Double>(rawValue: "baseline")
package let blendModeMetricName = AppearanceMetricName<BlendMode>(rawValue: "blendMode")

// MARK: - CoreUI measurements

extension AppearanceMetricName {
    var coreUIKeys: [String]? {
        switch rawValue {
        case layoutTraitsMetricName.rawValue:
            [kCUIMeasureWidth as String, kCUIMeasureHeight as String]
        case contentInsetsMetricName.rawValue:
            [kCUIMeasureContentInsetTopRight as String, kCUIMeasureContentInsetBottomLeft as String]
        case insetMetricName.rawValue:
            [kCUIMeasureEdgeInsetTopRight as String, kCUIMeasureEdgeInsetBottomLeft as String]
        case baselineMetricName.rawValue:
            [kCUIMeasureBaseline as String]
        case blendModeMetricName.rawValue:
            [kCUIMeasureBlendMode as String]
        default:
            nil
        }
    }

    func valueIn(coreUIMetricsDictionary measurements: [String: NSValue]) -> MetricValue? {
        func insets(topRight topRightKey: CFString, bottomLeft bottomLeftKey: CFString) -> EdgeInsets {
            let topRight = measurements[topRightKey as String]?.sizeValue ?? .zero
            let bottomLeft = measurements[bottomLeftKey as String]?.sizeValue ?? .zero
            return EdgeInsets(
                top: topRight.height,
                leading: bottomLeft.width,
                bottom: bottomLeft.height,
                trailing: topRight.width
            )
        }

        switch rawValue {
        case layoutTraitsMetricName.rawValue:
            guard let width = (measurements[kCUIMeasureWidth as String] as? NSNumber)?.doubleValue,
                  let height = (measurements[kCUIMeasureHeight as String] as? NSNumber)?.doubleValue else { return nil }
            return _LayoutTraits(
                width: .fixed(CGFloat(width)),
                height: .fixed(CGFloat(height))
            ) as? MetricValue
        case contentInsetsMetricName.rawValue:
            return insets(
                topRight: kCUIMeasureContentInsetTopRight,
                bottomLeft: kCUIMeasureContentInsetBottomLeft
            ) as? MetricValue
        case insetMetricName.rawValue:
            return insets(
                topRight: kCUIMeasureEdgeInsetTopRight,
                bottomLeft: kCUIMeasureEdgeInsetBottomLeft
            ) as? MetricValue
        case baselineMetricName.rawValue:
            guard let value = measurements[kCUIMeasureBaseline as String] as? NSNumber else { return nil }
            // The catalog casts a CGFloat even for the Double-typed baseline metric.
            return .some(CGFloat(value.doubleValue) as! MetricValue)
        case blendModeMetricName.rawValue:
            guard let value = measurements[kCUIMeasureBlendMode as String] as? NSNumber,
                  let mode = CGBlendMode(rawValue: Int32(value.uintValue)) else { return nil }
            return .some(BlendMode(mode) as! MetricValue)
        default:
            return nil
        }
    }
}

// MARK: - AppearanceWidgetMetricKey

package struct AppearanceWidgetMetricKey<Widget, MetricValue>: AppearanceAssetKey where Widget: AppearanceWidgetDefinition {
    package typealias AssetType = MetricValue

    package let metric: AppearanceMetricName<MetricValue>
    package let widget: Widget

    package init(metric: AppearanceMetricName<MetricValue>, for widget: Widget) {
        self.metric = metric
        self.widget = widget
    }
}

extension EnvironmentValues {
    package static func metric<Widget, MetricValue, V>(
        _ key: AppearanceWidgetMetricKey<Widget, MetricValue>,
        _ content: @escaping (MetricValue?) -> V
    ) -> FunctionalAppearanceAssetView<AppearanceWidgetMetricKey<Widget, MetricValue>, V> where Widget: AppearanceWidgetDefinition, V: View {
        asset(for: key, content)
    }
}

protocol AnyAppearanceWidgetMetricKey {
    func metric(in provider: any AppearanceWidgetMetricProviding) -> Any?
    func hasDefinition(in provider: any AppearanceWidgetMetricProviding) -> Bool
}

protocol AppearanceWidgetMetricProviding {
    func metric<Widget, MetricValue>(for key: AppearanceWidgetMetricKey<Widget, MetricValue>) -> MetricValue?
    func containsDefinition<Widget, MetricValue>(for key: AppearanceWidgetMetricKey<Widget, MetricValue>) -> Bool
}

extension AppearanceWidgetMetricKey: AnyAppearanceWidgetMetricKey {
    func metric(in provider: any AppearanceWidgetMetricProviding) -> Any? {
        provider.metric(for: self)
    }

    func hasDefinition(in provider: any AppearanceWidgetMetricProviding) -> Bool {
        provider.containsDefinition(for: self)
    }
}

#endif
