//
//  HorizontalAlignment.swift
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
public struct HorizontalAlignment: Equatable {
    public init(_ id: AlignmentID.Type) {
        key = AlignmentKey(id: id, axis: .horizontal)
    }

    @usableFromInline
    let key: AlignmentKey

    public static let leading = HorizontalAlignment(Leading.self)
    private enum Leading: FrameAlignment {
        static func defaultValue(in _: ViewDimensions) -> CGFloat {
            .zero
        }
    }

    public static let center = HorizontalAlignment(Center.self)
    private enum Center: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.width / 2
        }
    }

    public static let trailing = HorizontalAlignment(Trailing.self)
    private enum Trailing: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.width
        }
    }

    static let leadingText = HorizontalAlignment(LeadingText.self)
    private enum LeadingText: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = min(childValue, parentValue ?? .infinity)
        }
    }
}
