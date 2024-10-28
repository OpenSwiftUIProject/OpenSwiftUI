//
//  CoreFoundation_Private.c
//  OpenSwiftUI_SPI

#include "CoreFoundation_Private.h"
#include "dyld_Private.h"

bool _OpenSwiftUICFMZEnabled(void);

#if !OPENSWIFTUI_TARGET_OS_DARWIN
bool _CFMZEnabled(void) {
    return _OpenSwiftUICFMZEnabled();
}
#endif

bool _OpenSwiftUICFMZEnabled(void) {
    #if OPENSWIFTUI_TARGET_OS_OSX || OPENSWIFTUI_TARGET_OS_MACCATALYST
    return dyld_get_active_platform() == DYLD_PLATFORM_MACCATALYST || dyld_get_active_platform() == DYLD_PLATFORM_IOS;
    #else
    return false;
    #endif
}
