//
//  SemanticsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUI_SPI
import Testing

@MainActor
struct SemanticsTests {
    @Test
    func forced() {
        #if canImport(Darwin)
        if #available(iOS 13, macOS 10.15, *) {
            #expect(Semantics.forced.sdk == nil)
            #expect(Semantics.forced.deploymentTarget == nil)
        } else {
            #expect(Semantics.forced.sdk != nil)
            #expect(Semantics.forced.deploymentTarget != nil)
        }
        #else
        #expect(Semantics.forced.sdk == nil)
        #expect(Semantics.forced.deploymentTarget == nil)
        #endif
    }
    
    @Test
    func compare() {
        #expect(Semantics.v1 < Semantics.v2)
    }
    
    @Test
    func description() {
        #expect(Semantics.v1.description == "2019-9-1")
        #expect(Semantics.v2.description == "2020-9-1")
        #expect(Semantics.v3.description == "2021-9-1")
        #expect(Semantics.v4.description == "2022-9-1")
        #expect(Semantics.v5.description == "2023-9-1")
        #expect(Semantics.v6.description == "2024-0-0")
    }

    @Test
    func semanticsIsLinkedOnOrAfterAndIsDeployedOnOrAfter() {
        // This is currently tied with the toolchain's xctest binary
        #if os(iOS) || os(visionOS)
        #if compiler(<6.2) && compiler(>=6.1)
        // Path: Xcode-16.4.0.app Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents/xctest
        // SDK version: iOS 18.4
        // min version: iOS 13.0 (x86_64) & iOS 14.0 (arm64)
        #expect(isLinkedOnOrAfter(.v1) == true)
        #expect(isLinkedOnOrAfter(.v2) == true)
        #expect(isLinkedOnOrAfter(.v3) == true)
        #expect(isLinkedOnOrAfter(.v4) == true)
        #expect(isLinkedOnOrAfter(.v5) == true)
        #expect(isLinkedOnOrAfter(.v6) == true)
        #expect(isLinkedOnOrAfter(.v7) == false)
        #expect(isDeployedOnOrAfter(.v1) == true)
        #expect(isDeployedOnOrAfter(.v2) == true)
        #expect(isDeployedOnOrAfter(.v3) == false)
        #expect(isDeployedOnOrAfter(.v4) == false)
        #expect(isDeployedOnOrAfter(.v5) == false)
        #expect(isDeployedOnOrAfter(.v6) == false)
        #expect(isDeployedOnOrAfter(.v7) == false)
        #elseif compiler(>=6.2) && compiler(<6.3)
        // Path: Xcode-26.3.0.app Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents/xctest
        // SDK version: iOS 26.2
        // min version: iOS 13.0 (x86_64) & iOS 14.0 (arm64)
        #expect(isLinkedOnOrAfter(.v1) == true)
        #expect(isLinkedOnOrAfter(.v2) == true)
        #expect(isLinkedOnOrAfter(.v3) == true)
        #expect(isLinkedOnOrAfter(.v4) == true)
        #expect(isLinkedOnOrAfter(.v5) == true)
        #expect(isLinkedOnOrAfter(.v6) == true)
        #expect(isLinkedOnOrAfter(.v7) == false)
        #expect(isDeployedOnOrAfter(.v1) == true)
        #if arch(arm64)
        #expect(isDeployedOnOrAfter(.v2) == true)
        #else
        #expect(isDeployedOnOrAfter(.v2) == false)
        #endif
        #expect(isDeployedOnOrAfter(.v3) == false)
        #expect(isDeployedOnOrAfter(.v4) == false)
        #expect(isDeployedOnOrAfter(.v5) == false)
        #expect(isDeployedOnOrAfter(.v6) == false)
        #expect(isDeployedOnOrAfter(.v7) == false)
        #endif
        #elseif os(macOS)
        #if compiler(<6.2) && compiler(>=6.1)
        // Path: Xcode-16.4.0.app Platforms/MacOSX.platform/Developer/Library/Xcode/Agents/xctest
        // SDK version: macOS 15.4
        // min version: macOS 14.0
        #expect(isLinkedOnOrAfter(.v1) == true)
        #expect(isLinkedOnOrAfter(.v2) == true)
        #expect(isLinkedOnOrAfter(.v3) == true)
        #expect(isLinkedOnOrAfter(.v4) == true)
        #expect(isLinkedOnOrAfter(.v5) == true)
        #expect(isLinkedOnOrAfter(.v6) == true)
        #expect(isLinkedOnOrAfter(.v7) == false)
        #expect(isDeployedOnOrAfter(.v1) == true)
        #expect(isDeployedOnOrAfter(.v2) == true)
        #expect(isDeployedOnOrAfter(.v3) == true)
        #expect(isDeployedOnOrAfter(.v4) == true)
        #expect(isDeployedOnOrAfter(.v5) == true)
        #expect(isDeployedOnOrAfter(.v6) == false)
        #expect(isDeployedOnOrAfter(.v7) == false)
        #elseif compiler(>=6.2) && compiler(<6.3)
        // Path: Xcode-26.3.0.app Platforms/MacOSX.platform/Developer/Library/Xcode/Agents/xctest
        // SDK version: macOS 26.2
        // min version: macOS 14.0
        #expect(isLinkedOnOrAfter(.v1) == true)
        #expect(isLinkedOnOrAfter(.v2) == true)
        #expect(isLinkedOnOrAfter(.v3) == true)
        #expect(isLinkedOnOrAfter(.v4) == true)
        #expect(isLinkedOnOrAfter(.v5) == true)
        #expect(isLinkedOnOrAfter(.v6) == true)
        #expect(isLinkedOnOrAfter(.v7) == false)
        #expect(isDeployedOnOrAfter(.v1) == true)
        #expect(isDeployedOnOrAfter(.v2) == true)
        #expect(isDeployedOnOrAfter(.v3) == true)
        #expect(isDeployedOnOrAfter(.v4) == true)
        #expect(isDeployedOnOrAfter(.v5) == true)
        #expect(isDeployedOnOrAfter(.v6) == false)
        #expect(isDeployedOnOrAfter(.v7) == false)
        #endif
        #endif
    }
}
