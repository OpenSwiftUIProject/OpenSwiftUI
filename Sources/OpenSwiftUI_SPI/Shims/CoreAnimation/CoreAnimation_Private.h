//
//  CoreAnimation_Private.h
//  OpenSwiftUI_SPI

#ifndef CoreAnimation_Private_h
#define CoreAnimation_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CALayer (OpenSwiftUI_SPI)
@property (nonatomic, assign, readonly) BOOL hasBeenCommitted_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(hasBeenCommitted);

@property (nonatomic, assign) uint64_t openSwiftUI_viewTestProperties;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#endif /* CoreAnimation_Private_h */
