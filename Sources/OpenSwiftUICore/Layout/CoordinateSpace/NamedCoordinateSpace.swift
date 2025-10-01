//
//  NamedCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

/// A named coordinate space.
///
/// Use the `coordinateSpace(_:)` modifier to assign a name to the local
/// coordinate space of a  parent view. Child views can then refer to that
/// coordinate space using `.named(_:)`.
public struct NamedCoordinateSpace: CoordinateSpaceProtocol, Equatable {
    package var name: CoordinateSpace.Name
    
    package init(name: CoordinateSpace.Name) {
        self.name = name
    }
    
    public var coordinateSpace: CoordinateSpace { name.space }
}

@available(*, unavailable)
extension NamedCoordinateSpace: Sendable {}

extension CoordinateSpaceProtocol where Self == NamedCoordinateSpace {
    /// Creates a named coordinate space using the given value.
    ///
    /// Use the `coordinateSpace(_:)` modifier to assign a name to the local
    /// coordinate space of a  parent view. Child views can then refer to that
    /// coordinate space using `.named(_:)`.
    ///
    /// - Parameter name: A unique value that identifies the coordinate space.
    ///
    /// - Returns: A named coordinate space identified by the given value.
    public static func named(_ name: some Hashable) -> NamedCoordinateSpace {
        NamedCoordinateSpace(name: .name(name))
    }
    
    package static func id(_ id: CoordinateSpace.ID) -> NamedCoordinateSpace {
        NamedCoordinateSpace(name: .id(id))
    }
}
