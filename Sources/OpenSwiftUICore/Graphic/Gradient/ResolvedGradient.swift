//
//  ResolvedGradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
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
