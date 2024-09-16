//
//  dyld_Private.h
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#ifndef dyld_Private_h
#define dyld_Private_h

#include "OpenSwiftUIBase.h"

typedef uint32_t dyld_platform_t;

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
