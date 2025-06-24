//
//  GestureMask.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - GestureMask [6.5.4]

/// Options that control how adding a gesture to a view affects other gestures
/// recognized by the view and its subviews.
@frozen
@available(OpenSwiftUI_v1_0, *)
public struct GestureMask: OptionSet {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Disable all gestures in the subview hierarchy, including the added
    /// gesture.
    public static let none: GestureMask = .init(rawValue: 0)

    /// Enable the added gesture but disable all gestures in the subview
    /// hierarchy.
    public static let gesture: GestureMask = .init(rawValue: 1 << 0)

    /// Enable all gestures in the subview hierarchy but disable the added
    /// gesture.
    public static let subviews: GestureMask = .init(rawValue: 1 << 1)

    /// Enable both the added gesture as well as all other gestures on the view
    /// and its subviews.
    public static let all: GestureMask = [.gesture, .subviews]
}
