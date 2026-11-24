//
//  CircleTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

@MainActor
struct CircleTests {
    @Test(arguments: [
        (CGRect(x: 10, y: 20, width: 80, height: 40), 0, CGRect(x: 30, y: 20, width: 40, height: 40)),
        (CGRect(x: 10, y: 20, width: 80, height: 40), 5, CGRect(x: 35, y: 25, width: 30, height: 30)),
        (CGRect(x: 10, y: 20, width: 40, height: 80), 5, CGRect(x: 15, y: 45, width: 30, height: 30)),
        (CGRect(x: 10, y: 20, width: 40, height: 40), 5, CGRect(x: 15, y: 25, width: 30, height: 30)),
        (CGRect(x: 10, y: 20, width: 80, height: 40), -5, CGRect(x: 25, y: 15, width: 50, height: 50)),
        (CGRect(x: 10, y: 20, width: 80, height: 40), 20, CGRect(x: 50, y: 40, width: 0, height: 0)),
    ] as [(CGRect, CGFloat, CGRect)])
    func insetPathBounds(rect: CGRect, amount: CGFloat, expected: CGRect) {
        let path = Circle().inset(by: amount).path(in: rect)
        #expect(path.boundingRect == expected)
    }

    @Test
    func circularOutline() {
        let path = Circle().inset(by: 5).path(
            in: CGRect(x: 10, y: 20, width: 80, height: 40)
        )
        #expect(path.contains(CGPoint(x: 50, y: 40)))
        #expect(path.contains(CGPoint(x: 64, y: 40)))
        #expect(!path.contains(CGPoint(x: 36, y: 26)))
    }

    @Test(arguments: [21, 100] as [CGFloat])
    func overInsetProducesEmptyPath(amount: CGFloat) {
        let path = Circle().inset(by: amount).path(
            in: CGRect(x: 10, y: 20, width: 80, height: 40)
        )
        #expect(path.isEmpty)
    }

    @Test
    func specialBounds() {
        let circle = Circle().inset(by: 5)
        #expect(circle.path(in: .null).isEmpty)
        #expect(circle.path(in: .infinite).boundingRect == .infinite)
    }

    @Test
    func successiveInsets() {
        let rect = CGRect(x: 10, y: 20, width: 80, height: 40)
        let first = Circle().inset(by: 5)
        let second = first.inset(by: 7)
        #expect(first.path(in: rect).boundingRect == CGRect(x: 35, y: 25, width: 30, height: 30))
        #expect(second.path(in: rect).boundingRect == CGRect(x: 42, y: 32, width: 16, height: 16))
    }
}
