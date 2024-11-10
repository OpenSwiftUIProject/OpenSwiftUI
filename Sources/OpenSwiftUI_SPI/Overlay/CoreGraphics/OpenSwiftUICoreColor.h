//
//  OpenSwiftUICoreColor.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
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
#include "OpenSwiftUICoreSystem.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL OpenSwiftUICoreColorPlatformColorGetComponents(OpenSwiftUICoreSystem system, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) OPENSWIFTUI_SWIFT_NAME(CoreColorPlatformColorGetComponents(system:color:red:green:blue:alpha:));

OPENSWIFTUI_EXPORT
NSObject  * _Nullable OpenSwiftUICorePlatformColorForRGBA(OpenSwiftUICoreSystem system, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) OPENSWIFTUI_SWIFT_NAME(CorePlatformColorForRGBA(system:red:green:blue:alpha:));

OPENSWIFTUI_EXPORT
Class _Nullable OpenSwiftUICoreColorGetKitColorClass(OpenSwiftUICoreSystem system) OPENSWIFTUI_SWIFT_NAME(CoreColorGetKitColorClass(system:));

OPENSWIFTUI_SWIFT_NAME(CoreColor)
@interface OpenSwiftUICoreColor : NSObject

+ (nullable NSObject *)colorWithSystem:(OpenSwiftUICoreSystem)system cgColor: (CGColorRef)cgColor;
+ (nullable NSObject *)blackColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemRedColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemOrangeColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemYellowColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemGreenColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemTealColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemMintColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemCyanColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemBlueColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemIndigoColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemPurpleColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemPinkColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemBrownColorWithSystem:(OpenSwiftUICoreSystem)system;
+ (nullable NSObject *)systemGrayColorWithSystem:(OpenSwiftUICoreSystem)system;

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
