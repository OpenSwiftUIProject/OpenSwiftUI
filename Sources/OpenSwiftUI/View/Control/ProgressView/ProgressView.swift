//
//  ProgressView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 936A47782A7E2FBE97D58CDBAEB02770 (SwiftUI)

import OpenAttributeGraphShims
public import Foundation
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - ProgressView

/// A view that shows the progress toward completion of a task.
///
/// Use a progress view to show that a task is incomplete but advancing toward
/// completion. A progress view can show both determinate (percentage complete)
/// and indeterminate (progressing or not) types of progress.
///
/// Create a determinate progress view by initializing a `ProgressView` with
/// a binding to a numeric value that indicates the progress, and a `total`
/// value that represents completion of the task. By default, the progress is
/// `0.0` and the total is `1.0`.
///
/// The example below uses the state property `progress` to show progress in
/// a determinate `ProgressView`. The progress view uses its default total of
/// `1.0`, and because `progress` starts with an initial value of `0.5`,
/// the progress view begins half-complete. A "More" button below the progress
/// view allows people to increment the progress in increments of five percent:
///
///     struct LinearProgressDemoView: View {
///         @State private var progress = 0.5
///
///         var body: some View {
///             VStack {
///                 ProgressView(value: progress)
///                 Button("More") { progress += 0.05 }
///             }
///         }
///     }
///
/// ![A horizontal bar that represents progress, with a More button
/// placed underneath. The progress bar is at 50 percent from the leading
/// edge.](ProgressView-1-macOS)
///
/// To create an indeterminate progress view, use an initializer that doesn't
/// take a progress value:
///
///     var body: some View {
///         ProgressView()
///     }
///
/// ![An indeterminate progress view, presented as a spinning set of gray lines
/// emanating from the center of a circle, with opacity varying from fully
/// opaque to transparent. An animation rotates which line is most opaque,
/// creating the spinning effect.](ProgressView-2-macOS)
///
/// You can also create a progress view that covers a closed range of
/// [Date](https://developer.apple.com/documentation/foundation/date) values. As
/// long as the current date is within the range, the progress view
/// automatically updates, filling or depleting the progress view as it nears
/// the end of the range. The following example shows a five-minute timer whose
/// start time is that of the progress view's initialization:
///
///     struct DateRelativeProgressDemoView: View {
///         let workoutDateRange = Date()...Date().addingTimeInterval(5*60)
///
///         var body: some View {
///              ProgressView(timerInterval: workoutDateRange) {
///                  Text("Workout")
///              }
///         }
///     }
///
/// ![A horizontal progress view that shows a bar partially filled with as it
/// counts a five-minute duration.](ProgressView-3-macOS)
///
/// ### Styling progress views
///
/// You can customize the appearance and interaction of progress views by
/// creating styles that conform to the ``ProgressViewStyle`` protocol. To set a
/// specific style for all progress view instances within a view, use the
/// ``View/progressViewStyle(_:)`` modifier. In the following example, a custom
/// style adds a rounded pink border to all progress views within the enclosing
/// ``VStack``:
///
///     struct BorderedProgressViews: View {
///         var body: some View {
///             VStack {
///                 ProgressView(value: 0.25) { Text("25% progress") }
///                 ProgressView(value: 0.75) { Text("75% progress") }
///             }
///             .progressViewStyle(PinkBorderedProgressViewStyle())
///         }
///     }
///
///     struct PinkBorderedProgressViewStyle: ProgressViewStyle {
///         func makeBody(configuration: Configuration) -> some View {
///             ProgressView(configuration)
///                 .padding(4)
///                 .border(.pink, width: 3)
///                 .cornerRadius(4)
///         }
///     }
///
/// ![Two horizontal progress views, one at 25 percent complete and the other at 75 percent,
/// each rendered with a rounded pink border.](ProgressView-4-macOS)
///
/// OpenSwiftUI provides two built-in progress view styles,
/// ``ProgressViewStyle/linear`` and ``ProgressViewStyle/circular``, as well as
/// an automatic style that defaults to the most appropriate style in the
/// current context. The following example shows a circular progress view that
/// starts at 60 percent completed.
///
///     struct CircularProgressDemoView: View {
///         @State private var progress = 0.6
///
///         var body: some View {
///             VStack {
///                 ProgressView(value: progress)
///                     .progressViewStyle(.circular)
///             }
///         }
///     }
///
/// ![A ring shape, filled to 60 percent completion with a blue
/// tint.](ProgressView-5-macOS)
///
/// On platforms other than macOS, the circular style may appear as an
/// indeterminate indicator instead.
@available(OpenSwiftUI_v2_0, *)
public struct ProgressView<Label, CurrentValueLabel>: View where Label: View, CurrentValueLabel: View {
    var base: Base

    public var body: some View {
        switch base {
        case let .custom(custom): custom
        case let .observing(observing): observing
        }
    }

    enum Base {
        case custom(CustomProgressView<Label, CurrentValueLabel>)
        case observing(FoundationProgressView)
    }
}

@available(*, unavailable)
extension ProgressView: Sendable {}

// MARK: - Indeterminate Initializers

@available(OpenSwiftUI_v2_0, *)
extension ProgressView where CurrentValueLabel == EmptyView {
    /// Creates a progress view for showing indeterminate progress, without a
    /// label.
    nonisolated public init() where Label == EmptyView {
        self.init(label: nil)
    }

    /// Creates a progress view for showing indeterminate progress that displays
    /// a custom label.
    ///
    /// - Parameters:
    ///     - label: A view builder that creates a view that describes the task
    ///       in progress.
    nonisolated public init(@ViewBuilder label: () -> Label) {
        self.init(label: label())
    }

    /// Creates a progress view for showing indeterminate progress that
    /// generates its label from a localized string.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings. To initialize an
    /// indeterminate progress view with a string variable, use the
    /// corresponding initializer that takes a `StringProtocol` instance.
    ///
    /// - Parameters:
    ///     - titleKey: The key for the progress view's localized title that
    ///       describes the task in progress.
    nonisolated public init(_ titleKey: LocalizedStringKey) where Label == Text {
        self.init(label: Text(titleKey))
    }

    /// Creates a progress view for showing indeterminate progress that
    /// generates its label from a string.
    ///
    /// - Parameters:
    ///     - title: A string that describes the task in progress.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(verbatim:)``. See ``Text`` for more
    /// information about localizing strings. To initialize a progress view with
    /// a localized string key, use the corresponding initializer that takes a
    /// `LocalizedStringKey` instance.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S) where Label == Text, S: StringProtocol {
        self.init(label: Text(title))
    }

    nonisolated init(label: Label?) {
        base = .custom(
            CustomProgressView(
                fractionCompleted: nil,
                alwaysIndeterminate: true,
                label: label,
                currentValueLabel: nil
            )
        )
    }
}

// MARK: - Value-Based Initializers

@available(OpenSwiftUI_v2_0, *)
extension ProgressView {
    /// Creates a progress view for showing determinate progress.
    ///
    /// If the value is non-`nil`, but outside the range of `0.0` through
    /// `total`, the progress view pins the value to those limits, rounding to
    /// the nearest possible bound. A value of `nil` represents indeterminate
    /// progress, in which case the progress view ignores `total`.
    ///
    /// - Parameters:
    ///     - value: The completed amount of the task to this point, in a range
    ///       of `0.0` to `total`, or `nil` if the progress is indeterminate.
    ///     - total: The full amount representing the complete scope of the
    ///       task, meaning the task is complete if `value` equals `total`. The
    ///       default value is `1.0`.
    nonisolated public init<V>(
        value: V?,
        total: V = 1.0
    ) where Label == EmptyView, CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
        self.init(
            value: value,
            total: total,
            label: nil,
            currentValueLabel: nil
        )
    }

    /// Creates a progress view for showing determinate progress, with a
    /// custom label.
    ///
    /// If the value is non-`nil`, but outside the range of `0.0` through
    /// `total`, the progress view pins the value to those limits, rounding to
    /// the nearest possible bound. A value of `nil` represents indeterminate
    /// progress, in which case the progress view ignores `total`.
    ///
    /// - Parameters:
    ///     - value: The completed amount of the task to this point, in a range
    ///       of `0.0` to `total`, or `nil` if the progress is indeterminate.
    ///     - total: The full amount representing the complete scope of the
    ///       task, meaning the task is complete if `value` equals `total`. The
    ///       default value is `1.0`.
    ///     - label: A view builder that creates a view that describes the task
    ///       in progress.
    nonisolated public init<V>(
        value: V?,
        total: V = 1.0,
        @ViewBuilder label: () -> Label
    ) where CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
        self.init(
            value: value,
            total: total,
            label: label(),
            currentValueLabel: nil
        )
    }

    /// Creates a progress view for showing determinate progress, with a
    /// custom label.
    ///
    /// If the value is non-`nil`, but outside the range of `0.0` through
    /// `total`, the progress view pins the value to those limits, rounding to
    /// the nearest possible bound. A value of `nil` represents indeterminate
    /// progress, in which case the progress view ignores `total`.
    ///
    /// - Parameters:
    ///     - value: The completed amount of the task to this point, in a range
    ///       of `0.0` to `total`, or `nil` if the progress is indeterminate.
    ///     - total: The full amount representing the complete scope of the
    ///       task, meaning the task is complete if `value` equals `total`. The
    ///       default value is `1.0`.
    ///     - label: A view builder that creates a view that describes the task
    ///       in progress.
    ///     - currentValueLabel: A view builder that creates a view that
    ///       describes the level of completed progress of the task.
    nonisolated public init<V>(
        value: V?,
        total: V = 1.0,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel
    ) where V: BinaryFloatingPoint {
        self.init(
            value: value,
            total: total,
            label: label(),
            currentValueLabel: currentValueLabel()
        )
    }

    /// Creates a progress view for showing determinate progress that generates
    /// its label from a localized string.
    ///
    /// If the value is non-`nil`, but outside the range of `0.0` through
    /// `total`, the progress view pins the value to those limits, rounding to
    /// the nearest possible bound. A value of `nil` represents indeterminate
    /// progress, in which case the progress view ignores `total`.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings. To initialize a
    /// determinate progress view with a string variable, use the corresponding
    /// initializer that takes a `StringProtocol` instance.
    ///
    /// - Parameters:
    ///     - titleKey: The key for the progress view's localized title that
    ///       describes the task in progress.
    ///     - value: The completed amount of the task to this point, in a range
    ///       of `0.0` to `total`, or `nil` if the progress is
    ///       indeterminate.
    ///     - total: The full amount representing the complete scope of the
    ///       task, meaning the task is complete if `value` equals `total`. The
    ///       default value is `1.0`.
    nonisolated public init<V>(
        _ titleKey: LocalizedStringKey,
        value: V?,
        total: V = 1.0
    ) where Label == Text, CurrentValueLabel == EmptyView, V: BinaryFloatingPoint {
        self.init(
            value: value,
            total: total,
            label: Text(titleKey),
            currentValueLabel: nil
        )
    }

    /// Creates a progress view for showing determinate progress that generates
    /// its label from a string.
    ///
    /// If the value is non-`nil`, but outside the range of `0.0` through
    /// `total`, the progress view pins the value to those limits, rounding to
    /// the nearest possible bound. A value of `nil` represents indeterminate
    /// progress, in which case the progress view ignores `total`.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(verbatim:)``. See ``Text`` for more
    /// information about localizing strings. To initialize a determinate
    /// progress view with a localized string key, use the corresponding
    /// initializer that takes a `LocalizedStringKey` instance.
    ///
    /// - Parameters:
    ///     - title: The string that describes the task in progress.
    ///     - value: The completed amount of the task to this point, in a range
    ///       of `0.0` to `total`, or `nil` if the progress is
    ///       indeterminate.
    ///     - total: The full amount representing the complete scope of the
    ///       task, meaning the task is complete if `value` equals `total`. The
    ///       default value is `1.0`.
    @_disfavoredOverload
    nonisolated public init<S, V>(
        _ title: S,
        value: V?,
        total: V = 1.0
    ) where Label == Text, CurrentValueLabel == EmptyView, S: StringProtocol, V: BinaryFloatingPoint {
        self.init(
            value: value,
            total: total,
            label: Text(title),
            currentValueLabel: nil
        )
    }

    nonisolated init<V>(
        value: V?,
        total: V,
        label: Label?,
        currentValueLabel: CurrentValueLabel?
    ) where V: BinaryFloatingPoint {
        var fractionCompleted: Double? {
            guard let value else {
                return nil
            }
            if value < 0 || value > total {
                Log.runtimeIssues(
                    "ProgressView initialized with an out-of-bounds progress value. The value will be clamped to the range of `0...total`."
                )
            }
            guard value >= 0,
                  total >= 0,
                  value != 0 || total != 0 else {
                return nil
            }
            return Double(value / total).clamp(min: 0, max: 1)
        }
        base = .custom(
            CustomProgressView(
                fractionCompleted: fractionCompleted,
                alwaysIndeterminate: false,
                label: label,
                currentValueLabel: currentValueLabel
            )
        )
    }
}

// MARK: - ProgressView + Foundation Progress

@available(OpenSwiftUI_v2_0, *)
extension ProgressView {
    /// Creates a progress view for visualizing the given progress instance.
    ///
    /// The progress view synthesizes a default label using the
    /// `localizedDescription` of the given progress instance.
    nonisolated public init(
        _ progress: Foundation.Progress
    ) where Label == EmptyView, CurrentValueLabel == EmptyView {
        base = .observing(FoundationProgressView(progress: progress))
    }
}

// MARK: - ProgressView + Style Configuration

@available(OpenSwiftUI_v2_0, *)
extension ProgressView {
    /// Creates a progress view based on a style configuration.
    ///
    /// You can use this initializer within the
    /// ``ProgressViewStyle/makeBody(configuration:)`` method of a
    /// ``ProgressViewStyle`` to create an instance of the styled progress view.
    /// This is useful for custom progress view styles that only modify the
    /// current progress view style, as opposed to implementing a brand new
    /// style. Because this modifier style can't know how the current style
    /// represents progress, avoid making assumptions about the view's contents,
    /// such as whether it uses bars or other shapes.
    ///
    /// The following example shows a style that adds a rounded pink border to a
    /// progress view, but otherwise preserves the progress view's current
    /// style:
    ///
    ///     struct PinkBorderedProgressViewStyle: ProgressViewStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             ProgressView(configuration)
    ///                 .padding(4)
    ///                 .border(.pink, width: 3)
    ///                 .cornerRadius(4)
    ///         }
    ///     }
    ///
    /// ![Two horizontal progress views, one at 25 percent complete and the
    /// other at 75 percent, each rendered with a rounded pink
    /// border.](ProgressView-4-macOS)
    ///
    /// - Note: Progress views in widgets don't apply custom styles.
    nonisolated public init(
        _ configuration: ProgressViewStyleConfiguration
    ) where Label == ProgressViewStyleConfiguration.Label, CurrentValueLabel == ProgressViewStyleConfiguration.CurrentValueLabel {
        base = .custom(
            CustomProgressView(
                value: configuration.value,
                label: configuration.label,
                currentValueLabel: configuration.currentValueLabel
            )
        )
    }
}

// MARK: - ProgressViewValue

enum ProgressViewValue: Codable {
    case absolute(fractionCompleted: Double?, alwaysIndeterminate: Bool)
    case dateRelative(interval: ClosedRange<Date>, countdown: Bool)

    private enum CodingKeys: CodingKey {
        case absolute
        case dateRelative
    }

    private enum AbsoluteCodingKeys: CodingKey {
        case fractionCompleted
        case alwaysIndeterminate
    }

    private enum DateRelativeCodingKeys: CodingKey {
        case interval
        case countdown
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .absolute(fractionCompleted, alwaysIndeterminate):
            var nestedContainer = container.nestedContainer(
                keyedBy: AbsoluteCodingKeys.self,
                forKey: .absolute
            )
            try nestedContainer.encodeIfPresent(
                fractionCompleted,
                forKey: .fractionCompleted
            )
            try nestedContainer.encode(
                alwaysIndeterminate,
                forKey: .alwaysIndeterminate
            )
        case let .dateRelative(interval, countdown):
            var nestedContainer = container.nestedContainer(
                keyedBy: DateRelativeCodingKeys.self,
                forKey: .dateRelative
            )
            try nestedContainer.encode(interval, forKey: .interval)
            try nestedContainer.encode(countdown, forKey: .countdown)
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = container.allKeys
        guard keys.count == 1 else {
            throw DecodingError.typeMismatch(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one."
                )
            )
        }
        switch keys[0] {
        case .absolute:
            let nestedContainer = try container.nestedContainer(
                keyedBy: AbsoluteCodingKeys.self,
                forKey: .absolute
            )
            self = try .absolute(
                fractionCompleted: nestedContainer.decodeIfPresent(
                    Double.self,
                    forKey: .fractionCompleted
                ),
                alwaysIndeterminate: nestedContainer.decode(
                    Bool.self,
                    forKey: .alwaysIndeterminate
                )
            )
        case .dateRelative:
            let nestedContainer = try container.nestedContainer(
                keyedBy: DateRelativeCodingKeys.self,
                forKey: .dateRelative
            )
            self = try .dateRelative(
                interval: nestedContainer.decode(
                    ClosedRange<Date>.self,
                    forKey: .interval
                ),
                countdown: nestedContainer.decode(
                    Bool.self,
                    forKey: .countdown
                )
            )
        }
    }
}

// MARK: - CustomProgressView

@MainActor
@preconcurrency
struct CustomProgressView<Label, CurrentValueLabel>: PrimitiveView, UnaryView, View where Label: View, CurrentValueLabel: View {
    var value: ProgressViewValue
    var label: Label?
    var currentValueLabel: CurrentValueLabel?

    init(
        value: ProgressViewValue,
        label: Label?,
        currentValueLabel: CurrentValueLabel?
    ) {
        self.value = value
        self.label = label
        self.currentValueLabel = currentValueLabel
    }

    init(
        interval: ClosedRange<Date>,
        countdown: Bool,
        label: Label?,
        currentValueLabel: CurrentValueLabel?
    ) {
        self.value = .dateRelative(interval: interval, countdown: countdown)
        self.label = label
        self.currentValueLabel = currentValueLabel
    }

    init(
        fractionCompleted: Double?,
        alwaysIndeterminate: Bool,
        label: Label?,
        currentValueLabel: CurrentValueLabel?
    ) {
        self.value = .absolute(
            fractionCompleted: fractionCompleted,
            alwaysIndeterminate: alwaysIndeterminate
        )
        self.label = label
        self.currentValueLabel = currentValueLabel
    }

    nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let baseValue = view.value[offset: { .of(&$0.value) }]
        let label = view.value[offset: { .of(&$0.label) }]
        let currentValueLabel = view.value[offset: { .of(&$0.currentValueLabel) }]
        let child = Child(
            baseValue: baseValue,
            label: label,
            currentValueLabel: currentValueLabel
        )
        var outputs = Child.Value._makeView(
            view: _GraphValue(child),
            inputs: inputs
        )
        if inputs.preferences.contains(WidgetAuxiliaryViewMetadata.Key.self) {
            outputs.preferences.platformItemList = nil
            outputs.preferences.makePreferenceWriter(
                inputs: inputs.preferences,
                key: WidgetAuxiliaryViewMetadata.Key.self,
                value: Attribute(
                    WidgetMetadataWriter(
                        baseValue: baseValue,
                        labelPref: Attribute(
                            LazyWidgetAuxiliaryMetadataTextImage(
                                flags: _AttributeType.Flags.self,
                                content: label,
                                inputs: inputs
                            )
                        ),
                        currentValueLabelPref: Attribute(
                            LazyWidgetAuxiliaryMetadataTextImage(
                                flags: _AttributeType.Flags.self,
                                content: currentValueLabel,
                                inputs: inputs
                            )
                        ),
                        environment: inputs.environment
                    )
                )
            )
        }
        return outputs
    }

    private struct WidgetMetadataWriter: Rule {
        @Attribute var baseValue: ProgressViewValue
        @Attribute var labelPref: WidgetAuxiliaryTextImagePreference?
        @Attribute var currentValueLabelPref: WidgetAuxiliaryTextImagePreference?
        @Attribute var environment: EnvironmentValues

        var value: WidgetAuxiliaryViewMetadata? {
            let kind: WidgetAuxiliaryViewMetadata.Progress.Kind = switch baseValue {
            case let .absolute(fractionCompleted, alwaysIndeterminate): .absolute(fractionCompleted, alwaysIndeterminate)
            case let .dateRelative(interval, countdown): .date(interval, countdown)
            }
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
            return WidgetAuxiliaryViewMetadata(
                progress: .init(
                    kind: kind,
                    label: label,
                    currentValueLabel: currentValueLabel,
                    tint: WidgetAuxiliaryViewMetadata.tint(from: environment)
                )
            )
        }
    }

    private struct Child: Rule {
        @Attribute var baseValue: ProgressViewValue
        @Attribute var label: Label?
        @Attribute var currentValueLabel: CurrentValueLabel?

        var value: some View {
            ResolvedProgressView(value: baseValue)
                .optionalViewAlias(ProgressViewStyleConfiguration.CurrentValueLabel.self) {
                    currentValueLabel
                }
                .optionalViewAlias(ProgressViewStyleConfiguration.Label.self) {
                    label
                }
        }
    }
}

// MARK: - ResolvedProgressView

struct ResolvedProgressView: View {
    var value: ProgressViewValue

    @OptionalViewAlias
    var label: ProgressViewStyleConfiguration.Label?

    @OptionalViewAlias
    var currentValueLabel: ProgressViewStyleConfiguration.CurrentValueLabel?

    var body: ResolvedProgressViewStyle {
        ResolvedProgressViewStyle(
            configuration: ProgressViewStyleConfiguration(
                value: value,
                label: label,
                currentValueLabel: currentValueLabel
            )
        )
    }
}
