//
//  ShapeStyledLeadView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import Foundation
package import OpenGraphShims

package protocol ShapeStyledLeafView: ContentResponder {
    static var animatesSize: Bool { get }
    associatedtype ShapeUpdateData = Void
    mutating func mustUpdate(data: ShapeUpdateData, position: Attribute<ViewOrigin>) -> Bool
    typealias FramedShape =  (shape: _ShapeStyle_RenderedShape.Shape, frame: CGRect)
    func shape(in size: CGSize) -> FramedShape
    static var hasBackground: Bool { get }
    func backgroundShape(in size: CGSize) -> FramedShape
    func isClear(styles: _ShapeStyle_Pack) -> Bool
}
