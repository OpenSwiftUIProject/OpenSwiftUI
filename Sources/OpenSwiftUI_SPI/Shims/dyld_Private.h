//
//  dyld_Private.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef dyld_Private_h
#define dyld_Private_h

#include "OpenSwiftUIBase.h"

typedef uint32_t dyld_platform_t;

typedef OPENSWIFTUI_ENUM(dyld_platform_t, DYLD_PLATFORM) {
    DYLD_PLATFORM_UNKNOWN = 0,
    DYLD_PLATFORM_MACOS = 1,
    DYLD_PLATFORM_IOS = 2,
    DYLD_PLATFORM_TVOS = 3,
    DYLD_PLATFORM_WATCHOS = 4,
    DYLD_PLATFORM_BRIDGEOS = 5,
    DYLD_PLATFORM_MACCATALYST = 6,
    DYLD_PLATFORM_IOSSIMULATOR = 7,
    DYLD_PLATFORM_TVOSSIMULATOR = 8,
    DYLD_PLATFORM_WATCHOSSIMULATOR = 9,
    DYLD_PLATFORM_DRIVERKIT = 10,
    DYLD_PLATFORM_XROS = 11,
    DYLD_PLATFORM_XROS_SIMULATOR = 12
};

typedef OPENSWIFTUI_ENUM(uint32_t, DYLD_MACOSX_VERSION) {
    DYLD_MACOSX_VERSION_10_4 = 0x000A0400,
    DYLD_MACOSX_VERSION_10_5 = 0x000A0500,
    DYLD_MACOSX_VERSION_10_6 = 0x000A0600,
    DYLD_MACOSX_VERSION_10_7 = 0x000A0700,
    DYLD_MACOSX_VERSION_10_8 = 0x000A0800,
    DYLD_MACOSX_VERSION_10_9 = 0x000A0900,
    DYLD_MACOSX_VERSION_10_10 = 0x000A0A00,
    DYLD_MACOSX_VERSION_10_11 = 0x000A0B00,
    DYLD_MACOSX_VERSION_10_12 = 0x000A0C00,
    DYLD_MACOSX_VERSION_10_13 = 0x000A0D00,
    DYLD_MACOSX_VERSION_10_14 = 0x000A0E00,
    DYLD_MACOSX_VERSION_10_15 = 0x000A0F00,
    DYLD_MACOSX_VERSION_15_0 = 0x000F0000,
    /// For Test Only
    DYLD_MACOSX_VERSION_16_0 = 0x00100000,
};

typedef OPENSWIFTUI_ENUM(uint32_t, DYLD_IOS_VERSION) {
    DYLD_IOS_VERSION_2_0 = 0x00020000,
    DYLD_IOS_VERSION_2_1 = 0x00020100,
    DYLD_IOS_VERSION_2_2 = 0x00020200,
    DYLD_IOS_VERSION_3_0 = 0x00030000,
    DYLD_IOS_VERSION_3_1 = 0x00030100,
    DYLD_IOS_VERSION_3_2 = 0x00030200,
    DYLD_IOS_VERSION_4_0 = 0x00040000,
    DYLD_IOS_VERSION_4_1 = 0x00040100,
    DYLD_IOS_VERSION_4_2 = 0x00040200,
    DYLD_IOS_VERSION_4_3 = 0x00040300,
    DYLD_IOS_VERSION_5_0 = 0x00050000,
    DYLD_IOS_VERSION_5_1 = 0x00050100,
    DYLD_IOS_VERSION_6_0 = 0x00060000,
    DYLD_IOS_VERSION_6_1 = 0x00060100,
    DYLD_IOS_VERSION_7_0 = 0x00070000,
    DYLD_IOS_VERSION_7_1 = 0x00070100,
    DYLD_IOS_VERSION_8_0 = 0x00080000,
    DYLD_IOS_VERSION_8_1 = 0x00080100,
    DYLD_IOS_VERSION_8_2 = 0x00080200,
    DYLD_IOS_VERSION_9_0 = 0x00090000,
    DYLD_IOS_VERSION_18_0 = 0x00120000,
    /// For Test Only
    DYLD_IOS_VERSION_19_0 = 0x00130000,
};

typedef struct {
    dyld_platform_t platform;
    uint32_t        version;
} dyld_build_version_t;

// Always return true on non-Darwin platform
OPENSWIFTUI_EXPORT
bool dyld_program_sdk_at_least(dyld_build_version_t version);

OPENSWIFTUI_EXPORT
dyld_platform_t dyld_get_active_platform(void);

#endif /* dyld_Private_h */
