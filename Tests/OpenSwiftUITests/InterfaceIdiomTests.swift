//
//  InterfaceIdiomTests.swift
//  
//
//  Created by Kyle on 2023/8/30.
//

import XCTest
@testable import OpenSwiftUI

final class InterfaceIdiomTests: XCTestCase {
    func testInterfaceIdiom() throws {
        XCTAssertEqual(
            UIUserInterfaceIdiom.unspecified.idiom,
            nil
        )
        XCTAssertEqual(
            UIUserInterfaceIdiom.phone.idiom,
            .phone
        )
        XCTAssertEqual(
            UIUserInterfaceIdiom.pad.idiom,
            .pad
        )
        XCTAssertEqual(
            UIUserInterfaceIdiom.tv.idiom,
            .tv
        )
        XCTAssertEqual(
            UIUserInterfaceIdiom.carPlay.idiom,
            .carplay
        )
        XCTAssertEqual(
            UIUserInterfaceIdiom(rawValue: 4)?.idiom,
            .watch
        )
        if #available(iOS 14, *) {
            XCTAssertEqual(
                UIUserInterfaceIdiom.mac.idiom,
                .mac
            )
        }
        if #available(iOS 17, *) {
            XCTAssertEqual(
                UIUserInterfaceIdiom.vision.idiom,
                .vision
            )
        }
    }
    
    func testIdiomEqual() throws {
        XCTAssertEqual(AnyInterfaceIdiomType.phone, AnyInterfaceIdiomType.phone)
        XCTAssertNotEqual(AnyInterfaceIdiomType.phone, AnyInterfaceIdiomType.touchBar)
    }
    
    func testIdiomAccepts() throws {
        XCTAssertTrue(InterfaceIdiom.Phone.accepts(InterfaceIdiom.Phone.self))
        XCTAssertFalse(InterfaceIdiom.Phone.accepts(InterfaceIdiom.CarPlay.self))
    }
    
    
    func testInterfaceIdiomInput() throws {
        XCTAssertNil(InterfaceIdiom.Input.defaultValue)
        let idiom = UIDevice.current.userInterfaceIdiom.idiom
        InterfaceIdiom.Input.defaultValue = idiom
        XCTAssertEqual(InterfaceIdiom.Input.defaultValue, idiom)
        XCTAssertEqual(InterfaceIdiom.Input.targetValue, .phone)
    }
}
