//
//  OGMakeUniqueID.hpp
//  
//
//  Created by Kyle on 2023/10/9.
//

#ifndef OGMakeUniqueID_hpp
#define OGMakeUniqueID_hpp

#include <CoreFoundation/CoreFoundation.h>
typedef long long OGUniqueID __attribute__((swift_wrapper(struct)));

CF_EXTERN_C_BEGIN
CF_EXPORT
OGUniqueID OGMakeUniqueID(void);
CF_EXTERN_C_END

#endif /* OGMakeUniqueID_hpp */
