//
//  dyld_Private.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.0.87
//  Status: Complete

//  Modified from: https://github.com/apple-oss-distributions/dyld/blob/dyld-1245.1/include/mach-o/dyld_priv.h

/*
 * Copyright (c) 2003-2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER
 */

#ifndef dyld_Private_h
#define dyld_Private_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <mach-o/dyld.h>
#else
struct mach_header {
    uint32_t    magic;        /* mach magic number identifier */
    int32_t        cputype;    /* cpu specifier */
    int32_t        cpusubtype;    /* machine specifier */
    uint32_t    filetype;    /* type of file */
    uint32_t    ncmds;        /* number of load commands */
    uint32_t    sizeofcmds;    /* the size of all the load commands */
    uint32_t    flags;        /* flags */
};
#endif

#if OPENSWIFTUI_TARGET_OS_DARWIN && __has_include(<Availability.h>)
#include <Availability.h>
#else
#ifndef __API_AVAILABLE
  #define __API_AVAILABLE(...)
#endif
#ifndef __SPI_AVAILABLE
  #define __SPI_AVAILABLE(...)
#endif
#endif

typedef uint32_t dyld_platform_t;

typedef struct {
    dyld_platform_t platform;
    uint32_t        version;
} dyld_build_version_t;

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

// Returns the active platform of the process
OPENSWIFTUI_EXPORT
dyld_platform_t dyld_get_active_platform(void) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);

// Base platforms are platforms that have version numbers (macOS, iOS, watchos, tvOS, bridgeOS)
// All other platforms are mapped to a base platform for version checks

// It is intended that most code in the OS will use the version set constants, which will correctly deal with secret and future
// platforms. For example:

//  if (dyld_program_sdk_at_least(dyld_fall_2018_os_versions)) {
//      New behaviour for programs built against the iOS 12, tvOS 12, watchOS 5, macOS 10.14, or bridgeOS 3 (or newer) SDKs
//  } else {
//      Old behaviour
//  }

// In cases where more precise control is required (such as APIs that were added to various platforms in different years)
// the os specific values may be used instead. Unlike the version set constants, the platform specific ones will only ever
// return true if the running binary is the platform being tested, allowing conditions to be built for specific platforms
// and releases that came out at different times. For example:

//  if (dyld_program_sdk_at_least(dyld_platform_version_iOS_12_0)
//      || dyld_program_sdk_at_least(dyld_platform_version_watchOS_6_0)) {
//      New behaviour for programs built against the iOS 12 (fall 2018), watchOS 6 (fall 2019) (or newer) SDKs
//  } else {
//      Old behaviour all other platforms, as well as older iOSes and watchOSes
//  }

OPENSWIFTUI_EXPORT
dyld_platform_t dyld_get_base_platform(dyld_platform_t platform) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);

// SPI to ask if a platform is a simulation platform
OPENSWIFTUI_EXPORT
bool dyld_is_simulator_platform(dyld_platform_t platform) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);

// Takes a version and returns if the image was built against that SDK or newer
// In the case of multi_platform mach-o's it tests against the active platform
OPENSWIFTUI_EXPORT
bool dyld_sdk_at_least(const struct mach_header* mh, dyld_build_version_t version) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);

// Takes a version and returns if the image was built with that minos version or newer
// In the case of multi_plaform mach-o's it tests against the active platform
OPENSWIFTUI_EXPORT
bool dyld_minos_at_least(const struct mach_header* mh, dyld_build_version_t version) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);

// Convenience versions of the previous two functions that run against the the main executable
OPENSWIFTUI_EXPORT
bool dyld_program_sdk_at_least(dyld_build_version_t version) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);
OPENSWIFTUI_EXPORT
bool dyld_program_minos_at_least(dyld_build_version_t version) __API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)/*, bridgeos(3.0)*/);

// Returns a token that can be used for version compares. This is intend to be used by frameworks that
// must send the information over to a daemon which performs the compare. These values should not be stored and
// are not guaranteed to be stable between OS releases.

OPENSWIFTUI_EXPORT
uint64_t dyld_get_program_sdk_version_token()  __SPI_AVAILABLE(macos(15.0), ios(18.0), watchos(11.0), tvos(18.0), bridgeos(9.0));
OPENSWIFTUI_EXPORT
uint64_t dyld_get_program_minos_version_token()  __SPI_AVAILABLE(macos(15.0), ios(18.0), watchos(11.0), tvos(18.0), bridgeos(9.0));
OPENSWIFTUI_EXPORT
dyld_platform_t dyld_version_token_get_platform(uint64_t token) __SPI_AVAILABLE(macos(15.0), ios(18.0), watchos(11.0), tvos(18.0), bridgeos(9.0));
OPENSWIFTUI_EXPORT
bool dyld_version_token_at_least(uint64_t token, dyld_build_version_t version) __SPI_AVAILABLE(macos(15.0), ios(18.0), watchos(11.0), tvos(18.0), bridgeos(9.0));

#endif /* dyld_Private_h */
