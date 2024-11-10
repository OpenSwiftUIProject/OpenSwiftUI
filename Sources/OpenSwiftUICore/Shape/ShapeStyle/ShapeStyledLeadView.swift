//
//  ShapeStyledLeadView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

import Foundation

protocol ShapeStyledLeafView: ContentResponder {
    static var animatesSize: Bool { get }
    func shape(size: CGSize) /*-> (ShapeStyle_RenderShape.Shape, CGRect)*/
    func isClear(style: _ShapeStyle_Shape.ResolvedStyle)
}
