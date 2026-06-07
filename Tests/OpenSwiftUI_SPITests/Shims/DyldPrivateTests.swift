//
//  DyldPrivateTests.swift
//  OpenSwiftUI_SPITests

import dyldPrivate
import Testing

private func activePlatformBuildVersion(_ version: UInt32) -> dyld_build_version_t {
    .init(
        platform: dyld_get_active_platform(),
        version: version,
    )
}

struct DyldPrivateTests {
    @Test
    func sdkAtLeastVersion() {
        #if canImport(Darwin)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(.max)) == false)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(.min)) == true)

        #if os(iOS) || os(visionOS)
        // Path: Xcode-26.3.0.app Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents/xctest
        // SDK version: iOS 26.2
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._26_3.rawValue)) == false)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._26_2.rawValue)) == true)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._26_0.rawValue)) == true)
        #elseif os(macOS)
        // Path: Xcode-26.3.0.app Platforms/MacOSX.platform/Developer/Library/Xcode/Agents/xctest
        // SDK version: macOS 26.2
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(DYLD_MACOSX_VERSION._26_3.rawValue)) == false)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(DYLD_MACOSX_VERSION._26_2.rawValue)) == true)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(DYLD_MACOSX_VERSION._26_0.rawValue)) == true)
        #else
        preconditionFailure("Unsupported Darwin platform")
        #endif

        #else
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(.max)) == true)
        #expect(dyld_program_sdk_at_least(activePlatformBuildVersion(.min)) == true)
        #endif
    }

    @Test
    func minosAtLeastVersion() {
        #if canImport(Darwin)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(.max)) == false)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(.min)) == true)
        #if os(iOS) || os(visionOS)
        // Path: Xcode-26.3.0.app Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents/xctest
        // min version: iOS 14.0
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._26_0.rawValue)) == false)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._15_0.rawValue)) == false)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._14_0.rawValue)) == true)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_IOS_VERSION._13_0.rawValue)) == true)
        #elseif os(macOS)
        // Path: Xcode-26.3.0.app Platforms/MacOSX.platform/Developer/Library/Xcode/Agents/xctest
        // min version: macOS 14.0
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_MACOSX_VERSION._26_0.rawValue)) == false)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_MACOSX_VERSION._15_0.rawValue)) == false)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(DYLD_MACOSX_VERSION._14_0.rawValue)) == true)
        #else
        preconditionFailure("Unsupported Darwin platform")
        #endif

        #else
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(.max)) == true)
        #expect(dyld_program_minos_at_least(activePlatformBuildVersion(.min)) == true)
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
        preconditionFailure("Unsupported Darwin simulator platform")
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
        preconditionFailure("Unsupported Darwin platform")
        #endif
        #endif
        #else
        #expect(platform == .UNKNOWN)
        #endif
    }
}
