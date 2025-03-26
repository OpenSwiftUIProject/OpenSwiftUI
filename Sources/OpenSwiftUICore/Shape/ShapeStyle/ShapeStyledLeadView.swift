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

    typealias FramedShape =  (shape: ShapeStyle.RenderedShape.Shape, frame: CGRect)

    func shape(in size: CGSize) -> FramedShape

    static var hasBackground: Bool { get }

    func backgroundShape(in size: CGSize) -> FramedShape

    func isClear(styles: _ShapeStyle_Pack) -> Bool
}

extension ShapeStyledLeafView {
    package static var animatesSize: Bool { true }

    package static var hasBackground: Bool { false }

    package func backgroundShape(in size: CGSize) -> FramedShape {
        (shape: .path(Path(), FillStyle()), frame: .zero)
    }

    package func isClear(styles: ShapeStyle.Pack) -> Bool {
        styles.isClear(name: .foreground) && styles.isClear(name: .background)
    }

    package func contains(points: [PlatformPoint], size: CGSize) -> BitVector64 {
        preconditionFailure("TODO")
    }

    package func contentPath(size: CGSize) -> Path {
        preconditionFailure("TODO")
    }

    package static func makeLeafView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs,
        styles: Attribute<ShapeStyle.Pack>,
        interpolatorGroup: ShapeStyle.InterpolatorGroup? = nil,
        data: ShapeUpdateData
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

extension ShapeStyledLeafView where ShapeUpdateData == () {
    package mutating func mustUpdate(data: ShapeUpdateData, position: Attribute<ViewOrigin>) -> Bool {
        preconditionFailure("TODO")
    }

    @inlinable
    package static func makeLeafView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs,
        styles: Attribute<ShapeStyle.Pack>,
        interpolatorGroup: ShapeStyle.InterpolatorGroup? = nil,
        data: ShapeUpdateData
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

package struct ShapeStyledResponderData<V>: ContentResponder where V: ShapeStyledLeafView {
    package func contains(points: [PlatformPoint], size: CGSize) -> BitVector64 {
        preconditionFailure("TODO")
    }

    package func contentPath(size: CGSize) -> Path {
        preconditionFailure("TODO")
    }
}
