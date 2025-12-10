//
//  SensoryFeedback.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

/// Represents a type of haptic and/or audio feedback that can be played.
///
/// This feedback can be passed to `View.sensoryFeedback` to play it.
@available(OpenSwiftUI_v5_0, *)
@available(visionOS, unavailable)
public struct SensoryFeedback: Equatable, Sendable {
    enum FeedbackType: Hashable {
        case success
        case warning
        case error
        case increase
        case decrease
        case selection
        case alignment
        case levelChange
        case start
        case stop
        case pathComplete
        case impactWeight(SensoryFeedback.Weight.Storage, Double)
        case impactFlexibility(SensoryFeedback.Flexibility.Storage, Double)
    }

    var type: FeedbackType

    /// Indicates that a task or action has completed.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static let success: SensoryFeedback = .init(type: .success)

    /// Indicates that a task or action has produced a warning of some kind.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static let warning: SensoryFeedback = .init(type: .warning)

    /// Indicates that an error has occurred.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static let error: SensoryFeedback = .init(type: .error)

    /// Indicates that a UI element’s values are changing.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static let selection: SensoryFeedback = .init(type: .selection)

    /// Indicates that an important value increased above a significant
    /// threshold.
    ///
    /// Only plays feedback on watchOS.
    public static let increase: SensoryFeedback = .init(type: .increase)

    /// Indicates that an important value decreased below a significant
    /// threshold.
    ///
    /// Only plays feedback on watchOS.
    public static let decrease: SensoryFeedback = .init(type: .decrease)

    /// Indicates that an activity started.
    ///
    /// Use this haptic when starting a timer or any other activity that can be
    /// explicitly started and stopped.
    ///
    /// Only plays feedback on watchOS.
    public static let start: SensoryFeedback = .init(type: .start)

    /// Indicates that an activity stopped.
    ///
    /// Use this haptic when stopping a timer or other activity that was
    /// previously started.
    ///
    /// Only plays feedback on watchOS.
    public static let stop: SensoryFeedback = .init(type: .stop)

    /// Indicates the alignment of a dragged item.
    ///
    /// For example, use this pattern in a drawing app when the user drags a
    /// shape into alignment with another shape.
    ///
    /// Only plays feedback on iOS and macOS.
    public static let alignment: SensoryFeedback = .init(type: .alignment)

    /// Indicates movement between discrete levels of pressure.
    ///
    /// For example, as the user presses a fast-forward button on a video
    /// player, playback could increase or decrease and haptic feedback could be
    /// provided as different levels of pressure are reached.
    ///
    /// Only plays feedback on macOS.
    public static let levelChange: SensoryFeedback = .init(type: .levelChange)

    /// Indicates a drawn path has completed and/or recognized.
    ///
    /// Use this to provide feedback for closed shape drawing or similar
    /// actions. It should supplement the user experience, since only some
    /// platforms will play feedback in response to it.
    ///
    /// Only plays feedback on iOS.
    @available(OpenSwiftUI_v5_5, *)
    public static let pathComplete: SensoryFeedback = .init(type: .pathComplete)

    /// Provides a physical metaphor you can use to complement a visual
    /// experience.
    ///
    /// Use this to provide feedback for UI elements colliding. It should
    /// supplement the user experience, since only some platforms will play
    /// feedback in response to it.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static let impact: SensoryFeedback = .init(type: .impactWeight(.light, 1.0))

    /// Provides a physical metaphor you can use to complement a visual
    /// experience.
    ///
    /// Use this to provide feedback for UI elements colliding. It should
    /// supplement the user experience, since only some platforms will play
    /// feedback in response to it.
    ///
    /// Not all platforms will play different feedback for different weights and
    /// intensities of impact.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static func impact(weight: SensoryFeedback.Weight, intensity: Double = 1.0) -> SensoryFeedback {
        .init(type: .impactWeight(weight.storage, intensity))
    }

    /// Provides a physical metaphor you can use to complement a visual
    /// experience.
    ///
    /// Use this to provide feedback for UI elements colliding. It should
    /// supplement the user experience, since only some platforms will play
    /// feedback in response to it.
    ///
    /// Not all platforms will play different feedback for different
    /// flexibilities and intensities of impact.
    ///
    /// Only plays feedback on iOS and watchOS.
    public static func impact(flexibility: SensoryFeedback.Flexibility, intensity: Double = 1.0) -> SensoryFeedback {
        .init(type: .impactFlexibility(flexibility.storage, intensity))
    }

    // MARK: - SensoryFeedback.Weight

    /// The weight to be represented by a type of feedback.
    ///
    /// `Weight` values can be passed to
    /// `SensoryFeedback.impact(weight:intensity:)`.
    public struct Weight: Equatable, Sendable {
        enum Storage: Hashable {
            case light
            case medium
            case heavy
        }

        var storage: Storage

        /// Indicates a collision between small or lightweight UI objects.
        public static let light: SensoryFeedback.Weight = .init(storage: .light)

        /// Indicates a collision between medium-sized or medium-weight UI
        /// objects.
        public static let medium: SensoryFeedback.Weight = .init(storage: .medium)

        /// Indicates a collision between large or heavyweight UI objects.
        public static let heavy: SensoryFeedback.Weight = .init(storage: .heavy)
    }

    // MARK: - SensoryFeedback.Flexibility

    /// The flexibility to be represented by a type of feedback.
    ///
    /// `Flexibility` values can be passed to
    /// `SensoryFeedback.impact(flexibility:intensity:)`.
    public struct Flexibility: Equatable, Sendable {
        enum Storage: Hashable {
            case rigid
            case solid
            case soft
        }
        var storage: Storage

        /// Indicates a collision between hard or inflexible UI objects.
        public static let rigid: SensoryFeedback.Flexibility = .init(storage: .rigid)

        /// Indicates a collision between solid UI objects of medium
        /// flexibility.
        public static let solid: SensoryFeedback.Flexibility = .init(storage: .solid)

        /// Indicates a collision between soft or flexible UI objects.
        public static let soft: SensoryFeedback.Flexibility = .init(storage: .soft)
    }
}
