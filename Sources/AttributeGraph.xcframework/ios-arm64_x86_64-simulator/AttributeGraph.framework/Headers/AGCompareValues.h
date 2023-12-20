//
//  AGCompareValues.h
//  
//
//  Created by Kyle on 2023/10/9.
//

#ifndef AGCompareValues_h
#define AGCompareValues_h

#include <CoreFoundation/CoreFoundation.h>
#include "AGComparisonMode.h"
#include <stdbool.h>

CF_EXTERN_C_BEGIN
CF_EXPORT
bool AGCompareValues(const void *lhs, const void *rhs, const AGComparisonMode comparisonMode, const void *type);
CF_EXTERN_C_END

#endif /* AGCompareValues_h */
