//
//  OpenSwiftUICoreColor.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.0.87
//  Status: Complete

#include "OpenSwiftUICoreColor.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include "OpenSwiftUICoreGraphicsContext.h"

Class OpenSwiftUICoreColorClass(OpenSwiftUICoreSystem system);

#if OPENSWIFTUI_TARGET_OS_OSX
id NSColorSpaceForCGColorSpace(CGColorSpaceRef cgColorSpace);
Class NSColorSpaceClass(void);
#endif

BOOL OpenSwiftUICoreColorPlatformColorGetComponents(OpenSwiftUICoreSystem system, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    Class colorClass = OpenSwiftUICoreColorClass(system);
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
    } else {
        // For OPENSWIFTUI_TARGET_OS_MACCATALYST
        typedef BOOL (*Func)(id, SEL, CGFloat *, CGFloat *, CGFloat *, CGFloat *);
        IMP imp = [color methodForSelector:@selector(getRed:green:blue:alpha:)];
        Func func = (Func)imp;
        return func(color, @selector(getRed:green:blue:alpha:), red, green, blue, alpha);
    }
    #else
    return [color getRed:red green:green blue:blue alpha:alpha];
    #endif
}

id OpenSwiftUICorePlatformColorForRGBA(OpenSwiftUICoreSystem system, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    if (!colorClass) {
        return nil;
    }
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        id colorSpace = NSColorSpaceForCGColorSpace(CGColorSpaceCreateWithName(kCGColorSpaceExtendedSRGB));
        return [colorClass colorWithColorSpace:colorSpace components:(CGFloat[]){red, green, blue, alpha} count:4];
    } else {
        return [[colorClass alloc] initWithRed:red green:green blue:blue alpha:alpha];
    }
    #else
    return [[colorClass alloc] initWithRed:red green:green blue:blue alpha:alpha];
    #endif
}

Class _Nullable OpenSwiftUICoreColorGetKitColorClass(OpenSwiftUICoreSystem system) {
    return OpenSwiftUICoreColorClass(system);
}

Class _Nullable OpenSwiftUICoreColorClass(OpenSwiftUICoreSystem system) {
    static BOOL isValid = true;
    static Class colorClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        #if OPENSWIFTUI_TARGET_OS_OSX
        if (system == OpenSwiftUICoreSystemUIKit) {
            Class class = NSClassFromString(@"UIColor");
            colorClass = class;
            isValid = class != nil;
        }
        if (system == OpenSwiftUICoreSystemAppKit) {
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

@interface OpenSwiftUICoreColor () {
    CGColorRef _color;
}
@end

@implementation OpenSwiftUICoreColor

+ (NSObject *)colorWithSystem:(OpenSwiftUICoreSystem)system cgColor: (CGColorRef)cgColor {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    if (colorClass) {
        return [colorClass colorWithCGColor: cgColor];
    } else {
        return [[OpenSwiftUICoreColor alloc] initWithCGColor: cgColor];
    }
}

+ (NSObject *)blackColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass blackColor];
}

+ (NSObject *)systemRedColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemRedColor];
}

+ (NSObject *)systemOrangeColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemOrangeColor];
}

+ (NSObject *)systemYellowColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemYellowColor];
}

+ (NSObject *)systemGreenColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemGreenColor];
}

+ (NSObject *)systemTealColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemTealColor];
}

+ (NSObject *)systemMintColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemMintColor];
}

+ (NSObject *)systemCyanColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemCyanColor];
}

+ (NSObject *)systemBlueColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemBlueColor];
}

+ (NSObject *)systemIndigoColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemIndigoColor];
}

+ (NSObject *)systemPurpleColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemPurpleColor];
}

+ (NSObject *)systemPinkColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemPinkColor];
}

+ (NSObject *)systemBrownColorWithSystem:(OpenSwiftUICoreSystem)system {
    Class colorClass = OpenSwiftUICoreColorClass(system);
    return [colorClass systemBrownColor];
}

+ (NSObject *)systemGrayColorWithSystem:(OpenSwiftUICoreSystem)system {
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
