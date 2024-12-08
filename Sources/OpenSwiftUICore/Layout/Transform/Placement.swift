//
//  Placement.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation

/// The position and proposed size of a child view, as determined by a layout.
public struct _Placement: Equatable {
    
    public var proposedSize: CGSize {
        get { proposedSize_.fixingUnspecifiedDimensions() }
        set { proposedSize_ = _ProposedSize(newValue) }
    }
        
    package var proposedSize_: _ProposedSize
    
    /// The relative position in the child's actual size that will be placed at
    /// `anchorPosition`.
    public var anchor: UnitPoint
    
    /// The location that the anchor will be given in the layout’s coordinate
    /// space.
    public var anchorPosition: CGPoint
    
    /// Creates an instance with the given `proposedSize`, anchoring `anchor` at
    /// `anchorPosition`.
    public init(proposedSize: CGSize, anchoring anchor: UnitPoint = .topLeading, at anchorPosition: CGPoint) {
        self.proposedSize_ = _ProposedSize(proposedSize)
        self.anchor = anchor
        self.anchorPosition = anchorPosition
    }
    
    package init(proposedSize: _ProposedSize, anchoring anchor: UnitPoint, at anchorPosition: CGPoint) {
        self.proposedSize_ = proposedSize
        self.anchor = anchor
        self.anchorPosition = anchorPosition
    }
    
    package init(proposedSize: _ProposedSize, at anchorPosition: CGPoint) {
        self.proposedSize_ = proposedSize
        self.anchor = .topLeading
        self.anchorPosition = anchorPosition
    }
    
    package init(proposedSize: CGSize, aligning anchor: UnitPoint, in area: CGSize) {
        self.proposedSize_ = _ProposedSize(proposedSize)
        self.anchor = anchor
        self.anchorPosition = anchor.in(area)
    }
    
    package init(proposedSize: _ProposedSize, aligning anchor: UnitPoint, in area: CGSize) {
        self.proposedSize_ = proposedSize
        self.anchor = anchor
        self.anchorPosition = anchor.in(area)
    }
}

@available(*, unavailable)
extension _Placement: Sendable {}

extension _Placement {
    package func frameOrigin(childSize: CGSize) -> CGPoint {
        anchorPosition - CGSize(anchor.in(childSize))
    }
}
