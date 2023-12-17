//
//  ViewDimensions.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/16.
//  Lastest Version: iOS 15.5
//  Status: WIP

#if canImport(Darwin)
import CoreGraphics
#elseif os(Linux)
import Foundation
#endif

public struct ViewDimensions {
    let guideComputer: LayoutComputer
    var size: ViewSize

    public var width: CGFloat { size.value.width }
    public var height: CGFloat { size.value.height }

    public subscript(guide: HorizontalAlignment) -> CGFloat {
        self[guide.key]
    }

    public subscript(guide: VerticalAlignment) -> CGFloat {
        self[guide.key]
    }

    subscript(key: AlignmentKey) -> CGFloat {
        self[explicit: key] ?? key.id.defaultValue(in: self)
    }

    public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
        self[explicit: guide.key]
    }

    public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
        self[explicit: guide.key]
    }

    subscript(explicit key: AlignmentKey) -> CGFloat? {
        guideComputer.delegate.explicitAlignment(key, at: size)
    }
}

extension ViewDimensions: Equatable {}
