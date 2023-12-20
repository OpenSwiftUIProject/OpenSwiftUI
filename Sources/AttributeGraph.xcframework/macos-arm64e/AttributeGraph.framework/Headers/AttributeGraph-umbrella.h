#ifdef __OBJC__
#import <AppKit/AppKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AGAttribute.h"
#import "AGUniqueID.h"
#import "AGComparisonMode.h"
#import "AGCompareValues.h"

FOUNDATION_EXPORT double AGAttributeVersionNumber;
FOUNDATION_EXPORT const unsigned char AGAttributeVersionString[];

