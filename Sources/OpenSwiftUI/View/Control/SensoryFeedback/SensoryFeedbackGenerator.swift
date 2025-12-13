//
//  SensoryFeedbackGenerator.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E5C2FE5C277CCA85C518490456542950 (SwiftUI)

// MARK: - View + senosryFeedback

@available(OpenSwiftUI_v5_0, *)
@available(visionOS, unavailable)
extension View {

    /// Plays the specified `feedback` when the provided `trigger` value
    /// changes.
    ///
    /// For example, you could play feedback when a state value changes:
    ///
    ///     struct MyView: View {
    ///         @State private var showAccessory = false
    ///
    ///         var body: some View {
    ///             ContentView()
    ///                 .sensoryFeedback(.selection, trigger: showAccessory)
    ///                 .onLongPressGesture {
    ///                     showAccessory.toggle()
    ///                 }
    ///
    ///             if showAccessory {
    ///                 AccessoryView()
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - feedback: Which type of feedback to play.
    ///   - trigger: A value to monitor for changes to determine when to play.
    nonisolated public func sensoryFeedback<T>(
        _ feedback: SensoryFeedback,
        trigger: T
    ) -> some View where T: Equatable {
        platformSensoryFeedback(
            FeedbackGenerator(
                feedbackRequestContext: .init(),
                feedback: feedback,
                trigger: trigger,
                condition: nil,
                implementation: nil
            )
        )
    }

    /// Plays the specified `feedback` when the provided `trigger` value changes
    /// and the `condition` closure returns `true`.
    ///
    /// For example, you could play feedback for certain state transitions:
    ///
    ///     struct MyView: View {
    ///         @State private var phase = Phase.inactive
    ///
    ///         var body: some View {
    ///             ContentView(phase: $phase)
    ///                 .sensoryFeedback(.selection, trigger: phase) { old, new in
    ///                     old == .inactive || new == .expanded
    ///                 }
    ///         }
    ///
    ///         enum Phase {
    ///             case inactive
    ///             case preparing
    ///             case active
    ///             case expanded
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - feedback: Which type of feedback to play.
    ///   - trigger: A value to monitor for changes to determine when to play.
    ///   - condition: A closure to determine whether to play the feedback when
    ///     `trigger` changes.
    nonisolated public func sensoryFeedback<T>(
        _ feedback: SensoryFeedback,
        trigger: T,
        condition: @escaping (_ oldValue: T, _ newValue: T) -> Bool
    ) -> some View where T: Equatable {
        platformSensoryFeedback(
            FeedbackGenerator(
                feedbackRequestContext: .init(),
                feedback: feedback,
                trigger: trigger,
                condition: condition,
                implementation: nil
            )
        )
    }

    /// Plays feedback when returned from the `feedback` closure after the
    /// provided `trigger` value changes.
    ///
    /// For example, you could play different feedback for different state
    /// transitions:
    ///
    ///     struct MyView: View {
    ///         @State private var phase = Phase.inactive
    ///
    ///         var body: some View {
    ///             ContentView(phase: $phase)
    ///                 .sensoryFeedback(trigger: phase) { old, new in
    ///                     switch (old, new) {
    ///                         case (.inactive, _): return .success
    ///                         case (_, .expanded): return .impact
    ///                         default: return nil
    ///                     }
    ///                 }
    ///         }
    ///
    ///         enum Phase {
    ///             case inactive
    ///             case preparing
    ///             case active
    ///             case expanded
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - trigger: A value to monitor for changes to determine when to play.
    ///   - feedback: A closure to determine whether to play the feedback and
    ///     what type of feedback to play when `trigger` changes.
    nonisolated public func sensoryFeedback<T>(
        trigger: T,
        _ feedback: @escaping (_ oldValue: T, _ newValue: T) -> SensoryFeedback?
    ) -> some View where T: Equatable {
        platformSensoryFeedback(
            CustomFeedbackGenerator(
                feedbackRequestContext: .init(),
                trigger: trigger,
                feedback: feedback
            )
        )
    }
}

// MARK: - SensoryFeedbackGeneratorModifier

protocol SensoryFeedbackGeneratorModifier: ViewModifier {
    var feedbackRequestContext: FeedbackRequestContext { get set }
}

// MARK: - CustomFeedbackGenerator

private struct CustomFeedbackGenerator<T>: SensoryFeedbackGeneratorModifier where T: Equatable {
    var feedbackRequestContext: FeedbackRequestContext
    var trigger: T
    var feedback: (T, T) -> SensoryFeedback?
    @State var state: (feedback: SensoryFeedback, implementation: (any PlatformSensoryFeedback)?)?

    init(
        feedbackRequestContext: FeedbackRequestContext,
        trigger: T,
        feedback: @escaping (T, T) -> SensoryFeedback?
    ) {
        self.feedbackRequestContext = feedbackRequestContext
        self.trigger = trigger
        self.feedback = feedback
        self._state = State(wrappedValue: nil)
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { oldValue, newValue in
                let newFeedback = feedback(oldValue, newValue)
                if state?.feedback != newFeedback {
                    state?.implementation?.tearDown()
                    let newValue: (SensoryFeedback, (any PlatformSensoryFeedback)?)?
                    if let newFeedback {
                        newValue = (
                            newFeedback,
                            feedbackRequestContext.implementation(type: newFeedback.type)
                        )
                    } else {
                        newValue = nil
                    }
                    state = newValue
                    state?.implementation?.setUp()
                }
                state?.implementation?.generate()
            }
    }
}

// MARK: - FeedbackGenerator

private struct FeedbackGenerator<T>: SensoryFeedbackGeneratorModifier where T: Equatable {
    var feedbackRequestContext: FeedbackRequestContext
    var feedback: SensoryFeedback
    var trigger: T
    var condition: ((T, T) -> Bool)?
    @State var implementation: (any PlatformSensoryFeedback)?

    init(
        feedbackRequestContext: FeedbackRequestContext,
        feedback: SensoryFeedback,
        trigger: T,
        condition: ((T, T) -> Bool)?,
        implementation: (any PlatformSensoryFeedback)?
    ) {
        self.feedbackRequestContext = feedbackRequestContext
        self.feedback = feedback
        self.trigger = trigger
        self.condition = condition
        self._implementation = .init(initialValue: implementation)
    }

    func body(content: Content) -> some View {
        content
            .task(id: feedback) {
                implementation?.tearDown()
                implementation = feedbackRequestContext.implementation(type: feedback.type)
                implementation?.setUp()
            }
            .onChange(of: trigger) { oldValue, newValue in
                if condition?(oldValue, newValue) ?? true {
                    implementation?.generate()
                }
            }
    }
}

#if !canImport(Darwin)
// MARK: - View + platformSensoryFeedback

extension View {
    nonisolated func platformSensoryFeedback<Base>(
        _ base: Base
    ) -> some View where Base: SensoryFeedbackGeneratorModifier {
        modifier(base)
    }
}

// MARK: - FeedbackRequestContext

struct FeedbackRequestContext {
    func implementation(type: SensoryFeedback.FeedbackType) -> (any PlatformSensoryFeedback)? {
        nil
    }
}
#endif
