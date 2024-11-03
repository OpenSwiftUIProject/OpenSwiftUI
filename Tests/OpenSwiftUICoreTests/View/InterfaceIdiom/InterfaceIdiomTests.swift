//
//  InterfaceIdiomTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUICore
import Testing

struct InterfaceIdiomTests {
    @Test
    func idiomEqual() {
        #expect(InterfaceIdiomKind.phone == .phone)
        #expect(InterfaceIdiomKind.phone != .touchBar)
    }
    
    @Test
    func idiomAccepts() {
        #expect(PhoneInterfaceIdiom.accepts(PhoneInterfaceIdiom.self) == true)
        #expect(PhoneInterfaceIdiom.accepts(TouchBarInterfaceIdiom.self) == false)
        
        #expect(ComplicationInterfaceIdiom.accepts(WidgetInterfaceIdiom.self) == true)
        #expect(ComplicationInterfaceIdiom.accepts(ComplicationInterfaceIdiom.self) == true)
        
        #expect(WidgetInterfaceIdiom.accepts(WidgetInterfaceIdiom.self) == true)
        #expect(WidgetInterfaceIdiom.accepts(ComplicationInterfaceIdiom.self) == false)
    }
    
    @Test
    func patternMatching() {
        #expect((PhoneInterfaceIdiom() ~= AnyInterfaceIdiom(.phone)) == true)
        
        #expect((ComplicationInterfaceIdiom() ~= AnyInterfaceIdiom(.widget)) == false)
        #expect((ComplicationInterfaceIdiom() ~= AnyInterfaceIdiom(.complication)) == true)
        
        #expect((WidgetInterfaceIdiom() ~= AnyInterfaceIdiom(.widget)) == true)
        #expect((WidgetInterfaceIdiom() ~= AnyInterfaceIdiom(.complication)) == false)
    }
}
