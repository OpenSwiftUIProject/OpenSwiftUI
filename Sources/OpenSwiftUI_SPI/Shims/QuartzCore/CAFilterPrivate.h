//
//  CAFilterPrivate.h
//  OpenSwiftUI_SPI

#ifndef CAFilterPrivate_h
#define CAFilterPrivate_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CAFilter : NSObject
@end

OPENSWIFTUI_EXPORT NSMutableArray<CAFilter *> *_CAFilterArrayCreate(void);
OPENSWIFTUI_EXPORT void _CAFilterArrayAppend(NSMutableArray<CAFilter *> *array, CAFilter *filter);

OPENSWIFTUI_EXPORT CAFilter * _Nullable OpenSwiftUICoreMakeGaussianBlurFilter(CGFloat radius) OPENSWIFTUI_SWIFT_NAME(CoreAnimationMakeGaussianBlurFilter(radius:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#endif /* CAFilterPrivate_h */
