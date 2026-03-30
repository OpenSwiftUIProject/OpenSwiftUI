//
//  CALayer+OpenSwiftUIAddition.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef CALayer_OpenSwiftUIAdditions_h
#define CALayer_OpenSwiftUIAdditions_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

#import <QuartzCore/QuartzCore.h>

// MARK: - CALayer (OpenSwiftUIAdditions)

@interface CALayer (OpenSwiftUIAdditions)

@property (nonatomic, assign) uint64_t openSwiftUI_viewTestProperties;

@property (nonatomic, assign) int64_t openSwiftUI_displayListID;

- (void)openSwiftUI_setNoAnimationDelegate;

@end

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */

#endif /* CALayer_OpenSwiftUIAdditions_h */
