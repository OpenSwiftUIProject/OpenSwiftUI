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

//    public subscript(guide: HorizontalAlignment) -> CGFloat {
//      get
//    }
//    public subscript(guide: VerticalAlignment) -> CGFloat {
//      get
//    }
//    public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
//      get
//    }
//    public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
//      get
//    }
}

extension ViewDimensions: Equatable {}
