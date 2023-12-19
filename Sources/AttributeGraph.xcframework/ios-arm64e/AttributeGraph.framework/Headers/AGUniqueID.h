//
//  AGUniqueID.h
//  
//
//  Created by Kyle on 2023/10/9.
//

#ifndef AGUniqueID_h
#define AGUniqueID_h

#include <CoreFoundation/CoreFoundation.h>
typedef long long AGUniqueID;

CF_EXTERN_C_BEGIN
CF_EXPORT
AGUniqueID AGMakeUniqueID(void);
CF_EXTERN_C_END

#endif /* AGUniqueID_h */
