//
//  OGMakeUniqueID.cpp
//  
//
//  Created by Kyle on 2023/10/9.
//

#include "OGUniqueID.hpp"
#include <stdatomic.h>

CF_EXPORT
OGUniqueID OGMakeUniqueID(void) {
    // Initial value is 1
    static atomic_llong counter = 1;
    return counter++;
}
