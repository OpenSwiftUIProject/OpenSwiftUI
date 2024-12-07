//
//  ProposedSize.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

public struct _ProposedSize {
    package var width: CGFloat?
    package var height: CGFloat?
    
    package init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    package init() {
        self.width = nil
        self.height = nil
    }
    
    package func fixingUnspecifiedDimensions(at defaults: CGSize) -> CGSize {
        CGSize(width: width ?? defaults.width, height: height ?? defaults.height)
    }
    
    package func fixingUnspecifiedDimensions() -> CGSize {
        CGSize(width: width ?? 10.0, height: height ?? 10.0)
    }
    
    package func scaled(by s: CGFloat) -> _ProposedSize {
        _ProposedSize(width: width.map { $0 * s }, height: height.map { $0 * s })
    }
    
    package static let zero = _ProposedSize(width: 0, height: 0)
    package static let infinity = _ProposedSize(width: .infinity, height: .infinity)
    package static let unspecified = _ProposedSize(width: nil, height: nil)
}

@available(*, unavailable)
extension _ProposedSize: Sendable {}

extension _ProposedSize: Hashable {}

extension _ProposedSize {
    package init(_ s: CGSize) {
        width = s.width
        height = s.height
    }
}

extension CGSize {
    package init?(_ p: _ProposedSize) {
        guard let width = p.width, let height = p.height else { return nil }
        self.init(width: width, height: height)
    }
}

extension _ProposedSize {
    package func inset(by insets: EdgeInsets) -> _ProposedSize {
        _ProposedSize(
            width: width.map { max($0 - insets.leading - insets.trailing, .zero) },
            height: height.map { max($0 - insets.top - insets.bottom, .zero) }
        )
    }
    
    package subscript(axis: Axis) -> CGFloat? {
        get {
            switch axis {
                case .horizontal: width
                case .vertical: height
            }
        }
        set {
            switch axis {
                case .horizontal: width = newValue
                case .vertical: height = newValue
            }
        }
    }
    
    package init(_ l1: CGFloat?, in first: Axis, by l2: CGFloat?) {
        switch first {
            case .horizontal: self.init(width: l1, height: l2)
            case .vertical: self.init(width: l2, height: l1)
        }
    }
}
