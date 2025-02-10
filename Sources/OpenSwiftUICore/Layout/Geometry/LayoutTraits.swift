//
//  LayoutTraits.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 950FC9541E969A331FB3CF1283EA4AEC (SwiftUICore)

package import Foundation

/// A description of the sizing behavior of a view.
public struct _LayoutTraits: Equatable {
    package struct FlexibilityEstimate: Comparable {
        let minLength: CGFloat
        let maxLength: CGFloat

        package init(minLength: CGFloat, maxLength: CGFloat) {
            self.minLength = minLength
            self.maxLength = maxLength
        }

        package static func < (l: _LayoutTraits.FlexibilityEstimate, r: _LayoutTraits.FlexibilityEstimate) -> Bool {
            let lDiff = l.maxLength - l.minLength
            let rDiff = r.maxLength - r.minLength

            let lEffectiveMin = lDiff == .infinity ? -l.minLength : 0
            let rEffectiveMin = rDiff == .infinity ? -r.minLength : 0

            if lDiff == rDiff {
                return lEffectiveMin < rEffectiveMin
            } else {
                return lDiff < rDiff
            }
        }
    }

    package struct Dimension : Equatable {
        package var min: CGFloat {
            didSet { _checkInvariant() }
        }

        package var ideal: CGFloat {
            didSet { _checkInvariant() }
        }

        package var max: CGFloat {
            didSet { _checkInvariant() }
        }

        package init(min: CGFloat, ideal: CGFloat, max: CGFloat) {
            self.min = min
            self.ideal = ideal
            self.max = max
            _checkInvariant()
        }

        package static func fixed(_ d: CGFloat) -> Dimension {
            Dimension(min: d, ideal: d, max: d)
        }

        private func _checkInvariant() {
            guard min >= 0,
                  min.isFinite,
                  ideal < .infinity,
                  min <= ideal,
                  ideal <= max
            else {
                preconditionFailure("malformed dimension \(self)")
            }
        }
    }

    package var width = Dimension(min: .zero, ideal: .zero, max: .infinity)

    package var height = Dimension(min: .zero, ideal: .zero, max: .infinity)

    package init() {}

    package init(width: Dimension, height: Dimension) {
        self.width = width
        self.height = height
    }

    package subscript(axis: Axis) -> Dimension {
        get { axis == .horizontal ? width : height }
        set { if axis == .horizontal { width = newValue } else { height = newValue } }
    }
}

@available(*, unavailable)
extension _LayoutTraits: Sendable {}

extension _LayoutTraits {
    package init(width: CGFloat, height: CGFloat) {
        self.width = .fixed(width)
        self.height = .fixed(height)
    }

    package init(_ size: CGSize) {
        self.init(width: size.width, height: size.height)
    }
}

extension _LayoutTraits: CustomStringConvertible {
    public var description: String {
        "(\(width), \(height)"
    }
}

extension _LayoutTraits.Dimension: CustomStringConvertible {
    package var description: String {
        if min == max {
            "\(min)"
        } else {
            "\(min)...\(ideal)...\(max)"
        }
    }
}

extension _LayoutTraits {
    package var idealSize: CGSize {
        get {
            CGSize(width: width.ideal, height: height.ideal)
        }
        set {
            width.ideal = newValue.width
            height.ideal = newValue.height
        }
    }

    package var minSize: CGSize {
        get {
            CGSize(width: width.min, height: height.min)
        }
        set {
            width.min = newValue.width
            height.min = newValue.height
        }
    }

    package var maxSize: CGSize {
        get {
            CGSize(width: width.max, height: height.max)
        }
        set {
            width.max = newValue.width
            height.max = newValue.height
        }
    }
}

extension CGSize {
    package func clamped(to constraints: _LayoutTraits) -> CGSize {
        CGSize(
            width: width.clamp(min: constraints.width.min, max: constraints.width.max),
            height: height.clamp(min: constraints.height.min, max: constraints.height.max)
        )
    }
}
