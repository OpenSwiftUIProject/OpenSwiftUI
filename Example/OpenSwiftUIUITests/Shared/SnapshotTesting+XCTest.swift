//
//  SnapshotTesting+XCTest.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import XCTest

class OpenSwiftUIUITestCase: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(diffTool: .ksdiff) {
            super.invokeTest()
        }
    }
}
