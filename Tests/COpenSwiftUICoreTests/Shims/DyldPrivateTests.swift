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
                version: DYLD_IOS_VERSION._19_0.rawValue
            )) == false)
            if #unavailable(iOS 18) {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DYLD_IOS_VERSION._18_0.rawValue
                )) == false)
            } else {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DYLD_IOS_VERSION._18_0.rawValue
                )) == true)
            }
        } else {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DYLD_IOS_VERSION._19_0.rawValue
            )) == true)
        }
        #elseif os(macOS)
        if #unavailable(macOS 16) {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DYLD_MACOSX_VERSION._16_0.rawValue
            )) == false)
            if #unavailable(macOS 15) {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DYLD_MACOSX_VERSION._15_0.rawValue
                )) == false)
            } else {
                #expect(dyld_program_sdk_at_least(.init(
                    platform: dyld_get_active_platform(),
                    version: DYLD_MACOSX_VERSION._15_0.rawValue
                )) == true)
            }
        } else {
            #expect(dyld_program_sdk_at_least(.init(
                platform: dyld_get_active_platform(),
                version: DYLD_MACOSX_VERSION._16_0.rawValue
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
        let platform = try #require(DYLD_PLATFORM(rawValue: dyld_get_active_platform()))
#if canImport(Darwin)
        #if targetEnvironment(macCatalyst)
            #expect(platform == .MACCATALYST)
        #elseif targetEnvironment(simulator)
            #if os(iOS)
            #expect(platform == .IOSSIMULATOR)
            #elseif os(tvOS)
            #expect(platform == .TVOSSIMULATOR)
            #elseif os(watchOS)
            #expect(platform == .WATCHOSSIMULATOR)
            #elseif os(visionOS)
            #expect(platform == .XROS_SIMULATOR)
            #else
            fatalError("Unsupported Darwin simulator platform")
            #endif
        #else
            #if os(iOS)
            #expect(platform == .IOS)
            #elseif os(macOS)
            #expect(platform == .MACOS)
            #elseif os(tvOS)
            #expect(platform == .TVOS)
            #elseif os(watchOS)
            #expect(platform == .WATCHOS)
            #elseif os(visionOS)
            #expect(platform == .XROS)
            #else
            fatalError("Unsupported Darwin platform")
            #endif
        #endif
#else
        #expect(platform == .UNKNOWN)
#endif
    }
}
