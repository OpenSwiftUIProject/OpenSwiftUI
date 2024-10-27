//
//  dyld_Private.h
//  COpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef dyld_Private_h
#define dyld_Private_h

#include "OpenSwiftUIBase.h"

typedef uint32_t dyld_platform_t;

typedef OPENSWIFTUI_ENUM(dyld_platform_t, DyldPlatform) {
    unknown = 0,
    macOS = 1,
    iOS = 2,
    tvOS = 3,
    watchOS = 4,
    bridgeOS = 5,
    macCatalyst = 6,
    iOSSimulator = 7,
    tvOSSimulator = 8,
    watchOSSimulator = 9,
    driverKit = 10,
    xROS = 11,
    xROSSimulator = 12,
};

typedef OPENSWIFTUI_ENUM(uint32_t, DyldMacOSXVersion) {
    V10_4 = 0x000A0400,
    V10_5 = 0x000A0500,
    V10_6 = 0x000A0600,
    V10_7 = 0x000A0700,
    V10_8 = 0x000A0800,
    V10_9 = 0x000A0900,
    V10_10 = 0x000A0A00,
    V10_11 = 0x000A0B00,
    V10_12 = 0x000A0C00,
    V10_13 = 0x000A0D00,
    V10_14 = 0x000A0E00,
    V10_15 = 0x000A0F00,
    V15_0 = 0x000F0000,
    /// For Test Only
    V16_0 = 0x00100000,
};

typedef OPENSWIFTUI_ENUM(uint32_t, DyldIOSVersion) {
    V2_0 = 0x00020000,
    V2_1 = 0x00020100,
    V2_2 = 0x00020200,
    V3_0 = 0x00030000,
    V3_1 = 0x00030100,
    V3_2 = 0x00030200,
    V4_0 = 0x00040000,
    V4_1 = 0x00040100,
    V4_2 = 0x00040200,
    V4_3 = 0x00040300,
    V5_0 = 0x00050000,
    V5_1 = 0x00050100,
    V6_0 = 0x00060000,
    V6_1 = 0x00060100,
    V7_0 = 0x00070000,
    V7_1 = 0x00070100,
    V8_0 = 0x00080000,
    V8_1 = 0x00080100,
    V8_2 = 0x00080200,
    V9_0 = 0x00090000,
    V18_0 = 0x00120000,
    /// For Test Only
    V19_0 = 0x00130000,
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
