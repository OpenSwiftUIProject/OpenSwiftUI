//
//  MacIdiomGroupBoxStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9FE0D7630001934EE287FFEB520F6F19 (SwiftUI)

#if os(macOS)
#if OPENSWIFTUI_LINK_COREUI
import CoreUI
#endif
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - Const Value

private let approximateCornerRadius: CGFloat = 5.0
private let horizontalLabelInset: CGFloat = 10.0
private let verticalLabelInset: CGFloat = 3.0
private let contentToBackgroundInset: CGFloat = 5.0

// MARK: - MacIdiomGroupBoxStyle

struct MacIdiomGroupBoxStyle: GroupBoxStyle {
    @Environment(\.disableGroupBoxPadding)
    private var disablePadding

    @Environment(\.disableGroupBoxBackground)
    private var disableBackground

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: verticalLabelInset) {
            configuration.label
                .font(.subheadline)
                .padding(.leading, horizontalLabelInset)
            StaticIf(in: GroupedFormStyleContext()) {
                makeContent(configuration.content, borderWidth: 0)
            } else: {
                makeContent(configuration.content, borderWidth: 1)
            }
        }
        .spacing(Spacing())
    }

    private func makeContent<Content: View>(_ content: Content, borderWidth: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: approximateCornerRadius, style: .continuous)
        return VStack { content }
            .styleContext(.container, in: NoStyleContext())
            .styleContext(.container, in: WindowRootContext())
            .padding(disablePadding ? 0 : contentToBackgroundInset - borderWidth)
            .clipShape(ContainerRelativeShape())
            .padding(borderWidth)
            .containerShape(shape)
            .environment(\.groupBoxCornerRadius, approximateCornerRadius)
            .background {
                if !disableBackground {
                    GroupBoxBackground()
                }
            }
            .overlay {
                if !disableBackground {
                    GroupBoxStroke()
                }
            }
    }
}

#if OPENSWIFTUI_LINK_COREUI
// MARK: - GroupBoxBackground

private struct GroupBoxBackground: View {
    @Environment(\.displayScale)
    private var displayScale

    var body: some View {
        StaticIf(in: GroupedFormStyleContext()) {
            AppearanceWidgetView(GroupBoxWidgetDefinition(style: .form, part: .fill, displayScale: displayScale))
        } else: {
            AppearanceWidgetView(GroupBoxWidgetDefinition(style: .normal, part: nil, displayScale: displayScale))
        }
        .contentShape(RoundedRectangle(cornerRadius: approximateCornerRadius, style: .continuous))
    }
}

// MARK: - GroupBoxStroke

private struct GroupBoxStroke: View {
    @Environment(\.displayScale)
    private var displayScale

    var body: some View {
        StaticIf(in: GroupedFormStyleContext()) {
            AppearanceWidgetView(GroupBoxWidgetDefinition(style: .form, part: .stroke, displayScale: displayScale))
        } else: {
            EmptyView()
        }
        .allowsHitTesting(false)
    }
}
#else
private typealias GroupBoxBackground = EmptyView
private typealias GroupBoxStroke = EmptyView
#endif

// MARK: - EnvironmentValues

struct DisableGroupBoxBackground: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var disableGroupBoxBackground: Bool {
        get { self[DisableGroupBoxBackground.self] }
        set { self[DisableGroupBoxBackground.self] = newValue }
    }

    private struct GroupBoxCornerRadiusKey: EnvironmentKey {
        static let defaultValue: CGFloat = 0
    }

    var groupBoxCornerRadius: CGFloat {
        get { self[GroupBoxCornerRadiusKey.self] }
        set { self[GroupBoxCornerRadiusKey.self] = newValue }
    }
}

#if OPENSWIFTUI_LINK_COREUI
// MARK: - GroupBoxWidgetDefinition

private struct GroupBoxWidgetDefinition: AppearanceWidgetDefinition, CoreUIAppearanceWidget {
    enum Style: Hashable {
        case normal
        case form
    }

    enum Part: Hashable {
        case fill
        case stroke
    }

    var style: Style
    var part: Part?
    var displayScale: CGFloat

    var coreUIOptions: [String: Any] {
        var options: [String: Any] = [
            kCUIWidgetKey as String: style == .normal ? "group" : "kCUIWidgetFrameGroupBoxForm",
            kCUIScaleKey as String: displayScale,
            kCUIIsFlippedKey as String: false,
            "kCUIMaskOnlyKey": false,
        ]
        if let part {
            options["kCUIVariantKey"] = part == .fill ? "kCUIVariantFill" : "kCUIVariantStroke"
        }
        return options
    }

    var coreUIRenderer: CoreUIWidgetRendererType { .layer }

    func coreUIAdjustMetric<MetricValue>(
        key: AppearanceMetricName<MetricValue>,
        value: MetricValue?,
        for appearance: CatalogAppearance
    ) -> MetricValue? {
        if key.rawValue == layoutTraitsMetricName.rawValue {
            return (_LayoutTraits() as! MetricValue?)
        }
        return value
    }
}
#endif
#endif
