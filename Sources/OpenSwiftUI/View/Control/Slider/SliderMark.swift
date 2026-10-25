//
//  SliderMark.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - Slider + SliderMark

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Slider {
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        @SliderMarkBuilder<V> marks: () -> [SliderMark<V>],
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: nil,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel(),
            maximumValueLabel: maximumValueLabel(),
            customMinMaxValueLabels: false,
            label: label(),
            marks: marks()
        )
    }

    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        @SliderMarkBuilder<V> marks: () -> [SliderMark<V>],
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        self.init(
            value: value,
            in: bounds,
            step: step,
            onEditingChanged: onEditingChanged,
            minimumValueLabel: minimumValueLabel(),
            maximumValueLabel: maximumValueLabel(),
            customMinMaxValueLabels: false,
            label: label(),
            marks: marks()
        )
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Slider where ValueLabel == EmptyView {
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0 ... 1,
        @ViewBuilder label: () -> Label,
        @SliderMarkBuilder<V> marks: () -> [SliderMark<V>],
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
            label: label(),
            marks: marks()
        )
    }

    @available(tvOS, unavailable)
    nonisolated public init<V>(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        @ViewBuilder label: () -> Label,
        @SliderMarkBuilder<V> marks: () -> [SliderMark<V>],
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
            label: label(),
            marks: marks()
        )
    }
}

// MARK: - SliderMark

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public struct SliderMark<V>: Identifiable, Comparable where V: BinaryFloatingPoint {
    public typealias Label = Text

    public struct ID: Hashable {
        var value: V
    }

    var label: Label?

    var value: V

    public init(_ value: V, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.value = value
    }

    public init(_ value: V) {
        self.label = nil
        self.value = value
    }

    public var id: ID {
        ID(value: value)
    }

    func normalized(in bounds: ClosedRange<V>) -> SliderMark<V.Stride> where V.Stride: BinaryFloatingPoint {
        SliderMark<V.Stride>(
            label: label,
            value: bounds.lowerBound.distance(to: value) / bounds.lowerBound.distance(to: bounds.upperBound)
        )
    }

    public static func < (lhs: SliderMark, rhs: SliderMark) -> Bool {
        lhs.value < rhs.value
    }

    private init(label: Label?, value: V) {
        self.label = label
        self.value = value
    }
}

@_spi(Private)
@available(*, unavailable)
extension SliderMark.ID: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SliderMark: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension SliderMark {
    public init(_ titleKey: LocalizedStringKey, _ value: V) {
        self.init(value) { Text(titleKey) }
    }

    @_disfavoredOverload
    public init<S>(_ title: S, _ value: V) where S: StringProtocol {
        self.init(value) { Text(title) }
    }
}

extension SliderMark where V == Double {
    init<Other>(_ mark: SliderMark<Other>) where Other: BinaryFloatingPoint {
        self.label = mark.label
        self.value = Double(mark.value)
    }
}

// MARK: - SliderMarkBuilder

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@resultBuilder
public struct SliderMarkBuilder<V> where V: BinaryFloatingPoint {
    public static func buildBlock(_ components: SliderMark<V>...) -> [SliderMark<V>] {
        components
    }

    @_spi(DoNotImport)
    public static func buildBlock(_ components: [SliderMark<V>]) -> [SliderMark<V>] {
        components
    }
}

@_spi(Private)
@available(*, unavailable)
extension SliderMarkBuilder: Sendable {}
