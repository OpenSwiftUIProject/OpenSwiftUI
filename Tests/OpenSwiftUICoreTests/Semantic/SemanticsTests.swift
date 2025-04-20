//
//  SemanticsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
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
    func semanticsIsDeployedOnOrAfter() {
        let expectedIsDeployedOnOrAfterV1: Bool
        let expectedIsDeployedOnOrAfterV2: Bool
        let expectedIsDeployedOnOrAfterV3: Bool
        let expectedIsDeployedOnOrAfterV4: Bool
        let expectedIsDeployedOnOrAfterV5: Bool
        let expectedIsDeployedOnOrAfterV6: Bool
        if #available(iOS 13, macOS 10.15, *) {
            expectedIsDeployedOnOrAfterV1 = true
        } else {
            expectedIsDeployedOnOrAfterV1 = false
        }
        if #available(iOS 14, macOS 11, *) {
            expectedIsDeployedOnOrAfterV2 = true
        } else {
            expectedIsDeployedOnOrAfterV2 = false
        }
        if #available(iOS 15, macOS 12, *) {
            expectedIsDeployedOnOrAfterV3 = true
        } else {
            expectedIsDeployedOnOrAfterV3 = false
        }
        if #available(iOS 16, macOS 13, *) {
            expectedIsDeployedOnOrAfterV4 = true
        } else {
            expectedIsDeployedOnOrAfterV4 = false
        }
        if #available(iOS 17, macOS 14, *) {
            expectedIsDeployedOnOrAfterV5 = true
        } else {
            expectedIsDeployedOnOrAfterV5 = false
        }
        if #available(iOS 18, macOS 15, *) {
            expectedIsDeployedOnOrAfterV6 = true
        } else {
            expectedIsDeployedOnOrAfterV6 = false
        }
        #expect(isDeployedOnOrAfter(.v1) == expectedIsDeployedOnOrAfterV1)
        #expect(isDeployedOnOrAfter(.v2) == expectedIsDeployedOnOrAfterV2)
        #expect(isDeployedOnOrAfter(.v3) == expectedIsDeployedOnOrAfterV3)
        #expect(isDeployedOnOrAfter(.v4) == expectedIsDeployedOnOrAfterV4)
        #expect(isDeployedOnOrAfter(.v5) == expectedIsDeployedOnOrAfterV5)
        #expect(isDeployedOnOrAfter(.v6) == expectedIsDeployedOnOrAfterV6)
    }
}
