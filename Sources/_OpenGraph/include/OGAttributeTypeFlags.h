//
//  OGAttributeTypeFlags.hpp
//
//
//  Created by Kyle on 2023/9/25.
//

#ifndef OGAttributeTypeFlags_hpp
#define OGAttributeTypeFlags_hpp

#include <OpenFoundation/OpenFoundation.h>

// FIXME: OF_OPTIONS is not working on Linux platform
#if !TARGET_OS_LINUX
typedef OF_OPTIONS(uint32_t, OGAttributeTypeFlags) {
    OGAttributeTypeFlags_0 = 0,
    OGAttributeTypeFlags_8 = 1 << 3,
};
#endif

#endif /* OGAttribute_hpp */

