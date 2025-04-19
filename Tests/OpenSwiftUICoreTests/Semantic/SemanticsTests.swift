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
    func isDeployedOnOrAfter() {
        #expect(OpenSwiftUICore.isDeployedOnOrAfter(.v1) == true)
        #expect(OpenSwiftUICore.isDeployedOnOrAfter(.v2) == true)
        #expect(OpenSwiftUICore.isDeployedOnOrAfter(.v3) == true)
        #expect(OpenSwiftUICore.isDeployedOnOrAfter(.v4) == true)
        #expect(OpenSwiftUICore.isDeployedOnOrAfter(.v5) == true)
        #expect(OpenSwiftUICore.isDeployedOnOrAfter(.v6) == false)
    }
}
