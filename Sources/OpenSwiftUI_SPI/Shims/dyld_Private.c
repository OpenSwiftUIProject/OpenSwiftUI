//
//  dyld_Private.c
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#include "dyld_Private.h"

#if !OPENSWIFTUI_TARGET_OS_DARWIN
// Plain implementations for non-Darwin platforms

dyld_platform_t dyld_get_active_platform(void) {
    return DYLD_PLATFORM_UNKNOWN;
}

dyld_platform_t dyld_get_base_platform(dyld_platform_t platform) {
    return platform;
}

bool dyld_is_simulator_platform(dyld_platform_t platform) {
    return false;
}

bool dyld_sdk_at_least(const struct mach_header* mh, dyld_build_version_t version) {
    return true;
}

bool dyld_minos_at_least(const struct mach_header* mh, dyld_build_version_t version) {
    return true;
}

bool dyld_program_sdk_at_least(dyld_build_version_t version) {
    return true;
}

bool dyld_program_minos_at_least(dyld_build_version_t version) {
    return true;
}

uint64_t dyld_get_program_sdk_version_token() {
    return 0;
}

uint64_t dyld_get_program_minos_version_token() {
    return 0;
}

dyld_platform_t dyld_version_token_get_platform(uint64_t token) {
    return DYLD_PLATFORM_UNKNOWN;
}

bool dyld_version_token_at_least(uint64_t token, dyld_build_version_t version) {
    return true;
}
#endif
