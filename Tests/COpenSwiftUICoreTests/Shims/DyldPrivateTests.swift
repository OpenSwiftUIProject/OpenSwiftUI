//
//  DyldPrivateTests.swift
//  COpenSwiftUICoreTests

import COpenSwiftUICore
import Testing

struct DyldPrivateTests {
    @Test
    func sdkAtLeastVersion() {
#if canImport(Darwin)
        #expect(dyld_program_sdk_at_least(.init(
            platform: dyld_get_active_platform(),
            version: .max
        )) == false)
        #expect(dyld_program_sdk_at_least(.init(
            platform: dyld_get_active_platform(),
            version: .min
        )) == true)
        
        #if os(iOS)
        if #unavailable(iOS 19) {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DyldIOSVersion.V19_0.rawValue
            )) == false)
            if #unavailable(iOS 18) {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DyldIOSVersion.V18_0.rawValue
                )) == false)
            } else {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DyldIOSVersion.V18_0.rawValue
                )) == true)
            }
        } else {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DyldIOSVersion.V19_0.rawValue
            )) == true)
        }
        #elseif os(macOS)
        if #unavailable(macOS 16) {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DyldMacOSXVersion.V16_0.rawValue
            )) == false)
            if #unavailable(macOS 15) {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DyldMacOSXVersion.V15_0.rawValue
                )) == false)
            } else {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DyldMacOSXVersion.V15_0.rawValue
                )) == true)
            }
        } else {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DyldMacOSXVersion.V16_0.rawValue
            )) == true)
        }
        #else
        fatalError("Unsupported Darwin platform")
        #endif

#else
        #expect(dyld_program_sdk_at_least(.init(
            platform: dyld_get_active_platform(),
            version: .max
        )) == true)
        #expect(dyld_program_sdk_at_least(.init(
            platform: dyld_get_active_platform(),
            version: .min
        )) == true)
#endif
    }
    
    @Test
    func activePlatform() throws {
        let platform = try #require(DyldPlatform(rawValue: dyld_get_active_platform()))
#if canImport(Darwin)
        #if targetEnvironment(macCatalyst)
            #expect(platform == .macCatalyst)
        #elseif targetEnvironment(simulator)
            #if os(iOS)
            #expect(platform == .iOSSimulator)
            #elseif os(tvOS)
            #expect(platform == .tvOSSimulator)
            #elseif os(watchOS)
            #expect(platform == .watchOSSimulator)
            #elseif os(visionOS)
            #expect(platform == .xROSSimulator)
            #else
            fatalError("Unsupported Darwin simulator platform")
            #endif
        #else
            #if os(iOS)
            #expect(platform == .iOS)
            #elseif os(macOS)
            #expect(platform == .macOS)
            #elseif os(tvOS)
            #expect(platform == .tvOS)
            #elseif os(watchOS)
            #expect(platform == .watchOS)
            #elseif os(visionOS)
            #expect(platform == .xROS)
            #else
            fatalError("Unsupported Darwin platform")
            #endif
        #endif
#else
        #expect(platform == .unknown)
#endif
    }
}
