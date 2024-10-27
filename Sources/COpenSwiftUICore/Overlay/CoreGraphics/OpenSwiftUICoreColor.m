//
//  OpenSwiftUICoreColor.h
//  COpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

#include "OpenSwiftUICoreColor.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include "OpenSwiftUICoreGraphicsContext.h"

Class OpenSwiftUICoreColorClass(BOOL isAppKitBased);

#if OPENSWIFTUI_TARGET_OS_OSX || OPENSWIFTUI_TARGET_OS_MACCATALYST
id NSColorSpaceForCGColorSpace(CGColorSpaceRef cgColorSpace);
Class NSColorSpaceClass(void);
#endif

BOOL OpenSwiftUICoreColorPlatformColorGetComponents(BOOL system, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    if (!color) {
        return NO;
    }
    Class colorClass = OpenSwiftUICoreColorClass(system);
    if (!colorClass) {
        return NO;
    }
    #if OPENSWIFTUI_TARGET_OS_OSX || OPENSWIFTUI_TARGET_OS_MACCATALYST
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

NSObject *OpenSwiftUICorePlatformColorForRGBA(BOOL system, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    if (!colorClass) {
        return nil;
    }
    #if OPENSWIFTUI_TARGET_OS_OSX || OPENSWIFTUI_TARGET_OS_MACCATALYST
    if (system) {
        id colorSpace = NSColorSpaceForCGColorSpace(CGColorSpaceCreateWithName(kCGColorSpaceExtendedSRGB));
        return [colorClass colorWithColorSpace:colorSpace components:(CGFloat[]){red, green, blue, alpha} count:4];
    }
    #endif
    return [[colorClass alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

Class OpenSwiftUICoreColorGetKitColorClass(BOOL system) {
    OpenSwiftUICoreColorClass(system);
}

Class OpenSwiftUICoreColorClass(BOOL system) {
    static BOOL isValid = true;
    static Class colorClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        #if OPENSWIFTUI_TARGET_OS_OSX || OPENSWIFTUI_TARGET_OS_MACCATALYST
        if (!system) {
            Class class = NSClassFromString(@"UIColor");
            colorClass = class;
            isValid = class != nil;
        }
        if (system) {
            Class class = NSClassFromString(@"NSColor");
            colorClass = class;
            isValid = class != nil;
        }
        #else
        Class class = NSClassFromString(@"UIColor");
        colorClass = class;
        isValid = class != nil;
        #endif
    });
    if (isValid) {
        return colorClass;
    } else {
        [NSException raise:@"Invalid core color" format:@""];
    }
}

#if OPENSWIFTUI_TARGET_OS_OSX || OPENSWIFTUI_TARGET_OS_MACCATALYST
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

@interface OpenSwiftUICoreColor () {
    CGColorRef _color;
}
@end

@implementation OpenSwiftUICoreColor

+ (NSObject *)colorWithSystem:(BOOL)system cgColor: (CGColorRef)cgColor {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    if (colorClass) {
        return [colorClass colorWithCGColor: cgColor];
    } else {
        return [[OpenSwiftUICoreColor alloc] initWithCGColor: cgColor];
    }
}

+ (NSObject *)blackColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass blackColor];
}

+ (NSObject *)systemRedColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemRedColor];
}

+ (NSObject *)systemOrangeColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemOrangeColor];
}

+ (NSObject *)systemYellowColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemYellowColor];
}

+ (NSObject *)systemGreenColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemGreenColor];
}

+ (NSObject *)systemTealColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemTealColor];
}

+ (NSObject *)systemMintColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemMintColor];
}

+ (NSObject *)systemCyanColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemCyanColor];
}

+ (NSObject *)systemBlueColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemBlueColor];
}

+ (NSObject *)systemIndigoColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemIndigoColor];
}

+ (NSObject *)systemPurpleColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemPurpleColor];
}

+ (NSObject *)systemPinkColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemPinkColor];
}

+ (NSObject *)systemBrownColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemBrownColor];
}

+ (NSObject *)systemGrayColorWithSystem:(BOOL)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
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
    CGContextRef context = OpenSwiftUICoreGraphicsContext.current.CGContext;
    if (!context) {
        return;
    }
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextSetStrokeColorWithColor(context, self.CGColor);
}

- (void)setFill {
    CGContextRef context = OpenSwiftUICoreGraphicsContext.current.CGContext;
    if (!context) {
        return;
    }
    CGContextSetFillColorWithColor(context, self.CGColor);
}

- (void)setStroke {
    CGContextRef context = OpenSwiftUICoreGraphicsContext.current.CGContext;
    if (!context) {
        return;
    }
    CGContextSetStrokeColorWithColor(context, self.CGColor);
}

- (CGColorRef)CGColor {
    return _color;
}

- (OpenSwiftUICoreColor *)colorWithAlphaComponent:(CGFloat)alpha {
    CGColorRef newColor = CGColorCreateCopyWithAlpha(_color, alpha);
    OpenSwiftUICoreColor *color = [[OpenSwiftUICoreColor alloc] initWithCGColor:newColor];
    CGColorRelease(newColor);
    return color;
}

@end

#endif
