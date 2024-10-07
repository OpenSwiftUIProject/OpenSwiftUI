//
//  InterfaceIdiomTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUICore
import Testing
#if canImport(UIKit)
import UIKit
#endif

struct InterfaceIdiomTests {
    @Test
    func idiomEqual() {
        #expect(AnyInterfaceIdiomType.phone == .phone)
        #expect(AnyInterfaceIdiomType.phone != .touchBar)
    }
    
    @Test
    func idiomAccepts() throws {
        #expect(InterfaceIdiom.Phone.accepts(InterfaceIdiom.Phone.self) == true)
        #expect(InterfaceIdiom.Phone.accepts(InterfaceIdiom.CarPlay.self) == false)
    }
    
    #if os(iOS) || os(tvOS)
    @Test
    func interfaceIdiom() throws {
        #expect(UIUserInterfaceIdiom.unspecified.idiom == nil)
        #expect(UIUserInterfaceIdiom.phone.idiom == .phone)
        #expect(UIUserInterfaceIdiom.pad.idiom == .pad)
        #expect(UIUserInterfaceIdiom.tv.idiom == .tv)
        #expect(UIUserInterfaceIdiom.carPlay.idiom == .carplay)
        #expect(UIUserInterfaceIdiom(rawValue: 4)?.idiom == .watch)
        if #available(iOS 14, tvOS 14, *) {
            #expect(UIUserInterfaceIdiom.mac.idiom == .mac)
        }
        if #available(iOS 17, tvOS 17, *) {
            #expect(UIUserInterfaceIdiom.vision.idiom == .vision)
        }
    }

    @Test
    func interfaceIdiomInput() {
        #expect(InterfaceIdiom.Input.defaultValue == nil)
        let idiom = UIDevice.current.userInterfaceIdiom.idiom
        InterfaceIdiom.Input.defaultValue = idiom
        
        #expect(InterfaceIdiom.Input.defaultValue == idiom)
        #expect(InterfaceIdiom.Input.targetValue == .phone)
    }
    #endif
}
