//
//  _ViewDebugTests.swift
//  
//
//  Created by Kyle on 2023/10/6.
//

import XCTest
@testable import OpenSwiftUI

final class _ViewDebugTests: XCTestCase {
    func testExample() throws {
        _ = _ViewDebug.serializedData([.init(data: [.size: CGSize(width: 20, height: 20)], childData: [])])
    }
}
