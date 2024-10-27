//
//  dyld_Private.c
//  COpenSwiftUICore

#include "dyld_Private.h"

#if !OPENSWIFTUI_TARGET_OS_DARWIN
bool dyld_program_sdk_at_least(dyld_build_version_t version) {
    return true;
}

dyld_platform_t dyld_get_active_platform(void) {
    return 0;
}
#endif
