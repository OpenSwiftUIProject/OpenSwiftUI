//
//  OpenSwiftUICoreShadow.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "OpenSwiftUICoreShadow.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#else
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

#endif
