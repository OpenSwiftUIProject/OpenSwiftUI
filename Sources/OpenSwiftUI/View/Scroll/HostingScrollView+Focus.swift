//
//  HostingScrollView+Focus.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 60C465D0E37117769FC505C04DE5239A (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// TODO: Connect the container's focus queries, filler management, and substitution.

// MARK: - UIKitProxyFocusItem

protocol UIKitProxyFocusItem: UIFocusItem {
    var axis: Axis { get }
    var logicalFrame: CGRect { get set }
    var focusableFrame: CGRect? { get set }
}

// MARK: - UIKitFocusableFillerItem

private class UIKitFocusableFillerItem: UIKitFocusableViewResponderItemBase, UIKitProxyFocusItem {
    weak var host: UIView?
    let axis: Axis
    var logicalFrame: CGRect = .zero
    var focusableFrame: CGRect?

    init(host: UIView, axis: Axis) {
        self.host = host
        self.axis = axis
        super.init()
    }

    var frame: CGRect { focusableFrame ?? logicalFrame }

    var canBecomeFocused: Bool { true }

    var preferredFocusEnvironments: [any UIFocusEnvironment] { [] }

    var parentFocusEnvironment: (any UIFocusEnvironment)? { host }

    var focusItemContainer: (any UIFocusItemContainer)? { nil }

    func setNeedsFocusUpdate() {
        _openSwiftUIEmptyStub()
    }

    func updateFocusIfNeeded() {
        _openSwiftUIEmptyStub()
    }

    func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool { true }

    func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Log.focus?.log("focus changed for: \(UIKitFocusItemDescription(self))")
    }
}

// MARK: - FocusableBorder

struct FocusableBorder: Equatable {
    var bounds: CGRect
    var depth: EdgeInsets
}

// MARK: - FocusableFillerBounds

struct FocusableFillerBounds {
    var bounds: CGRect
    var horizontalMetrics: Metrics?
    var verticalMetrics: Metrics?

    func fillerFrames(in rect: CGRect) -> [CGRect] {
        func ranges(_ axis: Axis) -> [ClosedRange<CGFloat>] {
            let boundsRange = bounds.range(in: axis)
            let rectRange = rect.range(in: axis)
            let lowerBound = max(boundsRange.lowerBound, rectRange.lowerBound)
            let upperBound = min(rectRange.upperBound, boundsRange.upperBound)
            let length = upperBound - lowerBound
            if length <= 0 {
                return []
            }
            let metrics = axis == .horizontal ? horizontalMetrics : verticalMetrics
            let size = metrics?.size ?? length
            let spacing = metrics?.spacing ?? 0
            let count = floor((length + spacing) / (size + spacing))
            let adjustedSpacing = count > 1 ? (length - size * count) / (count - 1) : 0
            return (0..<Int(count)).map { index in
                let lower = lowerBound + (size + adjustedSpacing) * CGFloat(index)
                return lower...(lower + size)
            }
        }

        let horizontalRanges = ranges(.horizontal)
        let verticalRanges = ranges(.vertical)
        var frames: [CGRect] = []
        for horizontalRange in horizontalRanges {
            for verticalRange in verticalRanges {
                frames.append(CGRect(
                    x: horizontalRange.lowerBound,
                    y: verticalRange.lowerBound,
                    width: horizontalRange.length,
                    height: verticalRange.length
                ))
            }
        }
        return frames
    }
}

// MARK: - FocusableBounds

struct FocusableBounds {
    var bounds: CGRect
    var isLazyContainer: Bool
}

// MARK: - HostingScrollView.PlatformGroupContainer.SubstitutionCandidate

extension HostingScrollView.PlatformGroupContainer {
    private struct SubstitutionCandidate {
        var focusItem: any UIFocusItem
        var range: ClosedRange<CGFloat>
        var otherRange: ClosedRange<CGFloat>
    }
}

// MARK: - FocusableBoundsTransform

struct FocusableBoundsTransform: Rule {
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    var isLazyContainer: Bool

    var value: [FocusableBounds] {
        var transform = self.transform
        transform.appendPosition(position)
        var bounds = CGRect(origin: .zero, size: size.value)
        bounds.convert(to: .scrollViewContent, transform: transform)
        return [FocusableBounds(bounds: bounds, isLazyContainer: isLazyContainer)]
    }
}

// MARK: - FocusableBounds.Key

extension FocusableBounds {
    struct Key: PreferenceKey {
        static let defaultValue: [FocusableBounds] = []

        static func reduce(value: inout [FocusableBounds], nextValue: () -> [FocusableBounds]) {
            value.append(contentsOf: nextValue())
        }
    }
}

// MARK: - FocusableFillerBounds.Key

extension FocusableFillerBounds {
    struct Key: PreferenceKey {
        static let defaultValue: [FocusableFillerBounds] = []

        static func reduce(value: inout [FocusableFillerBounds], nextValue: () -> [FocusableFillerBounds]) {
            value.append(contentsOf: nextValue())
        }
    }
}

// MARK: - FocusableFillerBounds.Metrics

extension FocusableFillerBounds {
    struct Metrics {
        var size: CGFloat
        var spacing: CGFloat
        var lowerInset: CGFloat
        var upperInset: CGFloat
    }
}

// MARK: - HostingScrollView.PlatformGroupContainer.SubstitutionStrategy

extension HostingScrollView.PlatformGroupContainer {
    private struct SubstitutionStrategy {
        var axis: Axis
        var range: ClosedRange<CGFloat>
        var visibleRange: ClosedRange<CGFloat>
        var otherRange: ClosedRange<CGFloat>
        var guideOffset: CGFloat
        var sortOrder: SortOrder

        var searchRect: CGRect {
            let searchRange: ClosedRange<CGFloat>
            switch sortOrder {
            case .lowerBound:
                searchRange = min(visibleRange.lowerBound, range.lowerBound)...range.upperBound
            case .upperBound:
                searchRange = range.lowerBound...max(range.upperBound, visibleRange.upperBound)
            }
            return CGRect(
                origin: CGPoint(searchRange.lowerBound, in: axis, by: otherRange.lowerBound),
                size: CGSize(searchRange.length, in: axis, by: otherRange.length)
            )
        }

        enum SortOrder: Hashable {
            case lowerBound
            case upperBound
        }
    }
}

// MARK: - CGRect + Focus

extension CGRect {
    func range(in axis: Axis) -> ClosedRange<CGFloat> {
        guard isFinite else {
            Log.internalError("Invalid rect in CGRect.range(in:): \(loggable)")
            return 0...0
        }
        let lowerBound = origin[axis]
        return lowerBound...(lowerBound + max(size[axis], 0))
    }
}
#endif
