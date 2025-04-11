//
//  DisplayGamutTests.swift
//  OpenSwiftUICoreTests

@_spi(Private)
import OpenSwiftUICore
import Testing

struct DisplayGamutTests {
    @Test
    func enumInit() {
        #expect(DisplayGamut(rawValue: 0) == .sRGB)
        #expect(DisplayGamut(rawValue: 1) == .displayP3)
        #expect(DisplayGamut(rawValue: 2) == nil)
    }

    @Test
    func deviceDefault() {
        let defaultGamut = DisplayGamut.deviceDefault
        // For old devices, the defult may not be displayP3
        #expect(defaultGamut == .displayP3 || defaultGamut == .sRGB)
    }
}
