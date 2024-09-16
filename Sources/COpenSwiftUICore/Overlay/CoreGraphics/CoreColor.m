//
//  CoreColor.h
//  COpenSwiftUI
//  Audited for RELEASE_2024
//  Status: Complete

#include "CoreColor.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include "CoreGraphicsContext.h"

Class CoreColorClass(BOOL isAppKitBased);

#if OPENSWIFTUI_TARGET_OS_OSX
id NSColorSpaceForCGColorSpace(CGColorSpaceRef cgColorSpace);
Class NSColorSpaceClass(void);
#endif

BOOL CoreColorPlatformColorGetComponents(BOOL system, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    if (!color) {
        return NO;
    }
    Class colorClass = CoreColorClass(system);
    if (!colorClass) {
        return NO;
    }
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system) {
        id colorSpace = NSColorSpaceForCGColorSpace(CGColorSpaceCreateWithName(kCGColorSpaceExtendedSRGB));
        NSColor *nameSpaceColor = [color colorUsingColorSpace:colorSpace];
        if (nameSpaceColor) {
            [nameSpaceColor getRed:red green:green blue: blue alpha: alpha];
            return YES;
        } else {
            return NO;
        }
    }
    #endif
    // NOTE: Fix Mac Catalyst selector type issue
    return ((BOOL (*)(id, SEL))[color methodForSelector:@selector(getRed:green:blue:alpha:)])(color, @selector(getRed:green:blue:alpha:));
}

NSObject *CorePlatformColorForRGBA(BOOL system, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    Class colorClass = CoreColorClass(system);
    if (!colorClass) {
        return nil;
    }
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system) {
        id colorSpace = NSColorSpaceForCGColorSpace(CGColorSpaceCreateWithName(kCGColorSpaceExtendedSRGB));
        return [colorClass colorWithColorSpace:colorSpace components:(CGFloat[]){red, green, blue, alpha} count:4];
    }
    #endif
    return [[colorClass alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

Class CoreColorGetKitColorClass(BOOL system) {
    CoreColorClass(system);
}

Class CoreColorClass(BOOL system) {
    static BOOL isValid = false;
    static Class colorClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (system) {
            Class class = NSClassFromString(@"NSColor");
            colorClass = class;
            isValid = class != nil;
        } else {
            Class class = NSClassFromString(@"UIColor");
            colorClass = class;
            isValid = class != nil;
        }
    });
    if (isValid) {
        return colorClass;
    } else {
        [NSException raise:@"Invalid core color" format:@""];
    }
}

#if OPENSWIFTUI_TARGET_OS_OSX
id NSColorSpaceForCGColorSpace(CGColorSpaceRef cgColorSpace) {
    Class colorSpaceClass = NSColorSpaceClass();
    if (colorSpaceClass) {
        return [[colorSpaceClass alloc] initWithCGColorSpace:cgColorSpace];
    } else {
        return nil;
    }
}

OPENSWIFTUI_INLINE
Class NSColorSpaceClass(void) {
    static Class colorSpaceClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        colorSpaceClass = NSClassFromString(@"NSColorSpace");
    });
    return colorSpaceClass;
}
#endif

@interface CoreColor () {
    CGColorRef _color;
}
@end

@implementation CoreColor

+ (NSObject *)colorWithSystem:(BOOL)system cgColor: (CGColorRef)cgColor {
    Class colorClass = CoreColorClass(system);
    if (colorClass) {
        return [colorClass colorWithCGColor: cgColor];
    } else {
        return [[CoreColor alloc] initWithCGColor: cgColor];
    }
}

+ (NSObject *)blackColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass blackColor];
}

+ (NSObject *)systemRedColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemRedColor];
}

+ (NSObject *)systemOrangeColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemOrangeColor];
}

+ (NSObject *)systemYellowColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemYellowColor];
}

+ (NSObject *)systemGreenColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemGreenColor];
}

+ (NSObject *)systemTealColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemTealColor];
}

+ (NSObject *)systemMintColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemMintColor];
}

+ (NSObject *)systemCyanColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemCyanColor];
}

+ (NSObject *)systemBlueColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemBlueColor];
}

+ (NSObject *)systemIndigoColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemIndigoColor];
}

+ (NSObject *)systemPurpleColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemPurpleColor];
}

+ (NSObject *)systemPinkColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemPinkColor];
}

+ (NSObject *)systemBrownColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemBrownColor];
}

+ (NSObject *)systemGrayColorWithSystem:(BOOL)system {
    Class colorClass = CoreColorClass(system);
    return [colorClass systemGrayColor];
}

- (instancetype)initWithCGColor:(CGColorRef)cgColor {
    if (self = [super init]) {
        _color = CGColorRetain(cgColor);
    }
    return self;
}

- (void)dealloc {
    CGColorRelease(_color);
}

- (void)set {
    CGContextRef context = CoreGraphicsContext.current.CGContext;
    if (!context) {
        return;
    }
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextSetStrokeColorWithColor(context, self.CGColor);
}

- (void)setFill {
    CGContextRef context = CoreGraphicsContext.current.CGContext;
    if (!context) {
        return;
    }
    CGContextSetFillColorWithColor(context, self.CGColor);
}

- (void)setStroke {
    CGContextRef context = CoreGraphicsContext.current.CGContext;
    if (!context) {
        return;
    }
    CGContextSetStrokeColorWithColor(context, self.CGColor);
}

- (CGColorRef)CGColor {
    return _color;
}

- (CoreColor *)colorWithAlphaComponent:(CGFloat)alpha {
    CGColorRef newColor = CGColorCreateCopyWithAlpha(_color, alpha);
    CoreColor *color = [[CoreColor alloc] initWithCGColor:newColor];
    CGColorRelease(newColor);
    return color;
}

@end

#endif
