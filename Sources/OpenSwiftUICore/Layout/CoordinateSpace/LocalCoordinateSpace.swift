//
//  LocalCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// The local coordinate space of the current view.
public struct LocalCoordinateSpace: CoordinateSpaceProtocol {
    public init() {}
    
    public var coordinateSpace: CoordinateSpace { .local }
}

@available(*, unavailable)
extension LocalCoordinateSpace: Sendable {}

extension CoordinateSpaceProtocol where Self == LocalCoordinateSpace {
    /// The local coordinate space of the current view.
    public static var local: LocalCoordinateSpace { .init() }
}
