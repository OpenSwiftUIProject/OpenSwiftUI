//
//  InterfaceIdiomTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing
#if canImport(UIKit)
import UIKit
#endif

struct InterfaceIdiomTests {
    #if os(iOS) || os(tvOS)
    @Test
    func interfaceIdiom() throws {
        #expect(UIUserInterfaceIdiom.unspecified.idiom == nil)
        #expect(UIUserInterfaceIdiom.phone.idiom == AnyInterfaceIdiom(.phone))
        #expect(UIUserInterfaceIdiom.pad.idiom == AnyInterfaceIdiom(.pad))
        #expect(UIUserInterfaceIdiom.tv.idiom == AnyInterfaceIdiom(.tv))
        #expect(UIUserInterfaceIdiom.carPlay.idiom == AnyInterfaceIdiom(.carPlay))
        #expect(UIUserInterfaceIdiom(rawValue: 4)?.idiom == AnyInterfaceIdiom(.watch))
        #expect(UIUserInterfaceIdiom.carPlay.idiom == AnyInterfaceIdiom(.carPlay))
        #expect(UIUserInterfaceIdiom.vision.idiom == AnyInterfaceIdiom(.vision))
    }
    #endif
}
