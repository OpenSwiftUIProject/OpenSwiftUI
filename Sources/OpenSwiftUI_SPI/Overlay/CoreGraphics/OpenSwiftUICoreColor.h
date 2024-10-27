//
//  OpenSwiftUICoreColor.h
//  OpenSwiftUI_SPI
//
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef OpenSwiftUICoreColor_h
#define OpenSwiftUICoreColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL OpenSwiftUICoreColorPlatformColorGetComponents(BOOL system, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha);

OPENSWIFTUI_EXPORT
NSObject  * _Nullable OpenSwiftUICorePlatformColorForRGBA(BOOL system, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);

OPENSWIFTUI_EXPORT
Class _Nullable OpenSwiftUICoreColorGetKitColorClass(BOOL system);

@interface OpenSwiftUICoreColor : NSObject

+ (nullable NSObject *)colorWithSystem:(BOOL)system cgColor: (CGColorRef)cgColor;
+ (nullable NSObject *)blackColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemRedColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemOrangeColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemYellowColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemGreenColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemTealColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemMintColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemCyanColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemBlueColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemIndigoColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemPurpleColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemPinkColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemBrownColorWithSystem:(BOOL)system;
+ (nullable NSObject *)systemGrayColorWithSystem:(BOOL)system;

- (instancetype)initWithCGColor:(CGColorRef)cgColor;
- (void)set;
- (void)setFill;
- (void)setStroke;
- (CGColorRef)CGColor;
- (OpenSwiftUICoreColor *)colorWithAlphaComponent:(CGFloat)alpha;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* OpenSwiftUICoreColor_h */
