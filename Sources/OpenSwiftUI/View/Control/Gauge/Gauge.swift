//
//  Gauge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E32E1057CBE5FADC5D0032ED0E98877A (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - Gauge

/// A view that shows a value within a range.
///
/// A gauge is a view that shows a current level of a value in relation
/// to a specified finite capacity, very much like a fuel gauge in an
/// automobile. Gauge displays are configurable; they can show
/// any combination of the gauge's current value, the range the gauge can
/// display, and a label describing the purpose of the gauge itself.
///
/// In its most basic form, a gauge displays a single value along the path of
/// the gauge mapped into a range from 0 to 100 percent. The example below sets
/// the gauge's indicator to a position 40 percent along the gauge's path:
///
///     struct SimpleGauge: View {
///         @State private var batteryLevel = 0.4
///
///         var body: some View {
///             Gauge(value: batteryLevel) {
///                 Text("Battery Level")
///             }
///         }
///     }
///
/// ![A linear gauge displaying a current value set to 40 percent in a range of 0
///  to 1.](OpenSwiftUI-Gauge-ValueLabelLinear)
///
/// You can make a gauge more descriptive by describing its purpose, showing
/// its current value and its start and end values. This example shows the
/// gauge variant that accepts a range and adds labels using multiple
/// trailing closures describing the current value and the minimum
/// and maximum values of the gauge:
///
///     struct LabeledGauge: View {
///         @State private var current = 67.0
///         @State private var minValue = 0.0
///         @State private var maxValue = 170.0
///
///         var body: some View {
///             Gauge(value: current, in: minValue...maxValue) {
///                 Text("BPM")
///             } currentValueLabel: {
///                 Text("\(Int(current))")
///             } minimumValueLabel: {
///                 Text("\(Int(minValue))")
///             } maximumValueLabel: {
///                 Text("\(Int(maxValue))")
///             }
///         }
///     }
///
/// ![A linear gauge describing heart-rate in beats per minute with its
/// value set to 67 in a range of 0 to
/// 170.](OpenSwiftUI-Gauge-Label-CurrentValueLinear)
///
/// As shown above, the default style for gauges is a linear, continuous bar
/// with an indicator showing the current value, and optional labels describing
/// the gauge's purpose, current, minimum, and maximum values.
///
/// > Note: Some visual presentations of `Gauge` don't display all the
///   labels required by the API. However, the accessibility system does use
///   the label content and you should use these labels to fully describe
///   the gauge for accessibility users.
///
/// To change the style of a gauge, use the ``View/gaugeStyle(_:)``
/// view modifier and supply an initializer for a specific gauge style. For
/// example, to display the same gauge in a circular style, apply the
/// ``GaugeStyle/circular`` style to the view:
///
///     struct LabeledGauge: View {
///         @State private var current = 67.0
///         @State private var minValue = 0.0
///         @State private var maxValue = 170.0
///
///         var body: some View {
///             Gauge(value: current, in: minValue...maxValue) {
///                 Text("BPM")
///             } currentValueLabel: {
///                 Text("\(Int(current))")
///             } minimumValueLabel: {
///                 Text("\(Int(minValue))")
///             } maximumValueLabel: {
///                 Text("\(Int(maxValue))")
///             }
///             .gaugeStyle(.circular)
///         }
///     }
///
/// ![A circular gauge describing heart rate in beats per minute with its
/// value set to 67 in a range of 0 to 170.](OpenSwiftUI-Gauge-LabeledCircular)
///
/// To style elements of a gauge's presentation, you apply view modifiers to
/// the elements that you want to change. In the example below, the current
/// value, minimum and maximum value labels have custom colors:
///
///     struct StyledGauge: View {
///         @State private var current = 67.0
///         @State private var minValue = 50.0
///         @State private var maxValue = 170.0
///
///         var body: some View {
///             Gauge(value: current, in: minValue...maxValue) {
///                 Image(systemName: "heart.fill")
///                     .foregroundColor(.red)
///             } currentValueLabel: {
///                 Text("\(Int(current))")
///                     .foregroundColor(Color.green)
///             } minimumValueLabel: {
///                 Text("\(Int(minValue))")
///                     .foregroundColor(Color.green)
///             } maximumValueLabel: {
///                 Text("\(Int(maxValue))")
///                     .foregroundColor(Color.red)
///             }
///             .gaugeStyle(.circular)
///         }
///     }
///
/// ![A circular gauge describing heart rate in beats per minute with its
/// value set to 67 on a range of 0 to 170. The style of each label is
/// individually set showing custom label
/// colors.](OpenSwiftUI-Gauge-CircularStyled)
///
/// You can further style a gauge's appearance by supplying a tint color or
/// a gradient to the style's initializer. The following example shows the
/// effect of a gradient in the initialization of a ``CircularGaugeStyle``
/// gauge with a colorful gradient across the length of the gauge:
///
///     struct StyledGauge: View {
///         @State private var current = 67.0
///         @State private var minValue = 50.0
///         @State private var maxValue = 170.0
///         let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
///
///         var body: some View {
///             Gauge(value: current, in: minValue...maxValue) {
///                 Image(systemName: "heart.fill")
///                     .foregroundColor(.red)
///             } currentValueLabel: {
///                 Text("\(Int(current))")
///                     .foregroundColor(Color.green)
///             } minimumValueLabel: {
///                 Text("\(Int(minValue))")
///                     .foregroundColor(Color.green)
///             } maximumValueLabel: {
///                 Text("\(Int(maxValue))")
///                     .foregroundColor(Color.red)
///             }
///             .gaugeStyle(CircularGaugeStyle(tint: gradient))
///         }
///     }
/// ![A screenshot showing a circular gauge with a gradient
///  tint.](OpenSwiftUI-Gauge-Circular-Gradient)
///
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
public struct Gauge<Label, CurrentValueLabel, BoundsLabel, MarkedValueLabels>: View where Label: View, CurrentValueLabel: View, BoundsLabel: View, MarkedValueLabels: View {
    let value: Double
    let label: Label?
    let currentValueLabel: CurrentValueLabel?
    let minimumValueLabel: BoundsLabel?
    let maximumValueLabel: BoundsLabel?
    let markedValueLabels: MarkedValueLabels?

    /// Creates a gauge showing a value within a range and describes the
    /// gauge's purpose and current value.
    ///
    /// Use this modifier to create a gauge that shows the value at its
    /// relative position along the gauge and a label describing the gauge's
    /// purpose. In the example below, the gauge has a range of `0...1`, the
    /// indicator is set to `0.4`, or 40 percent of the distance along the
    /// gauge:
    ///
    ///     struct SimpleGauge: View {
    ///         @State private var batteryLevel = 0.4
    ///
    ///         var body: some View {
    ///             Gauge(value: batteryLevel) {
    ///                 Text("Battery Level")
    ///             }
    ///         }
    ///     }
    ///
    /// ![A linear gauge that shows an indicator at 40 percent along the length
    /// of the gauge.](OpenSwiftUI-Gauge-ValueLabelLinear)
    ///
    /// - Parameters:
    ///     - value: The value to show in the gauge.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - label: A view that describes the purpose of the gauge.
    public init<V>(
        value: V,
        in bounds: ClosedRange<V> = 0...1,
        @ViewBuilder label: () -> Label
    ) where CurrentValueLabel == EmptyView, BoundsLabel == EmptyView, MarkedValueLabels == EmptyView, V: BinaryFloatingPoint {
        self.value = Self.normalize(value, in: bounds)
        self.label = label()
        currentValueLabel = nil
        minimumValueLabel = nil
        maximumValueLabel = nil
        markedValueLabels = nil
    }

    /// Creates a gauge showing a value within a range and that describes the
    /// gauge's purpose and current value.
    ///
    /// Use this method to create a gauge that displays a value within a range
    /// you supply with labels that describe the purpose of the gauge and its
    /// current value. In the example below, a gauge using the
    /// ``GaugeStyle/circular`` style shows its current value of `67` along with a
    /// label describing the (BPM) for the gauge:
    ///
    ///     struct SimpleGauge: View {
    ///         @State private var current = 67.0
    ///
    ///         var body: some View {
    ///             Gauge(value: current, in: 0...170) {
    ///                 Text("BPM")
    ///             } currentValueLabel: {
    ///                 Text("\(current)")
    ///             }
    ///             .gaugeStyle(.circular)
    ///         }
    ///     }
    ///
    /// ![A screenshot showing a circular gauge describing heart rate in beats
    /// per minute, with the indicator and the current value label indicating a
    /// value of 67.](OpenSwiftUI-Gauge-LabelCurrentValueCircular)
    ///
    /// - Parameters:
    ///     - value: The value to show on the gauge.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - label: A view that describes the purpose of the gauge.
    ///     - currentValueLabel: A view that describes the current value of
    ///       the gauge.
    public init<V>(
        value: V,
        in bounds: ClosedRange<V> = 0...1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel
    ) where BoundsLabel == EmptyView, MarkedValueLabels == EmptyView, V: BinaryFloatingPoint {
        self.value = Self.normalize(value, in: bounds)
        self.label = label()
        self.currentValueLabel = currentValueLabel()
        minimumValueLabel = nil
        maximumValueLabel = nil
        markedValueLabels = nil
    }

    /// Creates a gauge showing a value within a range and describes the
    /// gauge's current, minimum, and maximum values.
    ///
    /// Use this method to create a gauge that shows a value within a
    /// prescribed bounds. The gauge has labels that describe its purpose,
    /// and for the gauge's current, minimum, and maximum values.
    ///
    ///     struct LabeledGauge: View {
    ///         @State private var current = 67.0
    ///         @State private var minValue = 0.0
    ///         @State private var maxValue = 170.0
    ///
    ///         var body: some View {
    ///             Gauge(value: current, in: minValue...maxValue) {
    ///                 Text("BPM")
    ///             } currentValueLabel: {
    ///                 Text("\(Int(current))")
    ///             } minimumValueLabel: {
    ///                 Text("\(Int(minValue))")
    ///             } maximumValueLabel: {
    ///                 Text("\(Int(maxValue))")
    ///             }
    ///         }
    ///     }
    ///
    /// ![A screenshot of a gauge, labeled BPM, that's represented by a
    /// semicircle showing its current value of 67 along a range of 0
    /// to 170.](OpenSwiftUI-Gauge-LabeledCircular)
    ///
    /// - Parameters:
    ///     - value: The value to show on the gauge.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - label: A view that describes the purpose of the gauge.
    ///     - currentValueLabel: A view that describes the current value of
    ///       the gauge.
    ///     - minimumValueLabel: A view that describes the lower bounds of the
    ///       gauge.
    ///     - maximumValueLabel: A view that describes the upper bounds of the
    ///       gauge.
    public init<V>(
        value: V,
        in bounds: ClosedRange<V> = 0...1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel,
        @ViewBuilder minimumValueLabel: () -> BoundsLabel,
        @ViewBuilder maximumValueLabel: () -> BoundsLabel
    ) where MarkedValueLabels == EmptyView, V: BinaryFloatingPoint {
        self.value = Self.normalize(value, in: bounds)
        self.label = label()
        self.currentValueLabel = currentValueLabel()
        self.minimumValueLabel = minimumValueLabel()
        self.maximumValueLabel = maximumValueLabel()
        markedValueLabels = nil
    }

    /// Creates a gauge representing a value within a range.
    ///
    /// - Parameters:
    ///     - value: The value to show in the instance.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - label: A view that describes the purpose of the gauge.
    ///     - currentValueLabel: A view that describes the current value of
    ///       the gauge.
    ///     - markedValueLabels: A view builder containing tagged views,
    ///       each of which describes a particular value of the gauge.
    ///       The method ignores this parameter.
    public init<V>(
        value: V,
        in bounds: ClosedRange<V> = 0...1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel,
        @ViewBuilder markedValueLabels: () -> MarkedValueLabels
    ) where BoundsLabel == EmptyView, V: BinaryFloatingPoint {
        self.value = Self.normalize(value, in: bounds)
        self.label = label()
        self.currentValueLabel = currentValueLabel()
        minimumValueLabel = nil
        maximumValueLabel = nil
        self.markedValueLabels = markedValueLabels()
    }

    /// Creates a gauge representing a value within a range.
    ///
    /// - Parameters:
    ///     - value: The value to show in the gauge.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - label: A view that describes the purpose of the gauge.
    ///     - currentValueLabel: A view that describes the current value of
    ///       the gauge.
    ///     - minimumValueLabel: A view that describes the lower bounds of the
    ///       gauge.
    ///     - maximumValueLabel: A view that describes the upper bounds of the
    ///       gauge.
    ///     - markedValueLabels: A view builder containing tagged views,
    ///       each of which describes a particular value of the gauge.
    ///       The method ignores this parameter.
    public init<V>(
        value: V,
        in bounds: ClosedRange<V> = 0...1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel,
        @ViewBuilder minimumValueLabel: () -> BoundsLabel,
        @ViewBuilder maximumValueLabel: () -> BoundsLabel,
        @ViewBuilder markedValueLabels: () -> MarkedValueLabels
    ) where V: BinaryFloatingPoint {
        self.value = Self.normalize(value, in: bounds)
        self.label = label()
        self.currentValueLabel = currentValueLabel()
        self.minimumValueLabel = minimumValueLabel()
        self.maximumValueLabel = maximumValueLabel()
        self.markedValueLabels = markedValueLabels()
    }

    public var body: some View {
        BaseGauge(
            value: value,
            label: label,
            currentValueLabel: currentValueLabel,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        )
    }

    @inline(__always)
    private static func normalize<V>(
        _ value: V,
        in bounds: ClosedRange<V>
    ) -> Double where V: BinaryFloatingPoint {
        if !bounds.contains(value) {
            Log.runtimeIssues("Gauge initialized with an out-of-bounds progress amount. The amount will be clamped to the nearest bound.")
        }
        let length = bounds.length
        return length > 0 ? Double((value - bounds.lowerBound) / length).clamp(min: 0, max: 1) : 1
    }
}

@available(*, unavailable)
extension Gauge: Sendable {}

// MARK: - BaseGauge

struct BaseGauge<Label, CurrentValueLabel, BoundsLabel>: PrimitiveView, UnaryView, View where Label: View, CurrentValueLabel: View, BoundsLabel: View {
    var value: Double
    var label: Label?
    var currentValueLabel: CurrentValueLabel?
    var minimumValueLabel: BoundsLabel?
    var maximumValueLabel: BoundsLabel?

    nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let baseValue = view.value[offset: { .of(&$0.value) }]
        let label = view.value[offset: { .of(&$0.label) }]
        let currentValueLabel = view.value[offset: { .of(&$0.currentValueLabel) }]
        let minimumValueLabel = view.value[offset: { .of(&$0.minimumValueLabel) }]
        let maximumValueLabel = view.value[offset: { .of(&$0.maximumValueLabel) }]
        let child = Child(
            baseValue: baseValue,
            label: label,
            currentValueLabel: currentValueLabel,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        )
        var outputs = Child.Value._makeView(view: _GraphValue(child), inputs: inputs)
        if inputs.preferences.contains(WidgetAuxiliaryViewMetadata.Key.self) {
            outputs.preferences.platformItemList = nil
            outputs.preferences.makePreferenceWriter(
                inputs: inputs.preferences,
                key: WidgetAuxiliaryViewMetadata.Key.self,
                value: Attribute(
                    WidgetMetadataWriter(
                        baseValue: baseValue,
                        labelPref: Attribute(LazyWidgetAuxiliaryMetadataTextImage(
                            flags: _AttributeType.Flags.self,
                            content: label,
                            inputs: inputs
                        )),
                        currentValueLabelPref: Attribute(LazyWidgetAuxiliaryMetadataTextImage(
                            flags: _AttributeType.Flags.self,
                            content: currentValueLabel,
                            inputs: inputs
                        )),
                        minimumValueLabelPref: Attribute(LazyWidgetAuxiliaryMetadataTextImage(
                            flags: _AttributeType.Flags.self,
                            content: minimumValueLabel,
                            inputs: inputs
                        )),
                        maximumValueLabelPref: Attribute(LazyWidgetAuxiliaryMetadataTextImage(
                            flags: _AttributeType.Flags.self,
                            content: maximumValueLabel,
                            inputs: inputs
                        )),
                        environment: inputs.environment
                    )
                )
            )
        }
        return outputs
    }

    private struct WidgetMetadataWriter: Rule {
        @Attribute var baseValue: Double
        @Attribute var labelPref: WidgetAuxiliaryTextImagePreference?
        @Attribute var currentValueLabelPref: WidgetAuxiliaryTextImagePreference?
        @Attribute var minimumValueLabelPref: WidgetAuxiliaryTextImagePreference?
        @Attribute var maximumValueLabelPref: WidgetAuxiliaryTextImagePreference?
        @Attribute var environment: EnvironmentValues

        var value: WidgetAuxiliaryViewMetadata? {
            let label = WidgetAuxiliaryViewMetadata(
                item: labelPref?.list?.mergedContentItem,
                url: nil,
                accessibility: nil,
                child: nil
            )
            let currentValueLabel = WidgetAuxiliaryViewMetadata(
                item: currentValueLabelPref?.list?.mergedContentItem,
                url: nil,
                accessibility: nil,
                child: nil
            )
            let minimumValueLabel = WidgetAuxiliaryViewMetadata(
                item: minimumValueLabelPref?.list?.mergedContentItem,
                url: nil,
                accessibility: nil,
                child: nil
            )
            let maximumValueLabel = WidgetAuxiliaryViewMetadata(
                item: maximumValueLabelPref?.list?.mergedContentItem,
                url: nil,
                accessibility: nil,
                child: nil
            )
            return WidgetAuxiliaryViewMetadata(gauge: .init(
                value: baseValue,
                label: label,
                currentValueLabel: currentValueLabel,
                minimumValueLabel: minimumValueLabel,
                maximumValueLabel: maximumValueLabel,
                tint: WidgetAuxiliaryViewMetadata.tint(from: environment)
            ))
        }
    }

    private struct Child: Rule {
        @Attribute var baseValue: Double
        @Attribute var label: Label?
        @Attribute var currentValueLabel: CurrentValueLabel?
        @Attribute var minimumValueLabel: BoundsLabel?
        @Attribute var maximumValueLabel: BoundsLabel?

        var value: some View {
            ResolvedGauge(value: baseValue)
                .optionalViewAlias(GaugeStyleConfiguration.Label.self) { label }
                .optionalViewAlias(GaugeStyleConfiguration.CurrentValueLabel.self) { currentValueLabel }
                .optionalViewAlias(GaugeStyleConfiguration.MinimumValueLabel.self) { minimumValueLabel }
                .optionalViewAlias(GaugeStyleConfiguration.MaximumValueLabel.self) { maximumValueLabel }
                .accessibilityConfiguration(AccessibilityGaugeModifier(baseValue))
        }
    }
}

// MARK: - ResolvedGauge

private struct ResolvedGauge: View {
    let value: Double

    @OptionalViewAlias var currentValueLabel: GaugeStyleConfiguration.CurrentValueLabel?
    @OptionalViewAlias var minimumValueLabel: GaugeStyleConfiguration.MinimumValueLabel?
    @OptionalViewAlias var maximumValueLabel: GaugeStyleConfiguration.MaximumValueLabel?

    var body: some View {
        ResolvedGaugeStyle(configuration: GaugeStyleConfiguration(
            value: value,
            label: .init(),
            currentValueLabel: currentValueLabel,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        ))
    }
}
