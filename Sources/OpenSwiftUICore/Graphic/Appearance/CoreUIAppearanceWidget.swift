//
//  CoreUIAppearanceWidget.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS) && OPENSWIFTUI_LINK_COREUI
import CoreUI
import Foundation

// MARK: - CoreUIWidgetRendererType

package enum CoreUIWidgetRendererType {
    case layer
    case drawing(DrawingOptions.Provider)

    package struct DrawingOptions {
        package let boundsSize: CGSize
        package let capInsets: EdgeInsets
        package let displayScale: CGFloat
        package let cropInsets: EdgeInsets

        package init(
            boundsSize: CGSize,
            displayScale: CGFloat,
            capInsets: EdgeInsets = EdgeInsets(),
            cropInsets: EdgeInsets = EdgeInsets()
        ) {
            self.boundsSize = boundsSize
            self.capInsets = capInsets
            self.displayScale = displayScale
            self.cropInsets = cropInsets
        }

        package struct Provider {
            private let optionsProvider: (_LayoutTraits) -> DrawingOptions

            package init(_ optionsProvider: @escaping (_LayoutTraits) -> DrawingOptions) {
                self.optionsProvider = optionsProvider
            }

            package func options(for layoutTraits: _LayoutTraits) -> DrawingOptions {
                optionsProvider(layoutTraits)
            }

            package static func with(
                capInsets: EdgeInsets = EdgeInsets(),
                displayScale: CGFloat,
                cropInsets: EdgeInsets = EdgeInsets()
            ) -> Provider {
                Provider { traits in
                    DrawingOptions(
                        boundsSize: traits.idealSize,
                        displayScale: displayScale,
                        capInsets: capInsets,
                        cropInsets: cropInsets
                    )
                }
            }
        }
    }
}

// MARK: - CoreUIAppearanceWidget

package protocol CoreUIAppearanceWidget {
    var coreUIOptions: [String: Any] { get }

    var coreUIRenderer: CoreUIWidgetRendererType { get }

    func coreUIAdjustMetric<MetricValue>(
        key: AppearanceMetricName<MetricValue>,
        value: MetricValue?,
        for appearance: CatalogAppearance
    ) -> MetricValue?
}

extension CoreUIAppearanceWidget {
    package func coreUILegacyState(pressed: Bool, enabled: Bool, appearsActive: Bool) -> CFString {
        if pressed {
            return kCUIStatePressed
        } else {
            return appearsActive ? kCUIStateActive : kCUIStateInactive
        }
    }
}

extension CoreUIAppearanceWidget {
    package var coreUIWidgetKey: String {
        coreUIOptions[kCUIWidgetKey as String]! as! String
    }

    package func coreUIAdjustMetric<MetricValue>(
        key: AppearanceMetricName<MetricValue>,
        value: MetricValue?,
        for appearance: CatalogAppearance
    ) -> MetricValue? {
        value
    }
}
#endif
