//
//  LayoutDirection.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 9DE75C3EAC30FFAB943BCC50F6D5E8C1 (SwiftUI)
//  ID: 54C853EF26D00A0E6B1785C3902A74F4 (SwiftUICore)

package import Foundation

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
public enum LayoutDirection: Hashable, CaseIterable, Sendable {
    /// A left-to-right layout direction.
    case leftToRight
    
    /// A right-to-left layout direction.
    case rightToLeft

    package func convert(_ rect: CGRect, to layoutDirection: LayoutDirection, in size: CGSize) -> CGRect {
        guard self != layoutDirection else {
            return rect
        }
        return CGRect(origin: CGPoint(x: size.width - rect.x - rect.width, y: rect.y), size: rect.size)
    }

    package var opposite: LayoutDirection {
        switch self {
        case .leftToRight: .rightToLeft
        case .rightToLeft: .leftToRight
        }
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
    }
}

// MARK: - LayoutDirection + CodableByProxy

extension LayoutDirection: CodableByProxy {
    package var codingProxy: CodableLayoutDirection {
        CodableLayoutDirection(self)
    }
}

// MARK: - CodableLayoutDirection

package struct CodableLayoutDirection: CodableProxy {
    package var base: LayoutDirection

    package init(_ base: LayoutDirection) {
        self.base = base
    }

    private enum CodingValue: Int, Codable {
        case leftToRight
        case rightToLeft
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let value: CodingValue = switch base {
        case .leftToRight: .leftToRight
        case .rightToLeft: .rightToLeft
        }
        try container.encode(value)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(CodingValue.self)
        switch value {
        case .leftToRight: base = .leftToRight
        case .rightToLeft: base = .rightToLeft
        }
    }
}
