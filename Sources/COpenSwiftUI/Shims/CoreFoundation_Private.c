//
//  CoreFoundation_Private.c
//  COpenSwiftUI

#include "CoreFoundation_Private.h"
#include "dyld_Private.h"

#if !OPENSWIFTUI_TARGET_OS_DARWIN

#define PLATFORM_IOS 2
#define PLATFORM_MACCATALYST 6

bool _CFMZEnabled(void) {
    return dyld_get_active_platform() == PLATFORM_MACCATALYST || dyld_get_active_platform() == PLATFORM_IOS;
}
#endif
