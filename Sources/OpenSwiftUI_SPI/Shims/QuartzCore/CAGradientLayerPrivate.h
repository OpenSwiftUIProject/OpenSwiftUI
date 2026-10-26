//
//  CAGradientLayerPrivate.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef CAGradientLayerPrivate_h
#define CAGradientLayerPrivate_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CAGradientLayer.h>)

#import <QuartzCore/CAGradientLayer.h>
#import <QuartzCore/CAMediaTimingFunction.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CAGradientLayer (OpenSwiftUI_SPI)

@property (nullable, copy, nonatomic) NSArray<CAMediaTimingFunction *> *interpolations;
@property (nullable, nonatomic) CGColorSpaceRef colorSpace;
@property (nonatomic) BOOL premultiplied;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CAGradientLayer.h */

#endif /* CAGradientLayerPrivate_h */
