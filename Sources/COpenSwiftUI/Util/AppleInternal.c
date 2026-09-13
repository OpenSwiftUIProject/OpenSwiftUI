//
//  AppleInternal.c
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#include "AppleInternal.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <dispatch/dispatch.h>

extern bool os_variant_allows_internal_security_policies(const char *subsystem);
extern bool os_variant_has_internal_content(const char *subsystem);
#endif

bool _OpenSwiftUIIsAppleInternalBuild(void) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    static bool isInternal;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        isInternal = os_variant_allows_internal_security_policies("org.OpenSwiftUIProject.OpenSwiftUI")
            && os_variant_has_internal_content("org.OpenSwiftUIProject.OpenSwiftUI");
    });
    return isInternal;
    #else
    return false;
    #endif
}
