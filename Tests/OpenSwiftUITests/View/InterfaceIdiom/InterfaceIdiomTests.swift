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
        #if OPENSWIFTUI_RELEASE_2021
        #expect(UIUserInterfaceIdiom.unspecified.idiom == nil)
        #expect(UIUserInterfaceIdiom.phone.idiom == AnyInterfaceIdiomType.phone)
        #expect(UIUserInterfaceIdiom.pad.idiom == AnyInterfaceIdiomType.pad)
        #expect(UIUserInterfaceIdiom.tv.idiom == AnyInterfaceIdiomType.tv)
        #expect(UIUserInterfaceIdiom.carPlay.idiom == AnyInterfaceIdiomType.carplay)
        #expect(UIUserInterfaceIdiom(rawValue: 4)?.idiom == AnyInterfaceIdiomType.watch)
        #expect(UIUserInterfaceIdiom.mac.idiom == AnyInterfaceIdiomType.mac)
        if #available(iOS 17, tvOS 17, *) {
            #expect(UIUserInterfaceIdiom.vision.idiom == AnyInterfaceIdiomType.vision)            
        }
        #elseif OPENSWIFTUI_RELEASE_2024
        #expect(UIUserInterfaceIdiom.unspecified.idiom == nil)
        #expect(UIUserInterfaceIdiom.phone.idiom == AnyInterfaceIdiom(.phone))
        #expect(UIUserInterfaceIdiom.pad.idiom == AnyInterfaceIdiom(.pad))
        #expect(UIUserInterfaceIdiom.tv.idiom == AnyInterfaceIdiom(.tv))
        #expect(UIUserInterfaceIdiom.carPlay.idiom == AnyInterfaceIdiom(.carPlay))
        #expect(UIUserInterfaceIdiom(rawValue: 4)?.idiom == AnyInterfaceIdiom(.watch))
        #expect(UIUserInterfaceIdiom.mac.idiom == AnyInterfaceIdiom(.mac))
        #expect(UIUserInterfaceIdiom.vision.idiom == AnyInterfaceIdiom(.vision))
        #endif
    }
    #endif
}
