//
//  Spacer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 81D5572A9475F8358655E25B09BAFBA9 (SwiftUICore)

public import Foundation
import OpenAttributeGraphShims

// MARK: - Spacer

/// A flexible space that expands along the major axis of its containing stack
/// layout, or on both axes if not contained in a stack.
///
/// A spacer creates an adaptive view with no content that expands as much as
/// it can. For example, when placed within an ``HStack``, a spacer expands
/// horizontally as much as the stack allows, moving sibling views out of the
/// way, within the limits of the stack's size.
/// OpenSwiftUI sizes a stack that doesn't contain a spacer up to the combined
/// ideal widths of the content of the stack's child views.
///
/// The following example provides a simple checklist row to illustrate how you
/// can use a spacer:
///
///     struct ChecklistRow: View {
///         let name: String
///
///         var body: some View {
///             HStack {
///                 Image(systemName: "checkmark")
///                 Text(name)
///             }
///             .border(Color.blue)
///         }
///     }
///
/// ![A figure of a blue rectangular border that marks the boundary of an
/// HStack, wrapping a checkmark image to the left of the name Megan. The
/// checkmark and name are centered vertically and separated by system
/// standard-spacing within the stack.](Spacer-1.png)
///
/// Adding a spacer before the image creates an adaptive view with no content
/// that expands to push the image and text to the right side of the stack.
/// The stack also now expands to take as much space as the parent view allows,
/// shown by the blue border that indicates the boundary of the stack:
///
///     struct ChecklistRow: View {
///         let name: String
///
///         var body: some View {
///             HStack {
///                 Spacer()
///                 Image(systemName: "checkmark")
///                 Text(name)
///             }
///             .border(Color.blue)
///         }
///     }
///
/// ![A figure of a blue rectangular border that marks the boundary of an
/// HStack, wrapping a checkmark image to the left of the name Megan. The
/// checkmark and name are centered vertically, separated by system-standard
/// spacing, and pushed to the right side of the stack.](Spacer-2.png)
///
/// Moving the spacer between the image and the name pushes those elements to
/// the left and right sides of the ``HStack``, respectively. Because the stack
/// contains the spacer, it expands to take as much horizontal space as the
/// parent view allows; the blue border indicates its size:
///
///     struct ChecklistRow: View {
///         let name: String
///
///         var body: some View {
///             HStack {
///                 Image(systemName: "checkmark")
///                 Spacer()
///                 Text(name)
///             }
///             .border(Color.blue)
///         }
///     }
///
/// ![A figure of a blue rectangular border that marks the boundary of an
/// HStack, wrapping a checkmark image to the left of the name Megan. The
/// checkmark and name are centered vertically, with the checkmark on the
/// left edge of the stack, and the text on the right side of the
/// stack.](Spacer-3.png)
///
/// Adding two spacer views on the outside of the stack leaves the image and
/// text together, while the stack expands to take as much horizontal space
/// as the parent view allows:
///
///     struct ChecklistRow: View {
///         let name: String
///
///         var body: some View {
///             HStack {
///                 Spacer()
///                 Image(systemName: "checkmark")
///                 Text(name)
///                 Spacer()
///             }
///             .border(Color.blue)
///         }
///     }
///
/// ![A figure of a blue rectangular border marks the boundary of an HStack,
/// wrapping a checkmark image to the left of text spelling the name Megan.
/// The checkmark and name are centered vertically, separated by
/// system-standard spacing, and centered horizontally
/// in the stack.](Spacer-4.png)
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Spacer: PrimitiveSpacer {
    /// The minimum length this spacer can be shrunk to, along the axis or axes
    /// of expansion.
    ///
    /// If `nil`, the system default spacing between views is used.
    public var minLength: CGFloat?
    
    @inlinable
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
}

/// A flexible space that expands along the major axis of its containing stack
/// layout, or on both axes if not contained in a stack. In a vertical stack
/// this spacer will adjust based on the first and last baseline of adjacent
/// `Text`.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct _TextBaselineRelativeSpacer: PrimitiveSpacer {
    public var minLength: CGFloat?

    @inlinable
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }

    static var requireTextBaselineSpacing: Bool { true }
}

/// A horizontally flexible space.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _HSpacer: PrimitiveSpacer {
    public var minWidth: CGFloat?

    @inlinable
    public init(minWidth: CGFloat? = nil) {
        self.minWidth = minWidth
    }

    var minLength: CGFloat? { minWidth }

    static var axis: Axis? { .horizontal }
}

/// A vertically flexible space.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _VSpacer: PrimitiveSpacer {
    public var minHeight: CGFloat?

    @inlinable
    public init(minHeight: CGFloat? = nil) {
        self.minHeight = minHeight
    }

    var minLength: CGFloat? { minHeight }

    static var axis: Axis? { .vertical }
}

// MARK: - SpacerLayoutComputer

private struct SpacerLayoutComputer<S>: StatefulRule where S: PrimitiveSpacer {
    @Attribute var spacer: S
    var orientation: Axis?
    @OptionalAttribute var dynamicOrientation: Axis??
    var platform: Platform

    typealias Value = LayoutComputer

    mutating func updateValue() {
        update(
            to: Engine(
                spacer: spacer,
                orientation: orientation ?? dynamicOrientation ?? nil,
                platform: platform
            )
        )
    }

    struct Engine: LayoutEngine {
        let spacer: S
        let orientation: Axis?
        var platform: Platform

        func layoutPriority() -> Double {
            -.infinity
        }

        func requiresSpacingProjection() -> Bool {
            true
        }

        func spacing() -> Spacing {
            if S.requireTextBaselineSpacing {
                guard let orientation else {
                    return .zero
                }
                if orientation == .horizontal {
                    return .init(minima: [
                        .init(category: .leftTextBaseline, edge: .left): .distance(0),
                        .init(category: .rightTextBaseline, edge: .right): .distance(0),
                        .init(category: nil, edge: .left): .distance(0),
                        .init(category: nil, edge: .right): .distance(0),
                    ])
                } else {
                    return .init(minima: [
                        .init(category: .textBaseline, edge: .top): .distance(0),
                        .init(category: .textBaseline, edge: .bottom): .distance(0),
                        .init(category: nil, edge: .top): .distance(0),
                        .init(category: nil, edge: .bottom): .distance(0),
                    ])
                }
            } else {
                guard let orientation else {
                    return .zero
                }
                if orientation == .horizontal {
                    return .horizontal(.zero)
                } else {
                    return .vertical(.zero)
                }
            }
        }

        mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            let value = spacer.minLength ?? defaultSpacingValue[orientation ?? .horizontal]
            return switch orientation {
            case .horizontal:
                CGSize(
                    width: max(proposedSize.width ?? -.infinity, value),
                    height: 0
                )
            case .vertical:
                CGSize(
                    width: 0,
                    height: max(proposedSize.height ?? -.infinity, value)
                )
            case nil:
                CGSize(
                    width: max(proposedSize.width ?? -.infinity, value),
                    height: max(proposedSize.height ?? -.infinity, value)
                )
            }

        }
    }

    struct Platform {}
}

// MARK: - PrimitiveSpacer

private protocol PrimitiveSpacer: PrimitiveView, UnaryView {
    var minLength: CGFloat? { get }

    static var axis: Axis? { get }

    static var requireTextBaselineSpacing: Bool { get }
}

extension PrimitiveSpacer {
    static var axis: Axis? { nil }

    static var requireTextBaselineSpacing: Bool { false }
}

extension PrimitiveSpacer {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var outputs = _ViewOutputs()
        if inputs.requestsLayoutComputer {

            let computer = if let orientation = axis ?? inputs.stackOrientation {
                SpacerLayoutComputer(
                    spacer: view.value,
                    orientation: orientation,
                    dynamicOrientation: .init(),
                    platform: .init()
                )
            } else {
                SpacerLayoutComputer(
                    spacer: view.value,
                    orientation: nil,
                    dynamicOrientation: inputs.dynamicStackOrientation,
                    platform: .init()
                )
            }
            outputs.layoutComputer = .init(computer)
        }
        if let representation = inputs.requestedSpacerRepresentation,
           representation.shouldMakeRepresentation(inputs: inputs) {
            representation.makeRepresentation(inputs: inputs, outputs: &outputs)
        }
        return outputs
    }
}

// MARK: - PlatformSpacerRepresentable

package protocol PlatformSpacerRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool

    static func makeRepresentation(inputs: _ViewInputs, outputs: inout _ViewOutputs)
}

extension _ViewInputs {
    package var requestedSpacerRepresentation: (any PlatformSpacerRepresentable.Type)? {
        get { base.requestedSpacerRepresentation }
        set { base.requestedSpacerRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct SpacerRepresentationKey: GraphInput {
        static let defaultValue: (any PlatformSpacerRepresentable.Type)? = nil
    }

    package var requestedSpacerRepresentation: (any PlatformSpacerRepresentable.Type)? {
        get { self[SpacerRepresentationKey.self] }
        set { self[SpacerRepresentationKey.self] = newValue }
    }
}
