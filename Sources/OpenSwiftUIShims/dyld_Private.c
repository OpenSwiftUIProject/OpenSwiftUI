//
//  dyld_Private.c
//  
//
//  Created by Kyle on 2023/10/3.
//

#include "dyld_Private.h"

#if !TARGET_OS_DARWIN
bool dyld_program_sdk_at_least(dyld_build_version_t version) {
    return true;
}
#endif
