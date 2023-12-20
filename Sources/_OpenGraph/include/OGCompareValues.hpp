//
//  OGCompareValues.hpp
//  
//
//  Created by Kyle on 2023/10/9.
//

#ifndef OGCompareValues_hpp
#define OGCompareValues_hpp

#include <OpenFoundation/OpenFoundation.h>
#include "OGComparisonMode.hpp"
#include <stdbool.h>

OF_EXTERN_C_BEGIN
OF_EXPORT
bool OGCompareValues(const void *lhs, const void *rhs, const void *type, const OGComparisonMode comparisonMode);
OF_EXTERN_C_END

#endif /* OGCompareValues_hpp */
