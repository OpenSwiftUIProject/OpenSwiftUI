//
//  OpenSwiftUICoreShadow.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "OpenSwiftUICoreShadow.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "OpenSwiftUICoreColor.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#elif OPENSWIFTUI_TARGET_OS_OSX
#include <AppKit/AppKit.h>
#endif

CGSize OpenSwiftUICoreShadowGetOffset(id shadow) {
    return [(NSShadow *)shadow shadowOffset];
}

CGFloat OpenSwiftUICoreShadowGetBlurRadius(id shadow) {
    return [(NSShadow *)shadow shadowBlurRadius];
}

id _Nullable OpenSwiftUICoreShadowGetPlatformColor(id shadow) {
    return [(NSShadow *)shadow shadowColor];
}

Class _Nullable OpenSwiftUICoreShadowClass(void) {
    static BOOL isValid = false;
    static Class shadowClass = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Class class = NSClassFromString(@"NSShadow");
        shadowClass = class;
        isValid = class != nil;
    });
    if (isValid) {
        return shadowClass;
    }
    return nil;
}

id _Nullable OpenSwiftUICoreMakeNSShadow(
    id color,
    CGFloat offsetX,
    CGFloat offsetY,
    CGFloat blurRadius
) {
    NSShadow *shadow = [[OpenSwiftUICoreShadowClass() alloc] init];
    shadow.shadowOffset = CGSizeMake(offsetX, offsetY);
    shadow.shadowBlurRadius = blurRadius;
    shadow.shadowColor = color;
    return shadow;
}

static id custom_shadow_style_color(OpenSwiftUICoreSystem system) {
    static id color;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        const CGFloat components[] = {
            -1.0,
            -1.0,
            -1.0,
            1.0 / 512.0,
        };
        CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(
            kCGColorSpaceExtendedSRGB
        );
        CGColorRef cgColor = CGColorCreate(colorSpace, components);
        CGColorSpaceRelease(colorSpace);
        color = [OpenSwiftUICoreColorGetKitColorClass(system) colorWithCGColor:cgColor];
        CGColorRelease(cgColor);
    });
    return color;
}

id _Nullable OpenSwiftUICoreMakeNSShadowWithCustomStyleIndex(
    OpenSwiftUICoreSystem system,
    CGFloat index
) {
    NSShadow *shadow = [[OpenSwiftUICoreShadowClass() alloc] init];
    shadow.shadowBlurRadius = index;
    shadow.shadowColor = custom_shadow_style_color(system);
    return shadow;
}

#endif
