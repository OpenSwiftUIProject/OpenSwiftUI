//
//  CoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// A resolved coordinate space created by the coordinate space protocol.
///
/// You don't typically use `CoordinateSpace` directly. Instead, use the static
/// properties and functions of `CoordinateSpaceProtocol` such as `.global`,
/// `.local`, and `.named(_:)`.
public enum CoordinateSpace {
    /// The global coordinate space at the root of the view hierarchy.
    case global
    
    /// The local coordinate space of the current view.
    case local
    
    /// A named reference to a view's local coordinate space.
    case named(AnyHashable)
    
    @_spi(ForOpenSwiftUIOnly)
    public struct ID: Equatable, Sendable {
        let value: UniqueID
        
        public init() {
            value = .init()
        }
    }
    
    @_spi(ForOpenSwiftUIOnly)
    case id(CoordinateSpace.ID)
  
    package static let root: CoordinateSpace = .global
    
    package var canonical: CoordinateSpace { self }
    
    package enum Name: Equatable {
        case name(AnyHashable)
        case id(CoordinateSpace.ID)
        package var space: CoordinateSpace {
            switch self {
                case let .name(name): .named(name)
                case let .id(id): .id(id)
            }
        }
    }
}

@available(*, unavailable)
extension CoordinateSpace: Sendable {}

extension CoordinateSpace {
    public var isGlobal: Bool { self == .global }
    
    public var isLocal: Bool { self == .local }
}

extension CoordinateSpace: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .global:
                hasher.combine(0)
            case .local:
                hasher.combine(1)
            case let .named(anyHashable):
                hasher.combine(2)
                anyHashable.hash(into: &hasher)
            case let .id(id):
                hasher.combine(3)
                hasher.combine(id.value)
        }
    }
}
