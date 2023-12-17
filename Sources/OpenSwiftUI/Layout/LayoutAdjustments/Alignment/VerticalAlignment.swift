//
//  VerticalAlignment.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/17.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: E20796D15DD3D417699102559E024115

#if canImport(Darwin)
import CoreGraphics
#elseif os(Linux)
import Foundation
#endif

@frozen
public struct VerticalAlignment: Equatable {
    public init(_ id: AlignmentID.Type) {
        key = AlignmentKey(id: id, axis: .vertical)
    }

    @usableFromInline
    let key: AlignmentKey

    public static let top = VerticalAlignment(Top.self)
    private enum Top: FrameAlignment {
        static func defaultValue(in _: ViewDimensions) -> CGFloat {
            .zero
        }
    }

    public static let center = VerticalAlignment(Center.self)
    private enum Center: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height / 2
        }
    }

    public static let bottom = VerticalAlignment(Bottom.self)
    private enum Bottom: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }
    }

    public static let firstTextBaseline = VerticalAlignment(FirstTextBaseline.self)
    private enum FirstTextBaseline: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = min(childValue, parentValue ?? .infinity)
        }
    }

    public static let lastTextBaseline = VerticalAlignment(LastTextBaseline.self)
    private enum LastTextBaseline: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = max(childValue, parentValue ?? -.infinity)
        }
    }
}
