//
//  CoreColor.h
//  COpenSwiftUI
//  Audited for RELEASE_2024
//  Status: Complete

#import "CoreColor.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

Class CoreColorClass(BOOL isAppKitBased);

#if OPENSWIFTUI_TARGET_OS_OSX
id NSColorSpaceForCGColorSpace(CGColorSpaceRef cgColorSpace);
Class NSColorSpaceClass(void);
#endif

BOOL CoreColorPlatformColorGetComponents(BOOL isAppKitBased, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
    if (!color) {
        return NO;
    }
    Class colorClass = CoreColorClass(isAppKitBased);
    if (colorClass) {
        #if OPENSWIFTUI_TARGET_OS_OSX
        if (isAppKitBased) {
            id colorSpace =
            NSColorSpaceForCGColorSpace(CGColorSpaceCreateWithName(kCGColorSpaceExtendedSRGB));
            NSColor *nameSpaceColor = [color colorUsingColorSpace:colorSpace];
            if (nameSpaceColor) {
                [nameSpaceColor getRed:red green:green blue: blue alpha: alpha];
                return YES;
            } else {
                return NO;
            }
        }
        #endif
        return ((BOOL (*)(id, SEL))[color methodForSelector:@selector(getRed:green:blue:alpha:)])(color, @selector(getRed:green:blue:alpha:));
    } else {
        return NO;
    }
}

Class CoreColorGetKitColorClass(BOOL isAppKitBased) {
    CoreColorClass(isAppKitBased);
}

Class CoreColorClass(BOOL isAppKitBased) {
    static BOOL isValid = false;
    static Class colorClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (isAppKitBased) {
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

#endif
