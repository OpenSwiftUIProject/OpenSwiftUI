//
//  Slider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F045F16106E380A820CC0B639278A953 (SwiftUI)

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore

/// A control for selecting a value from a bounded linear range of values.
///
/// A slider consists of a "thumb" image that the user moves between two
/// extremes of a linear "track". The ends of the track represent the minimum
/// and maximum possible values. As the user moves the thumb, the slider
/// updates its bound value.
///
/// The following example shows a slider bound to the value `speed`. As the
/// slider updates this value, a bound ``Text`` view shows the value updating.
/// The `onEditingChanged` closure passed to the slider receives callbacks when
/// the user drags the slider. The example uses this to change the
/// color of the value text.
///
///     @State private var speed = 50.0
///     @State private var isEditing = false
///
///     var body: some View {
///         VStack {
///             Slider(
///                 value: $speed,
///                 in: 0...100,
///                 onEditingChanged: { editing in
///                     isEditing = editing
///                 }
///             )
///             Text("\(speed)")
///                 .foregroundColor(isEditing ? .red : .blue)
///         }
///     }
///
/// ![An unlabeled slider, with its thumb about one third of the way from the
/// minimum extreme. Below, a blue label displays the value
/// 33.045977.](OpenSwiftUI-Slider-simple.png)
///
/// You can also use a `step` parameter to provide incremental steps along the
/// path of the slider. For example, if you have a slider with a range of `0` to
/// `100`, and you set the `step` value to `5`, the slider's increments would be
/// `0`, `5`, `10`, and so on. The following example shows this approach, and
/// also adds optional minimum and maximum value labels.
///
///     @State private var speed = 50.0
///     @State private var isEditing = false
///
///     var body: some View {
///         Slider(
///             value: $speed,
///             in: 0...100,
///             step: 5
///         ) {
///             Text("Speed")
///         } minimumValueLabel: {
///             Text("0")
///         } maximumValueLabel: {
///             Text("100")
///         } onEditingChanged: { editing in
///             isEditing = editing
///         }
///         Text("\(speed)")
///             .foregroundColor(isEditing ? .red : .blue)
///     }
///
/// ![A slider with labels show minimum and maximum values of 0 and 100,
/// respectively, with its thumb most of the way to the maximum extreme. Below,
/// a blue label displays the value
/// 85.000000.](OpenSwiftUI-Slider-withStepAndLabels.png)
///
/// The slider also uses the `step` to increase or decrease the value when a
/// VoiceOver user adjusts the slider with voice commands.
@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable) // @_spi_available(tvOS, introduced: 18.0)
public struct Slider<Label, ValueLabel>: View where Label: View, ValueLabel: View {
    @Binding var value: Double

    var onEditingChanged: (Bool) -> Void

    let skipDistance: Double

    let discreteValueCount: Int

    let marks: [SliderMark<Double>]?

    var _minimumValueLabel: ValueLabel

    var _maximumValueLabel: ValueLabel

    var hasCustomMinMaxValueLabels: Bool

    var label: Label

    var accessibilityValue: AccessibilityBoundedNumber?

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    nonisolated public init(
        _ configuration: SliderStyleConfiguration
    ) where Label == SliderStyleConfiguration.Label, ValueLabel == SliderStyleConfiguration.ValueLabel {
        _value = configuration.$value
        onEditingChanged = configuration.onEditingChanged
        skipDistance = configuration.skipDistance
        discreteValueCount = configuration.discreteValueCount
        marks = configuration.marks
        _minimumValueLabel = SliderStyleConfiguration.ValueLabel(
            minimumValueLabel: configuration.minimumValueLabel,
            maximumValueLabel: configuration.maximumValueLabel,
            showMinimum: true
        )
        _maximumValueLabel = SliderStyleConfiguration.ValueLabel(
            minimumValueLabel: configuration.minimumValueLabel,
            maximumValueLabel: configuration.maximumValueLabel,
            showMinimum: false
        )
        hasCustomMinMaxValueLabels = configuration.hasCustomMinMaxValueLabels
        label = configuration.label
        accessibilityValue = nil
    }

    public var body: some View {
        let configuration = SliderStyleConfiguration(
            label: .init(),
            minimumValueLabel: .init(),
            maximumValueLabel: .init(),
            value: $value,
            onEditingChanged: onEditingChanged,
            skipDistance: skipDistance,
            discreteValueCount: discreteValueCount,
            marks: marks,
            hasCustomMinMaxValueLabels: hasCustomMinMaxValueLabels,
            accessibilityValue: accessibilityValue
        )
        AccessibilitySliderModifier(configuration, value: accessibilityValue)
            .body(content: ResolvedSliderStyle(configuration: configuration))
            .viewAlias(SliderStyleConfiguration.Label.self) {
                AccessibilityLabelModifier().body(content: label)
            }
            .viewAlias(SliderStyleConfiguration.MinimumValueLabel.self) {
                AccessibilityLabelModifier().body(content: _minimumValueLabel)
            }
            .viewAlias(SliderStyleConfiguration.MaximumValueLabel.self) {
                AccessibilityLabelModifier().body(content: _maximumValueLabel)
            }
    }
}

@available(*, unavailable)
extension Slider: Sendable {}

// MARK: - Creating a slider with labels

@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable)
extension Slider {
    /// Creates a slider to select a value from a given range, which displays
    /// the provided labels.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///   - minimumValueLabel: A view that describes `bounds.lowerBound`.
    ///   - maximumValueLabel: A view that describes `bounds.upperBound`.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @_alwaysEmitIntoClient
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel(),
            maximumValueLabel: maximumValueLabel(),
            label: label
        )
    }

    /// Creates a slider to select a value from a given range, subject to a
    /// step increment, which displays the provided labels.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values.
    ///   - step: The distance between each valid value.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///   - minimumValueLabel: A view that describes `bounds.lowerBound`.
    ///   - maximumValueLabel: A view that describes `bounds.upperBound`.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @_alwaysEmitIntoClient
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel(),
            maximumValueLabel: maximumValueLabel(),
            label: label
        )
    }
}

@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable)
extension Slider where ValueLabel == EmptyView {
    /// Creates a slider to select a value from a given range, which displays
    /// the provided label.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @_alwaysEmitIntoClient
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        @ViewBuilder label: () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            onEditingChanged: onEditingChanged,
            label: label
        )
    }

    /// Creates a slider to select a value from a given range, subject to a
    /// step increment, which displays the provided label.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values.
    ///   - step: The distance between each valid value.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @_alwaysEmitIntoClient
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        @ViewBuilder label: () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged,
            label: label
        )
    }
}

// MARK: - Creating a slider

@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable)
extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    /// Creates a slider to select a value from a given range.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: nil,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: EmptyView(),
            maximumValueLabel: EmptyView(),
            customMinMaxValueLabels: false,
            label: EmptyView(),
            marks: nil
        )
    }

    /// Creates a slider to select a value from a given range, subject to a
    /// step increment.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values.
    ///   - step: The distance between each valid value.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: EmptyView(),
            maximumValueLabel: EmptyView(),
            customMinMaxValueLabels: false,
            label: EmptyView(),
            marks: nil
        )
    }
}

// MARK: - Deprecated initializers

@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable)
extension Slider {
    /// Creates a slider to select a value from a given range, which displays
    /// the provided labels.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///   - minimumValueLabel: A view that describes `bounds.lowerBound`.
    ///   - maximumValueLabel: A view that describes `bounds.upperBound`.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @available(*, deprecated, renamed: "Slider(value:in:label:minimumValueLabel:maximumValueLabel:onEditingChanged:)")
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        minimumValueLabel: ValueLabel,
        maximumValueLabel: ValueLabel,
        @ViewBuilder label: () -> Label
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: nil,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel,
            customMinMaxValueLabels: true,
            label: label(),
            marks: nil
        )
    }

    /// Creates a slider to select a value from a given range, subject to a
    /// step increment, which displays the provided labels.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values.
    ///   - step: The distance between each valid value.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///   - minimumValueLabel: A view that describes `bounds.lowerBound`.
    ///   - maximumValueLabel: A view that describes `bounds.upperBound`.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @available(*, deprecated, renamed: "Slider(value:in:step:label:minimumValueLabel:maximumValueLabel:onEditingChanged:)")
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        minimumValueLabel: ValueLabel,
        maximumValueLabel: ValueLabel,
        @ViewBuilder label: () -> Label
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel,
            customMinMaxValueLabels: true,
            label: label(),
            marks: nil
        )
    }
}

@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable)
extension Slider where ValueLabel == EmptyView {
    /// Creates a slider to select a value from a given range, which displays
    /// the provided label.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values. Defaults to `0...1`.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @available(*, deprecated, renamed: "Slider(value:in:label:onEditingChanged:)")
    @_disfavoredOverload
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder label: () -> Label
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: nil,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: EmptyView(),
            maximumValueLabel: EmptyView(),
            customMinMaxValueLabels: false,
            label: label(),
            marks: nil
        )
    }

    /// Creates a slider to select a value from a given range, subject to a
    /// step increment, which displays the provided label.
    ///
    /// - Parameters:
    ///   - value: The selected value within `bounds`.
    ///   - bounds: The range of the valid values.
    ///   - step: The distance between each valid value.
    ///   - onEditingChanged: A callback for when editing begins and ends.
    ///   - label: A `View` that describes the purpose of the instance. Not all
    ///     slider styles show the label, but even in those cases, OpenSwiftUI
    ///     uses the label for accessibility. For example, VoiceOver uses the
    ///     label to identify the purpose of the slider.
    ///
    /// The `value` of the created instance is equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// The slider calls `onEditingChanged` when editing begins and ends. For
    /// example, on iOS, editing begins when the user starts to drag the thumb
    /// along the slider's track.
    @available(*, deprecated, renamed: "Slider(value:in:step:label:onEditingChanged:)")
    @_disfavoredOverload
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        @ViewBuilder label: () -> Label
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: EmptyView(),
            maximumValueLabel: EmptyView(),
            customMinMaxValueLabels: false,
            label: label(),
            marks: nil
        )
    }
}

// MARK: - Slider + Internal Initializers

extension Slider {
    nonisolated init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride?,
        onEditingChanged: @escaping (Bool) -> Void,
        minimumValueLabel: ValueLabel,
        maximumValueLabel: ValueLabel,
        customMinMaxValueLabels: Bool,
        label: Label,
        marks: [SliderMark<V>]?
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        let normalizing = Normalizing(
            min: bounds.lowerBound,
            max: bounds.upperBound,
            stride: step
        )
        self.init(
            value: value.projecting(normalizing),
            skipDistance: step.map { $0 / normalizing.length },
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel,
            customMinMaxValueLabels: customMinMaxValueLabels,
            accessibilityValue: AccessibilityBoundedNumber(
                for: value.wrappedValue,
                in: bounds,
                by: step
            ),
            label: label,
            marks: marks.map { $0.map { $0.normalized(in: bounds) } }
        )
    }

    nonisolated init<V>(
        value: Binding<V>,
        skipDistance: V?,
        onEditingChanged: @escaping (Bool) -> Void,
        minimumValueLabel: ValueLabel,
        maximumValueLabel: ValueLabel,
        customMinMaxValueLabels: Bool,
        accessibilityValue: AccessibilityBoundedNumber?,
        label: Label,
        marks: [SliderMark<V>]?
    ) where V: BinaryFloatingPoint {
        _value = value.projecting(Clamping())
        self.onEditingChanged = onEditingChanged
        self.skipDistance = skipDistance.map { Double($0) } ?? 0.1
        discreteValueCount = {
            guard let skipDistance else {
                return 0
            }
            return Int((1.0 / Double(skipDistance)).rounded()) + 1
        }()
        _minimumValueLabel = minimumValueLabel
        _maximumValueLabel = maximumValueLabel
        hasCustomMinMaxValueLabels = customMinMaxValueLabels
        self.label = label
        self.accessibilityValue = accessibilityValue
        if let marks {
            var uniqueMarks: [SliderMark<Double>] = []
            var previousMark: SliderMark<Double>?
            for mark in marks.map({ SliderMark<Double>($0) }).sorted() {
                if let previousMark, previousMark.value == mark.value {
                    Log.runtimeIssues("Multiple marks specified for value %f", [mark.value])
                    continue
                }
                uniqueMarks.append(mark)
                previousMark = mark
            }
            self.marks = uniqueMarks
        } else {
            self.marks = nil
        }
    }
}

// MARK: - Projections

private struct Clamping<Value>: Projection where Value: BinaryFloatingPoint {
    func get(base: Value) -> Double {
        Double(base).clamped(to: 0 ... 1)
    }

    func set(base: inout Value, newValue: Double) {
        base = Value(newValue).clamp(min: 0, max: 1)
    }
}

private struct Normalizing<Value>: Projection where Value: Strideable, Value: Hashable, Value.Stride: BinaryFloatingPoint {
    let min: Value
    let max: Value
    let stride: Value.Stride?
    let maxStrides: Value.Stride?
    let length: Value.Stride

    init(min: Value, max: Value, stride: Value.Stride?) {
        self.min = min
        self.max = max
        self.stride = stride

        if let stride {
            let result = (min.distance(to: max) / stride).rounded(.down)
            precondition(result > 0, "max stride must be positive")
            length = stride * result
            maxStrides = result
        } else {
            length = min.distance(to: max)
            maxStrides = nil
        }
    }

    func get(base: Value) -> Value.Stride {
        min.distance(to: base) / length
    }

    func set(base: inout Value, newValue: Value.Stride) {
        let newStride: Value.Stride
        if let stride, let maxStrides {
            newStride = stride * (newValue * maxStrides).rounded(.toNearestOrAwayFromZero)
        } else {
            newStride = newValue * length
        }
        base = min.advanced(by: newStride)
    }
}
