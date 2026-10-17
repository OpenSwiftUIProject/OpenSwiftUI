//
//  EventDirections.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
import OpenSwiftUICore

// MARK: - _EventDirections

/// A set of directions in which an event, such as a drag or a scroll, can
/// move.
///
/// Gestures and scroll views use this set to limit an interaction to some
/// directions. For example, a gesture that uses ``horizontal`` responds only
/// to movement that is mostly left or right.
@available(OpenSwiftUI_v1_0, *)
public struct _EventDirections: OptionSet {
    public let rawValue: Int8

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    /// The left direction.
    public static let left = _EventDirections(rawValue: 1 << 0)

    /// The right direction.
    public static let right = _EventDirections(rawValue: 1 << 1)

    /// The up direction.
    public static let up = _EventDirections(rawValue: 1 << 2)

    /// The down direction.
    public static let down = _EventDirections(rawValue: 1 << 3)

    /// The left and right directions.
    public static let horizontal: _EventDirections = [.left, .right]

    /// The up and down directions.
    public static let vertical: _EventDirections = [.up, .down]

    /// All directions.
    public static let all: _EventDirections = [.horizontal, .vertical]
}

@available(*, unavailable)
extension _EventDirections: Sendable {}

// MARK: - CGSize + withinRange

extension CGSize {
    /// Returns a Boolean value that indicates whether this size points in one
    /// of the directions in `axes`.
    ///
    /// The size points in a direction when the cosine of the angle between
    /// them is greater than `rangeCosine`. The result is always `true` when
    /// `axes` is ``_EventDirections/all``.
    func withinRange(axes: _EventDirections, rangeCosine: CGFloat) -> Bool {
        guard axes != .all else {
            return true
        }
        let direction = normalized()
        if axes.contains(.left), -direction.width > rangeCosine {
            return true
        }
        if axes.contains(.right), direction.width > rangeCosine {
            return true
        }
        if axes.contains(.up), -direction.height > rangeCosine {
            return true
        }
        return axes.contains(.down) && direction.height > rangeCosine
    }
}
