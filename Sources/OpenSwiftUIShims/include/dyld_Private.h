//
//  dyld_Private.h
//
//
//  Created by Kyle on 2023/9/24.
//

#ifndef dyld_Private_h
#define dyld_Private_h

#include "OpenSwiftUIBase.h"

typedef uint32_t dyld_platform_t;

typedef struct {
    dyld_platform_t platform;
    uint32_t        version;
} dyld_build_version_t;

// Always return true on non-Darwin platform
extern bool dyld_program_sdk_at_least(dyld_build_version_t version);

#endif /* dyld_Private_h */
