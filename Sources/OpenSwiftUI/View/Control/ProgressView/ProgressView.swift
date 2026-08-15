//
//  ProgressView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 936A47782A7E2FBE97D58CDBAEB02770 (SwiftUI)

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
import OpenCombineFoundation
#else
import Combine
#endif
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
