//
//  OGMakeUniqueID.hpp
//  
//
//  Created by Kyle on 2023/10/9.
//

#ifndef OGMakeUniqueID_hpp
#define OGMakeUniqueID_hpp

#include <OpenFoundation/OpenFoundation.h>
typedef long long OGUniqueID;

OF_EXTERN_C_BEGIN
OF_EXPORT
OGUniqueID OGMakeUniqueID(void);
OF_EXTERN_C_END

#endif /* OGMakeUniqueID_hpp */
