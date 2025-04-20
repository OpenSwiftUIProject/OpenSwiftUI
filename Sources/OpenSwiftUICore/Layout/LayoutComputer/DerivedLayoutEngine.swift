//
//  DerivedLayoutEngine.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

package protocol DerivedLayoutEngine: LayoutEngine {
  var base: LayoutComputer { get }
}

extension DerivedLayoutEngine {
    package func layoutPriority() -> Double {
        base.layoutPriority()
    }

    package func ignoresAutomaticPadding() -> Bool {
        base.ignoresAutomaticPadding()
    }

    package func requiresSpacingProjection() -> Bool {
        base.requiresSpacingProjection()
    }

    package mutating func spacing() -> Spacing {
        base.spacing()
    }

    package mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        base.sizeThatFits(proposedSize)
    }

    package mutating func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat {
        base.lengthThatFits(proposal, in: axis)
    }

    package mutating func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] {
        base.childGeometries(at: parentSize, origin: origin)
    }

    package mutating func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? {
        base.explicitAlignment(k, at: viewSize)
    }
}
