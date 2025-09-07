//
//  TransitionProperties.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// The properties a `Transition` can have.
///
/// A transition can have properties that specify high level information about
/// it. This can determine how a transition interacts with other features like
/// Accessibility settings.
///
/// - See Also: `Transition`
@available(OpenSwiftUI_v5_0, *)
public struct TransitionProperties: Sendable {
    /// Whether the transition includes motion.
    ///
    /// When this behavior is included in a transition, that transition will be
    /// replaced by opacity when Reduce Motion is enabled.
    ///
    /// Defaults to `true`.
    public var hasMotion: Bool
    
    public init(hasMotion: Bool = true) {
        self.hasMotion = hasMotion
    }
    
    package func union(_ other: TransitionProperties) -> TransitionProperties {
        TransitionProperties(hasMotion: hasMotion || other.hasMotion)
    }
}

