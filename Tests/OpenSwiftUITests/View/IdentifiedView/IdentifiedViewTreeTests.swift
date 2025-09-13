//
//  IdentifiedViewTreeTests.swift
//  OpenSwiftUITests

import Testing
import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#endif

struct IdentifiedViewTreeTests {
    private func helper(identifier: AnyHashable) -> _IdentifiedViewProxy {
        return _IdentifiedViewProxy(
            identifier: identifier,
            size: .zero,
            position: .zero,
            transform: .init(),
            accessibilityNode: nil,
            platform: .init(.init(inputs: .invalidInputs(.invalid), outputs: _ViewOutputs()))
        )
    }
    
    @Test
    func forEachProxy() async {
        let tree = _IdentifiedViewTree.proxy(helper(identifier: "1"))
        await confirmation(expectedCount: 1) { confirm in
            tree.forEach { _ in
                confirm()
            }
        }
    }
    
    @Test
    func forEachArray() async {
        let tree = _IdentifiedViewTree.array([
            .proxy(helper(identifier: "1")),
            .empty,
            .array([.proxy(helper(identifier: "2"))])
        ])
        await confirmation(expectedCount: 2) { confirm in
            tree.forEach { _ in
                confirm()
            }
        }
    }
    
    @Test
    func forEachEmpty() async {
        let tree = _IdentifiedViewTree.empty
        await confirmation(expectedCount: 0) { confirm in
            tree.forEach { _ in
                confirm()
            }
        }
    }
}
