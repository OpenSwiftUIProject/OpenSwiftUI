//
//  AGComparisonMode.hpp
//
//
//  Created by Kyle on 2023/12/20.
//

#ifndef AGComparisonMode_h
#define AGComparisonMode_h

#include <CoreFoundation/CoreFoundation.h>

typedef CF_OPTIONS(uint32_t, AGComparisonMode) {
    AGComparisonMode_0 = 0,
    AGComparisonMode_1 = 1 << 0,
    AGComparisonMode_2 = 1 << 1,
    AGComparisonMode_3 = AGComparisonMode_1 | AGComparisonMode_2,
};

#endif /* AGComparisonMode_h */

