//
//  AccessibilityDirectTouch.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore
import OpenSwiftUI_SPI

// MARK: - AccessibilityDirectTouchOptions

/// An option set that defines the functionality of a view's direct touch area.
@available(OpenSwiftUI_v5_0, *)
public struct AccessibilityDirectTouchOptions: OptionSet, Sendable {
    public let rawValue: UInt

    /// Create a set of direct touch options
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Allows a direct touch area to immediately receive touch events without
    /// an assistive technology, such as VoiceOver, speaking. Appropriate for
    /// apps that provide direct audio feedback on touch that would conflict
    /// with speech feedback.
    public static let silentOnTouch = AccessibilityDirectTouchOptions(rawValue: 1 << 0)

    /// Prevents touch passthrough with the direct touch area until an
    /// assistive technology, such as VoiceOver, has activated the direct
    /// touch area through a user action, for example a double tap.
    public static let requiresActivation = AccessibilityDirectTouchOptions(rawValue: 1 << 1)
}

// MARK: - View + AccessibilityDirectTouch

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Explicitly set whether this accessibility element is a direct touch
    /// area. Direct touch areas passthrough touch events to the app rather
    /// than being handled through an assistive technology, such as VoiceOver.
    /// The modifier accepts an optional `AccessibilityDirectTouchOptions`
    /// option set to customize the functionality of the direct touch area.
    ///
    /// For example, this is how a direct touch area would allow a VoiceOver
    /// user to interact with a view with a `rotationEffect` controlled by a
    /// `RotationGesture`. The direct touch area would require a user to
    /// activate the area before using the direct touch area.
    ///
    ///     var body: some View {
    ///         Rectangle()
    ///             .frame(width: 200, height: 200, alignment: .center)
    ///             .rotationEffect(angle)
    ///             .gesture(rotation)
    ///             .accessibilityDirectTouch(options: .requiresActivation)
    ///     }
    ///
    nonisolated public func accessibilityDirectTouch(
        _ isDirectTouchArea: Bool = true,
        options: AccessibilityDirectTouchOptions = []
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibility(
            AccessibilityProperties.TouchInfoKey.self,
            AccessibilityTouchInfo(isDirectTouchArea: isDirectTouchArea, options: options)
        )
    }
}

@available(OpenSwiftUI_v5_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    /// Explicitly set whether this accessibility element is a direct touch
    /// area. Direct touch areas passthrough touch events to the app rather
    /// than being handled through an assistive technology, such as VoiceOver.
    /// The modifier accepts an optional `AccessibilityDirectTouchOptions`
    /// option set to customize the functionality of the direct touch area.
    ///
    /// For example, this is how a direct touch area would allow a VoiceOver
    /// user to interact with a view with a `rotationEffect` controlled by a
    /// `RotationGesture`. The direct touch area would require a user to
    /// activate the area before using the direct touch area.
    ///
    ///     var body: some View {
    ///         Rectangle()
    ///             .frame(width: 200, height: 200, alignment: .center)
    ///             .rotationEffect(angle)
    ///             .gesture(rotation)
    ///             .accessibilityDirectTouch(options: .requiresActivation)
    ///     }
    ///
    nonisolated public func accessibilityDirectTouch(
        _ isDirectTouchArea: Bool = true,
        options: AccessibilityDirectTouchOptions = []
    ) -> ModifiedContent<Content, Modifier> {
        update(
            AccessibilityProperties.TouchInfoKey.self,
            replacing: AccessibilityTouchInfo(isDirectTouchArea: isDirectTouchArea, options: options)
        )
    }
}

// MARK: - AccessibilityTouchInfo

struct AccessibilityTouchInfo: Equatable {
    var isDirectTouchArea: Bool
    var options: AccessibilityDirectTouchOptions
}

extension AccessibilityTouchInfo: AccessibilityTraitResolver {
    func resolve(into traits: inout AXOpenSwiftUITraits, for storage: AccessibilityTraitStorage) {
        if isDirectTouchArea, storage[.allowsDirectInteraction] != false {
            traits = AXOpenSwiftUITraits(
                rawValue: traits.rawValue | AXOpenSwiftUITraits.allowsDirectInteraction.rawValue
            )
        }
    }
}
