//
//  ResolvedGradient.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Empty

package struct ResolvedGradient: Equatable {
    package enum ColorSpace {
        case device
        case linear
        case perceptual

        func mix(_ lhs: Color.Resolved, _ rhs: Color.Resolved, by fraction: Float) -> Color.Resolved {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

// FIXME
public struct Gradient {}
