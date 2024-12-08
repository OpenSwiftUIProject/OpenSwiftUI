//
//  ScrollCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package enum ScrollCoordinateSpace {
    package static let vertical: CoordinateSpace.ID = .init()
    package static let horizontal: CoordinateSpace.ID = .init()
    package static let all: CoordinateSpace.ID = .init()
    package static let content: CoordinateSpace.ID = .init()
}

extension CoordinateSpace {
    package static var verticalScrollView: CoordinateSpace { .id(ScrollCoordinateSpace.vertical) }
    package static var horizontalScrollView: CoordinateSpace { .id(ScrollCoordinateSpace.horizontal) }
    package static var scrollView: CoordinateSpace { .id(ScrollCoordinateSpace.all) }
    package static var scrollViewContent: CoordinateSpace { .id(ScrollCoordinateSpace.content) }
}

extension CoordinateSpace.Name {
    package static var verticalScrollView: CoordinateSpace.Name { .id(ScrollCoordinateSpace.vertical) }
    package static var horizontalScrollView: CoordinateSpace.Name { .id(ScrollCoordinateSpace.horizontal) }
    package static var scrollView: CoordinateSpace.Name { .id(ScrollCoordinateSpace.all) }
    package static var scrollViewContent: CoordinateSpace.Name { .id(ScrollCoordinateSpace.content) }
}

extension CoordinateSpaceProtocol where Self == NamedCoordinateSpace {
    /// The named coordinate space that is added by the system for the innermost
    /// containing scroll view that allows scrolling along the provided axis.
    public static func scrollView(axis: Axis) -> Self {
        NamedCoordinateSpace(name: axis == .horizontal ? .horizontalScrollView : .verticalScrollView)
    }
    
    /// The named coordinate space that is added by the system for the innermost
    /// containing scroll view.
    public static var scrollView: NamedCoordinateSpace { NamedCoordinateSpace(name: .scrollView) }
  
    package static var scrollViewContent: NamedCoordinateSpace { NamedCoordinateSpace(name: .scrollViewContent) }
}
