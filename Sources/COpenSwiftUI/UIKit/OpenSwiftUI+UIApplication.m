//
//  OpenSwiftUI+UIApplication.m
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#include "OpenSwiftUI+UIApplication.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <objc/runtime.h>

UIContentSizeCategory _UIApplicationDefaultContentSizeCategory() {
    typedef UIContentSizeCategory (*Func)(Class, SEL);
    SEL selector = NSSelectorFromString(@"_defaultContentSizeCategory");
    Func func = nil;
    if ([UIApplication resolveClassMethod:selector]) {
        IMP impl = class_getMethodImplementation(UIApplication.class, selector);
        func = (Func)impl;
    }
    if (func == nil) {
        return UIContentSizeCategoryLarge;
    }
    return func(UIApplication.class, selector);
}

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */
