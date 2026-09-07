//
//  EmbeddedAnimation.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// A bounded, time-based animation for the Embedded renderer.
/// Springs, repeat/delay and desktop animation transactions are not included.
public struct Animation: Equatable, Sendable {
    package let milliseconds: UInt32
    package let eased: Bool
    private init(duration: Double, eased: Bool) {
        precondition(duration.isFinite && duration >= 0 && duration <= 60)
        milliseconds = UInt32(duration * 1000)
        self.eased = eased
    }
    public static var `default`: Animation { .easeOut(duration: 0.25) }
    public static func linear(duration: Double) -> Animation { .init(duration: duration, eased: false) }
    public static func easeOut(duration: Double) -> Animation { .init(duration: duration, eased: true) }
    package func progress(at time: UInt32) -> Int32 {
        guard milliseconds > 0 && time < milliseconds else { return 1024 }
        let t = Int32(UInt64(time) * 1024 / UInt64(milliseconds))
        let remaining = 1024 - t
        return eased ? 1024 - remaining * remaining * remaining / 1048576 : t
    }
}

package enum EmbeddedAnimationTransaction {
    nonisolated(unsafe) static var current: Animation?
}

/// State writes in this synchronous scope use the specified animation.
/// The platform must serialize all hosts and drive their animation clocks.
/// Multiple writes before rendering coalesce; the last write selects animation.
public func withAnimation<Result, Failure: Error>(_ animation: Animation? = .default, _ body: () throws(Failure) -> Result) throws(Failure) -> Result {
    let previous = EmbeddedAnimationTransaction.current
    EmbeddedAnimationTransaction.current = animation
    defer { EmbeddedAnimationTransaction.current = previous }
    return try body()
}
#endif
