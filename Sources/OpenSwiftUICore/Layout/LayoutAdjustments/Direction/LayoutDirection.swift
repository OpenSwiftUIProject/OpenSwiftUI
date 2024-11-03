//
//  LayoutDirection.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 9DE75C3EAC30FFAB943BCC50F6D5E8C1

import Foundation

// MARK: - LayoutDirection

/// A direction in which OpenSwiftUI can lay out content.
///
/// OpenSwiftUI supports both left-to-right and right-to-left directions
/// for laying out content to support different languages and locales.
/// The system sets the value based on the user's locale, but
/// you can also use the ``View/environment(_:_:)`` modifier
/// to override the direction for a view and its child views:
///
///     MyView()
///         .environment(\.layoutDirection, .rightToLeft)
///
/// You can also read the ``EnvironmentValues/layoutDirection`` environment
/// value to find out which direction applies to a particular environment.
/// However, in many cases, you don't need to take any action based on this
/// value. OpenSwiftUI horizontally flips the x position of each view within its
/// parent, so layout calculations automatically produce the desired effect
/// for both modes without any changes.
public enum LayoutDirection: Hashable, CaseIterable {
    /// A left-to-right layout direction.
    case leftToRight
    
    /// A right-to-left layout direction.
    case rightToLeft
}

extension LayoutDirection: Sendable {}

#if canImport(UIKit)
// MARK: - UIKit integration

public import UIKit

extension LayoutDirection {
    /// Create a direction from its UITraitEnvironmentLayoutDirection equivalent.
    public init?(_ uiLayoutDirection: UITraitEnvironmentLayoutDirection) {
        switch uiLayoutDirection {
        case .unspecified:
            return nil
        case .leftToRight:
            self = .leftToRight
        case .rightToLeft:
            self = .rightToLeft
        @unknown default:
            return nil
        }
    }
}

extension UITraitEnvironmentLayoutDirection {
    /// Creates a trait environment layout direction from the specified OpenSwiftUI layout direction.
    public init(_ layoutDirection: LayoutDirection) {
        switch layoutDirection {
        case .leftToRight: self = .leftToRight
        case .rightToLeft: self = .rightToLeft
        }
    }
}

#endif

// MARK: - CodableLayoutDirection

struct CodableLayoutDirection: CodableProxy {
    var base: LayoutDirection
    
    private enum CodingValue: Int, Codable {
        case leftToRight
        case rightToLeft
    }
    
    @inline(__always)
    init(base: LayoutDirection) {
        self.base = base
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(CodingValue.self)
        switch value {
        case .leftToRight: base = .leftToRight
        case .rightToLeft: base = .rightToLeft
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let value: CodingValue = switch base {
        case .leftToRight: .leftToRight
        case .rightToLeft: .rightToLeft
        }
        try container.encode(value)
    }
}

// MARK: - LayoutDirection + CodableByProxy

extension LayoutDirection: CodableByProxy {
    var codingProxy: CodableLayoutDirection {
        CodableLayoutDirection(base: self)
    }
    
    static func unwrap(codingProxy: CodableLayoutDirection) -> LayoutDirection {
        codingProxy.base
    }
}

// MARK: - LayoutDirectionKey

private struct LayoutDirectionKey: EnvironmentKey {
    static let defaultValue: LayoutDirection = .leftToRight
}

extension EnvironmentValues {
    /// The layout direction associated with the current environment.
    public var layoutDirection: LayoutDirection {
        get { self[LayoutDirectionKey.self] }
        set { self[LayoutDirectionKey.self] = newValue }
        _modify { yield &self[LayoutDirectionKey.self] }
    }
}
