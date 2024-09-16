//
//  CoreColor.h
//  COpenSwiftUI
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef CoreColor_h
#define CoreColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL CoreColorPlatformColorGetComponents(BOOL system, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha);

OPENSWIFTUI_EXPORT
Class CoreColorGetKitColorClass(BOOL isAppKitBased);

@interface CoreColor : NSObject

+ (id)colorWithSystem:(BOOL)system cgColor: (CGColorRef)cgColor;
+ (id)blackColorWithSystem:(BOOL)system;
+ (id)systemRedColorWithSystem:(BOOL)system;
+ (id)systemOrangeColorWithSystem:(BOOL)system;
+ (id)systemYellowColorWithSystem:(BOOL)system;
+ (id)systemGreenColorWithSystem:(BOOL)system;
+ (id)systemTealColorWithSystem:(BOOL)system;
+ (id)systemMintColorWithSystem:(BOOL)system;
+ (id)systemCyanColorWithSystem:(BOOL)system;
+ (id)systemBlueColorWithSystem:(BOOL)system;
+ (id)systemIndigoColorWithSystem:(BOOL)system;
+ (id)systemPurpleColorWithSystem:(BOOL)system;
+ (id)systemPinkColorWithSystem:(BOOL)system;
+ (id)systemBrownColorWithSystem:(BOOL)system;
+ (id)systemGrayColorWithSystem:(BOOL)system;

- (instancetype)initWithCGColor:(CGColorRef)cgColor;
- (void)set;
- (void)setFill;
- (void)setStroke;
- (CGColorRef)CGColor;
- (CoreColor *)colorWithAlphaComponent:(CGFloat)alpha;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* CoreColor_h */
