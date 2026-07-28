//
//  OpenSwiftUI+UIApplication.m
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#include "OpenSwiftUI+UIApplication.h"
#include "Shims/OpenSwiftUIShims.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <objc/runtime.h>

UIContentSizeCategory _UIApplicationDefaultContentSizeCategory() {
    Class self = UIApplication.class;
    OPENSWIFTUI_SAFE_WRAPPER_IMP(UIContentSizeCategory, @"_defaultContentSizeCategory", UIContentSizeCategoryLarge);
    return func(self, selector);
}

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */
