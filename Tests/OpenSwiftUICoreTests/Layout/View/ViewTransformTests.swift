//
//  ViewTransformTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

struct ViewTransformTests {
    @Test
    func conversion() {
        #expect(MemoryLayout<CoordinateSpace>.size == 0x29)
        #expect(MemoryLayout<ViewTransform.Conversion>.size == 0x5A)
        
        let space = CoordinateSpace.named("test")
        
        do {
            let globalToSpace = ViewTransform.Conversion.globalToSpace(space)
            
            guard case let .spaceToSpace(global, space) = globalToSpace else {
                Issue.record("Expected .spaceToSpace, got \(globalToSpace)")
                return
            }
            guard case let .named(name) = space, let name = name as? String else {
                Issue.record("Expected .named, got \(space)")
                return
            }
            #expect(name == "test")
            #expect(global == .global)
        }
        
        do {
            let spaceToGlobal = ViewTransform.Conversion.spaceToGlobal(space)
            
            guard case let .spaceToSpace(space, global) = spaceToGlobal else {
                Issue.record("Expected .spaceToSpace, got \(spaceToGlobal)")
                return
            }
            guard case let .named(name) = space, let name = name as? String else {
                Issue.record("Expected .named, got \(space)")
                return
            }
            #expect(name == "test")
            #expect(global == .global)
        }
    }
    
    @Test
    func viewTransformDescription() {
        var transform = ViewTransform()
        transform.appendTranslation(CGSize(width: 10, height: 10))
        #expect(transform.description == #"""
        (10.0, 10.0)
        """#)
        transform.appendCoordinateSpace(name: "a")
        #expect(transform.description == #"""
        ((10.0, 10.0), CoordinateSpaceElement(name: AnyHashable("a")))
        """#)
        transform.appendSizedSpace(name: "b", size: .init(width: 20, height: 20))
        #expect(transform.description == #"""
        ((10.0, 10.0), CoordinateSpaceElement(name: AnyHashable("a"))); SizedSpaceElement(name: AnyHashable("b"), size: (20.0, 20.0))
        """#)
    }

    @Test
    func convertSpaceToLocal() {
        let space = CoordinateSpace.ID()
        var transform = ViewTransform()
        transform.appendTranslation(CGSize(width: 10, height: 20))
        transform.appendSizedSpace(id: space, size: CGSize(width: 100, height: 200))
        transform.appendTranslation(CGSize(width: 3, height: 4))

        var items: [ViewTransform.Item] = []
        transform.convert(.spaceToLocal(.id(space))) { item in
            items.append(item)
        }

        #expect(items == [
            .sizedSpace(.id(space), size: CGSize(width: 100, height: 200)),
            .translation(CGSize(width: 3, height: 4)),
        ])
    }

    @Test
    func convertBetweenSpaces() {
        let parentSpace = CoordinateSpace.ID()
        let childSpace = CoordinateSpace.ID()
        var transform = ViewTransform()
        transform.appendSizedSpace(id: parentSpace, size: CGSize(width: 100, height: 200))
        transform.appendTranslation(CGSize(width: 3, height: 4))
        transform.appendCoordinateSpace(id: childSpace)

        var forwardItems: [ViewTransform.Item] = []
        transform.convert(.spaceToSpace(.id(parentSpace), .id(childSpace))) { item in
            forwardItems.append(item)
        }
        #expect(forwardItems == [
            .sizedSpace(.id(parentSpace), size: CGSize(width: 100, height: 200)),
            .translation(CGSize(width: 3, height: 4)),
        ])

        var inverseItems: [ViewTransform.Item] = []
        transform.convert(.spaceToSpace(.id(childSpace), .id(parentSpace))) { item in
            inverseItems.append(item)
        }
        #expect(inverseItems == [
            .coordinateSpace(.id(childSpace)),
            .translation(CGSize(width: -3, height: -4)),
        ])
    }

    @Test
    func inverseConversionInvertsTransformItems() {
        let affine = CGAffineTransform(scaleX: 2, y: 3)
        let projection = ProjectionTransform(
            m11: 1, m12: 0, m13: 0.1,
            m21: 0, m22: 1, m23: 0,
            m31: 5, m32: 7, m33: 1
        )
        var transform = ViewTransform()
        transform.appendAffineTransform(affine, inverse: false)
        transform.appendProjectionTransform(projection, inverse: true)

        var items: [ViewTransform.Item] = []
        transform.convert(.localToSpace(.root)) { item in
            items.append(item)
        }

        #expect(items == [
            .projectionTransform(projection, inverse: false),
            .affineTransform(affine, inverse: true),
        ])
    }

    @Test
    func convertsPointsAndMutableCollections() {
        let space = CoordinateSpace.ID()
        var transform = ViewTransform()
        transform.appendSizedSpace(id: space, size: CGSize(width: 100, height: 200))
        transform.appendTranslation(CGSize(width: 3, height: 4))

        let convertedPoint = transform.convert(
            .spaceToLocal(.id(space)),
            point: CGPoint(x: 1, y: 2)
        )
        #expect(convertedPoint == CGPoint(x: 4, y: 6))
        #expect(transform.convert(.localToSpace(.id(space)), point: convertedPoint) == CGPoint(x: 1, y: 2))

        var points = [CGPoint(x: 1, y: 2), CGPoint(x: 5, y: 6)]
        transform.convert(.spaceToLocal(.id(space)), points: &points)
        #expect(points == [CGPoint(x: 4, y: 6), CGPoint(x: 8, y: 10)])

        var slice = points[...]
        transform.convert(.localToSpace(.id(space)), points: &slice)
        #expect(Array(slice) == [CGPoint(x: 1, y: 2), CGPoint(x: 5, y: 6)])
    }

    @Test
    func containingSizedCoordinateSpaceAppliesAffineTransforms() {
        let name = CoordinateSpace.Name.name(AnyHashable("target"))
        var transform = ViewTransform()
        transform.appendSizedSpace(name: "target", size: CGSize(width: 10, height: 20))
        transform.appendAffineTransform(CGAffineTransform(scaleX: 2, y: 3), inverse: false)

        #expect(
            transform.containingSizedCoordinateSpace(name: name) ==
            CGRect(origin: .zero, size: CGSize(width: 20, height: 60))
        )
    }

    @Test
    func scrollGeometryQueriesRespectClippingAndTransforms() {
        let geometry = ScrollGeometry(
            contentOffset: CGPoint(x: 1, y: 2),
            contentSize: CGSize(width: 100, height: 200),
            contentInsets: .zero,
            containerSize: CGSize(width: 20, height: 30)
        )

        var unclippedTransform = ViewTransform()
        unclippedTransform.appendScrollGeometry(geometry, isClipped: false)
        unclippedTransform.appendTranslation(CGSize(width: 3, height: 4))

        var translatedGeometry = geometry
        translatedGeometry.contentOffset += CGSize(width: 3, height: 4)
        #expect(unclippedTransform.containingScrollGeometry == nil)
        #expect(unclippedTransform.nearestScrollGeometry == translatedGeometry)

        var clippedTransform = ViewTransform()
        clippedTransform.appendScrollGeometry(geometry, isClipped: true)
        clippedTransform.appendAffineTransform(CGAffineTransform(scaleX: 2, y: 3), inverse: false)

        var transformedGeometry = geometry
        transformedGeometry.contentOffset = CGPoint(x: 2, y: 6)
        transformedGeometry.containerSize = CGSize(width: 40, height: 90)
        #expect(clippedTransform.containingScrollGeometry == transformedGeometry)
        #expect(clippedTransform.nearestScrollGeometry == transformedGeometry)
    }

    @Test
    func convertAndClipToScrollView() {
        let space = CoordinateSpace.ID()
        let geometry = ScrollGeometry(
            contentOffset: .zero,
            contentSize: CGSize(width: 100, height: 100),
            contentInsets: .zero,
            containerSize: CGSize(width: 50, height: 60)
        )
        var transform = ViewTransform()
        transform.appendCoordinateSpace(id: space)
        transform.appendScrollGeometry(geometry, isClipped: false)

        var rect = CGRect(x: -10, y: -10, width: 100, height: 100)
        let didConvertRect = rect.convertAndClipToScrollView(to: .id(space), transform: transform)
        #expect(didConvertRect)
        #expect(rect == CGRect(x: 0, y: 0, width: 50, height: 60))

        var nonRectilinearTransform = ViewTransform()
        nonRectilinearTransform.appendCoordinateSpace(id: space)
        nonRectilinearTransform.appendAffineTransform(
            CGAffineTransform(rotationAngle: .pi / 4),
            inverse: false
        )
        var rotatedRect = CGRect(x: 0, y: 0, width: 10, height: 20)
        let didConvertRotatedRect = rotatedRect.convertAndClipToScrollView(
            to: .id(space),
            transform: nonRectilinearTransform
        )
        #expect(!didConvertRotatedRect)

        var nullRect = CGRect.null
        let didConvertNullRect = nullRect.convertAndClipToScrollView(to: .id(space), transform: transform)
        #expect(didConvertNullRect)
        #expect(nullRect.isNull)
    }
}
