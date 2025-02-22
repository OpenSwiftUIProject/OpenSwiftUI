//
//  CoreAnimation_Private.h
//  OpenSwiftUI_SPI
//
//  Status: WIP

#ifndef CoreAnimation_Private_h
#define CoreAnimation_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CALayer (OpenSwiftUI_SPI)
- (BOOL)hasBeenCommitted;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#endif /* CoreAnimation_Private_h */
